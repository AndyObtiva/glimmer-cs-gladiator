require 'models/glimmer/gladiator/file'

module Glimmer
  class Gladiator
    class Dir
      include Glimmer

      REFRESH_DELAY = 7
  
      class << self
        def local_dir
          unless @local_dir
            @local_dir = new(ENV['LOCAL_DIR'] || '.', true)
            @local_dir.refresh
            @filewatcher = Filewatcher.new(@local_dir.path)
            @thread = Thread.new(@filewatcher) do |fw| 
              fw.watch do |filename, event|
                if @last_update.nil? || (Time.now.to_f - @last_update) > REFRESH_DELAY
                  @local_dir.refresh if !filename.include?('new_file') && !@local_dir.selected_child_path_history.include?(filename) && filename != @local_dir.selected_child_path
                end
                @last_update = Time.now.to_f
              end
            end
          end
          @local_dir
        end        
      end
  
      attr_accessor :selected_child, :filter, :children, :filtered_path_options, :filtered_path, :path, :display_path
      attr_reader :name, :parent
      attr_writer :all_children
  
      def initialize(path, is_local_dir = false)
        @display_path = path
        @path = ::File.expand_path(@display_path)
        @name = ::File.basename(::File.expand_path(path))
        @display_path = @path.sub(Dir.local_dir.path, '').sub(/^\//, '') unless is_local_dir
        self.filtered_path_options = []
      end

      def name=(the_name)
        self.display_path = display_path.sub(/#{Regexp.escape(@name)}$/, the_name)
        @name = the_name
        new_path = ::File.expand_path(display_path)
        FileUtils.mv(path, new_path)
        self.path = display_path
      end
  
      def children
        @children ||= retrieve_children
      end

      def retrieve_children
        @children = ::Dir.glob(::File.join(@path, '*')).map do |p| 
          ::File.file?(p) ? Gladiator::File.new(p) : Gladiator::Dir.new(p)
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
          child_path = child.path.to_s.sub(Dir.local_dir.path, '')
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
        return if selected_path.nil? || 
                  ::Dir.exist?(selected_path) || 
                  (selected_child && ::File.expand_path(selected_child.path) == ::File.expand_path(selected_path))
        if ::File.file?(selected_path)
          @selected_child&.write_dirty_content
          new_child = Gladiator::File.new(selected_path)
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

at_exit do
  Glimmer::Gladiator::Dir.local_dir.selected_child&.write_raw_dirty_content
end
  
