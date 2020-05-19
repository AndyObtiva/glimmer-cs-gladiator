require 'models/glimmer/gladiator/file'

module Glimmer
  class Gladiator
    class Dir
      include Glimmer

      REFRESH_DELAY = 7
  
      class << self
        def local_dir
          @local_dir ||= new(ENV['LOCAL_DIR'] || '.').tap do |dir|
            dir.refresh
            @filewatcher = Filewatcher.new(dir.path)
            @thread = Thread.new(@filewatcher) do |fw| 
              fw.watch do |filename, event|
                if @last_update.nil? || (Time.now.to_f - @last_update) > REFRESH_DELAY
                  dir.refresh if !filename.include?('new_file') && !dir.selected_child_path_history.include?(filename) && filename != dir.selected_child_path
                end
                @last_update = Time.now.to_f
              end
            end
          end
        end
      end
  
      attr_accessor :selected_child, :filter, :children, :filtered_path_options, :filtered_path, :path, :display_path
      attr_reader :name, :parent
  
      def initialize(path)
        @display_path = path
        @path = ::File.expand_path(@display_path)
        @name = ::File.basename(::File.expand_path(path))
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
        ::Dir.glob(::File.join(@display_path, '*')).map {|p| ::File.file?(p) ? Gladiator::File.new(p) : Gladiator::Dir.new(p)}.sort_by {|c| c.path.to_s.downcase }.sort_by {|c| c.class.name }
      end
  
      def selected_child_path_history
        @selected_child_path_history ||= []
      end
  
      def refresh(async: true)
        new_all_children = retrieve_all_children
        new_children = retrieve_children        
        refresh_operation = lambda do
          @all_children = new_all_children
          @children ||= []
          @children.clear
          new_children.each do |child|
            @children << child
          end
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
        self.filtered_path_options = filtered.to_a.map(&:display_path)
      end
  
      def filtered
        return if filter.nil?
        all_children_files.select do |child| 
          child.path.downcase.include?(filter.downcase) ||
            child.path.downcase.gsub(/[_\/\.]/, '').include?(filter.downcase)
        end.sort_by {|c| c.path.to_s.downcase}
      end
  
      def all_children
        @all_children ||= retrieve_all_children
      end
  
      def retrieve_all_children
        ::Dir.glob(::File.join(@display_path, '**', '*')).map {|p| ::File.file?(p) ? Gladiator::File.new(p) : Gladiator::Dir.new(p)}
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
              selected_child_path_history << self.selected_child.path if self.selected_child
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
  
      def to_s
        path
      end
    end  
  end
end

at_exit do
  Glimmer::Gladiator::Dir.local_dir.selected_child&.write_raw_dirty_content
end
  
