# Copyright (c) 2020-2022 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'models/glimmer/gladiator/file'

module Glimmer
  class Gladiator
    class Dir
      include Glimmer
      include Glimmer::DataBinding::ObservableModel
      
      IGNORE_PATHS = ['.gladiator', '.gladiator-scratchpad', '.git', 'coverage', 'packages', 'node_modules', 'tmp', 'vendor', 'pkg', 'dist', 'log']

      attr_accessor :selected_child, :filter, :children, :filtered_path_options, :filtered_path, :display_path, :ignore_paths
      attr_reader :name, :parent, :path
      attr_writer :all_children
  
      def initialize(path, project_dir = nil)
        @project_dir = project_dir
        if is_local_dir
          @filewatcher = Filewatcher.new(path)
          @filewatcher_thread = Thread.new(@filewatcher) do |fw|
            begin
              fw.watch do |filename, event|
                # TODO do fine grained processing of events for enhanced performance (e.g. dir refresh vs file change)
                # TODO do fine grained file change only without a refresh delay for enhanced performance
                begin
                  if !@refresh_in_progress && !filename.include?('new_file') && !ignore_paths.any? { |ignore_path| filename.include?(ignore_path) } && (event != :updated || find_child_file(filename).nil?)
                    Thread.new {
                      refresh
                    }
                  end
                rescue => e
                  puts e.full_message
                end
              end
            rescue => e
              puts e.full_message
            end
          end
        end
        self.path = ::File.expand_path(path)
        @name = ::File.basename(::File.expand_path(path))
        @ignore_paths = IGNORE_PATHS
        self.filtered_path_options = []
      end
      
      def is_local_dir
        @project_dir.nil?
      end

      def project_dir
        @project_dir || self
      end

      def path=(the_path)
        @path = the_path
        generate_display_path
      end
      
      def generate_display_path
        is_local_dir ? path : @display_path = @path.sub(project_dir.path, '').sub(/^\//, '')
      end
      
      def name=(the_name)
        self.display_path = display_path.sub(/#{Regexp.escape(@name)}$/, the_name)
        @name = the_name
        new_path = @project_dir.nil? ? ::File.expand_path(display_path) : ::File.join(project_dir.path, display_path)
        FileUtils.mv(path, new_path)
        self.path = display_path
      end
  
      def children
        @children ||= retrieve_children
      end

      def retrieve_children
        @children = ::Dir.glob(::File.join(@path, '*')).reject do |p|
          # TODO make sure to configure ignore_paths in a preferences dialog
          if project_dir == self
            project_dir.ignore_paths.any? do |ignore_path|
              p.include?(ignore_path)
            end
          end
        end.map do |p|
          ::File.file?(p) ? File.new(p, project_dir) : Dir.new(p, project_dir)
        end.sort_by do |c|
          c.path.to_s.downcase
        end.sort_by do |c|
          c.class.name
        end.each do |child|
          child.retrieve_children if child.is_a?(Dir)
        end
      end
      
      def find_child_file(child_path)
        depth_first_search_file(self, child_path)
      end
      
      def depth_first_search_file(dir, file_path)
        dir.children.each do |child|
          if child.is_a?(File)
            return child if child.path.include?(file_path.to_s)
          else
            result = depth_first_search_file(child, file_path)
            return result unless result.nil?
          end
        end
        nil
      end
  
      def selected_child_path_history
        @selected_child_path_history ||= []
      end
      
      def close
        all_children_files.each(&:close)
        stop_filewatcher
      end
      
      def stop_filewatcher
        @filewatcher&.stop
        @filewatcher_thread&.kill
        @filewatcher_thread = nil
        @filewatcher&.finalize
        @filewatcher = nil
      end
  
      def pause_refresh
        @refresh_paused = true
      end
      
      def resume_refresh
        @refresh_paused = false
      end

      def refresh(async: true, force: false)
        return if @refresh_paused && !force
        @refresh_in_progress = true
        retrieve_children
        collect_all_children
        refresh_operation = lambda do
          notify_observers(:children)
          notify_observers(:all_children)
        end
        if async
          async_exec(&refresh_operation)
        else
          sync_exec(&refresh_operation)
        end
        @refresh_in_progress = false
      end
  
      def filter=(value)
        if value.to_s.empty?
          @filter = nil
        else
          @filter = value
        end
        @last_filtered = filtered.to_a
        self.filtered_path_options = @last_filtered.map(&:display_path)
        @last_filter = @filter
      end
  
      def filtered
        return if filter.nil?
        children_files = !@last_filter.to_s.empty? && filter.downcase.start_with?(@last_filter.downcase) ? @last_filtered : all_children_files
        children_files.select do |child|
          child_path = child.path.to_s.sub(project_dir.path, '')
          child_path.downcase.include?(filter.downcase) ||
            child_path.downcase.gsub(/[_\/.-]/, '').include?(filter.downcase.gsub(/[_\/.-]/, ''))
        end.sort_by {|c| c.path.to_s.downcase}
      end
  
      def all_children
        @all_children ||= collect_all_children
      end
  
      def collect_all_children
        @all_children = children.reduce([]) do |output, child|
          addition = [child]
          addition += child.collect_all_children if child.is_a?(Dir)
          output + addition
        end
      end
  
      def all_children_files
        all_children.select {|child| child.is_a?(Gladiator::File) }
      end
  
      def selected_child_path=(selected_path)
        return (project_dir.selected_child = nil) if selected_path.nil?
        # scratchpad scenario
        if selected_path.empty? # Scratchpad
          @selected_child&.write_dirty_content
          @scratchpad = (self.selected_child = File.new('', project_dir)) if @scratchpad.nil? || @scratchpad.closed?
          return @scratchpad
        end
        full_selected_path = selected_path.include?(project_dir.path) ? selected_path : ::File.join(project_dir.path, selected_path)
        return if ::Dir.exist?(full_selected_path) ||
                  (selected_child && selected_child.path == full_selected_path)
        selected_path = full_selected_path
        if ::File.file?(selected_path)
          @selected_child&.write_dirty_content
          new_child = find_child_file(selected_path)
          begin
            unless new_child.dirty_content.nil?
              selected_child_path_history << new_child.path if new_child && !selected_child_path_history.include?(new_child.path)
              self.selected_child = new_child
              self.selected_child.start_filewatcher
            end
          rescue
            # no op
          end
        else
          refresh
        end
      end
      
      def selected_child_path
        @selected_child&.path
      end
      
      def selected_child=(new_child)
        return if selected_child == new_child
        file_properties = @selected_child&.backup_properties if @selected_child == new_child
        @selected_child = new_child
        @selected_child.restore_properties(file_properties) if file_properties
      end
      
      def remove!
        FileUtils.rm_rf(path)
      end
  
      def to_s
        path
      end
      
      def eql?(other)
        self.path.eql?(other&.path)
      end

      def hash
        self.path.hash
      end
    end
  end
end
  
