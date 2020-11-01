require 'models/glimmer/gladiator/file'

module Glimmer
  class Gladiator
    class Dir
      include Glimmer

      REFRESH_DELAY = 7
  
      attr_accessor :selected_child, :filter, :children, :filtered_path_options, :filtered_path, :display_path, :ignore_paths
      attr_reader :name, :parent, :path
      attr_writer :all_children
  
      def initialize(path, project_dir = nil)
        @project_dir = project_dir
        if is_local_dir
         @filewatcher = Filewatcher.new(path)
         @thread = Thread.new(@filewatcher) do |fw|
           fw.watch do |filename, event|
             if @last_update.nil? || (Time.now.to_f - @last_update) > REFRESH_DELAY
               refresh if !filename.include?('new_file') && !selected_child_path_history.include?(filename) && filename != selected_child_path
             end
             @last_update = Time.now.to_f
           end
         end
        end
        self.path = ::File.expand_path(path)
        @name = ::File.basename(::File.expand_path(path))
        @ignore_paths = ['.gladiator', '.git', 'coverage', 'packages', 'tmp', 'vendor']
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
      
      def children
        @children ||= retrieve_children
      end

      def retrieve_children
        @children = ::Dir.glob(::File.join(@path, '*')).reject do |p|
          # TODO make sure to configure ignore_paths in a preferences dialog
          project_dir.ignore_paths.reduce(false) do |result, ignore_path|
            result || p.include?(ignore_path)
          end
        end.map do |p|
          ::File.file?(p) ? Gladiator::File.new(p, project_dir) : Gladiator::Dir.new(p, project_dir)
        end.sort_by do |c|
          c.path.to_s.downcase
        end.sort_by do |c|
          c.class.name
        end.each do |child|
          child.retrieve_children if child.is_a?(Dir)
        end
      end
  
      def selected_child_path_history
        @selected_child_path_history ||= []
      end
  
      def pause_refresh
        @refresh_paused = true
      end
      
      def resume_refresh
        @refresh_paused = false
      end

      def refresh(async: true, force: false)
        return if @refresh_paused && !force
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
        # scratchpad scenario
        if selected_path&.empty? #scratchpad
          @selected_child&.write_dirty_content
          return (self.selected_child = File.new)
        end
        full_selected_path = selected_path.include?(project_dir.path) ? selected_path : ::File.join(project_dir.path, selected_path)
        return if selected_path.nil? ||
                  ::Dir.exist?(full_selected_path) ||
                  (selected_child && selected_child.path == full_selected_path)
        selected_path = full_selected_path
        if ::File.file?(selected_path)
          @selected_child&.write_dirty_content
          new_child = Gladiator::File.new(selected_path, project_dir)
          begin
            unless new_child.dirty_content.nil?
              self.selected_child&.stop_filewatcher
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
        file_properties = @selected_child&.backup_properties if @selected_child == new_child
        @selected_child = new_child
        @selected_child.restore_properties(file_properties) if file_properties
      end
      
      def delete!
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
  