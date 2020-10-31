module Glimmer
  class Gladiator
    class File
      include Glimmer

      attr_accessor :dirty_content, :line_numbers_content, :selection, :line_number, :find_text, :replace_text, :top_pixel, :display_path, :case_sensitive
      attr_reader :name, :path, :project_dir

      def initialize(path=nil, project_dir=nil)
        path = nil if path&.strip&.empty?
        raise "Not a file path: #{path}" if !path.nil? && !::File.file?(path)
        @project_dir = project_dir
        @command_history = []
        @name = path.nil? ? 'Scratchpad' : ::File.basename(path)
        self.path = ::File.expand_path(path) unless path.nil?
        @top_pixel = 0
        @selection_count = 0
        @selection = Point.new(0, 0 + @selection_count)
        read_dirty_content = path.nil? ? '' : ::File.read(path)
        begin
          # test read dirty content
          read_dirty_content.split("\n")
          observe(self, :dirty_content) do
            lines_text_size = lines.size.to_s.size
            self.line_numbers_content = lines.size.times.map {|n| (' ' * (lines_text_size - (n+1).to_s.size)) + (n+1).to_s }.join("\n")
          end
          @line_number = 1
          self.dirty_content = read_dirty_content
          observe(self, :selection) do
            self.line_number = line_index_for_caret_position(caret_position) + 1
          end
          observe(self, :line_number) do
            if line_number
              line_index = line_number - 1
              new_caret_position = caret_position_for_line_index(line_index)
              self.caret_position = new_caret_position unless self.caret_position && line_index_for_caret_position(new_caret_position) == line_index_for_caret_position(caret_position)
            end
          end
        rescue
          # no op in case of a binary file
        end
      end

      def path=(the_path)
        the_path = nil if the_path&.strip&.empty?
        @path = the_path
        generate_display_path
      end

      def generate_display_path
        return if @path.nil?
        @display_path = @path.sub(project_dir.path, '').sub(/^\//, '')
      end

      def backup_properties
        [:find_text, :replace_text, :case_sensitive, :top_pixel, :caret_position, :selection_count].reduce({}) do |hash, property|
          hash.merge(property => send(property))
        end
      end

      def restore_properties(properties_hash)
        return if properties_hash[:caret_position] == 0 && properties_hash[:selection_count] == 0 && properties_hash[:find_text].nil? && properties_hash[:replace_text].nil? && properties_hash[:top_pixel] == 0 && properties_hash[:case_sensitive].nil?
        properties_hash.each do |property, value|
          send("#{property}=", value)
        end
      end

      # to use for widget data-binding
      def content=(value)
        value = value.gsub("\t", '  ')
        if dirty_content != value
          Command.do(self) # record a native (OS-widget) operation
          self.dirty_content = value
        end
      end

      def content
        dirty_content
      end

      def caret_position=(value)
        old_top_pixel = top_pixel
        self.selection = Point.new(value, value + selection_count.to_i)
        self.top_pixel = old_top_pixel
      end

      def caret_position
        selection.x
      end

      def selection_count
        selection.y - selection.x
      end

      def selection_count=(value)
        self.selection = Point.new(caret_position, caret_position + value.to_i)
      end

      def name=(the_name)
        new_path = path.sub(/#{Regexp.escape(@name)}$/, the_name) unless path.nil?
        @name = the_name
        if !path.nil? && ::File.exist?(path)
          FileUtils.mv(path, new_path)
          self.path = new_path
        end
      end

      def dirty_content=(the_content)
        @dirty_content = the_content
        notify_observers(:content)
      end

      def start_filewatcher
        return if @path.nil?
        @filewatcher = Filewatcher.new(@path)
        @thread = Thread.new(@filewatcher) do |fw|
          fw.watch do |filename, event|
            begin
              read_dirty_content = ::File.read(path)
              # test read dirty content
              read_dirty_content.split("\n")
              async_exec do
                self.dirty_content = read_dirty_content if read_dirty_content != dirty_content
              end
            rescue
              # no op in case of a binary file
            end
          end
        end
      end

      def stop_filewatcher
        @filewatcher&.stop
      end

      def format_dirty_content_for_writing!
        new_dirty_content = "#{dirty_content.gsub("\r\n", "\n").gsub("\r", "\n").sub(/\n+\z/, '')}\n"
        new_dirty_content = new_dirty_content.split("\n").map {|line| line.strip.empty? ? line : line.rstrip }.join("\n")
        self.dirty_content = new_dirty_content if new_dirty_content != self.dirty_content
      end

      def write_dirty_content
        return if path.nil? || !::File.exist?(path)
        format_dirty_content_for_writing!
        ::File.write(path, dirty_content) if ::File.exists?(path)
      rescue => e
        puts "Error in writing dirty content for #{path}"
        puts e.full_message
      end

      def write_raw_dirty_content
        return if path.nil? || !::File.exist?(path)
        ::File.write(path, dirty_content) if ::File.exists?(path)
      rescue => e
        puts "Error in writing raw dirty content for #{path}"
        puts e.full_message
      end

      def current_line_indentation
        current_line.to_s.match(/^(\s+)/).to_a[1].to_s
      end

      def current_line
        lines[line_number - 1]
      end

      def delete!
        FileUtils.rm(path) unless path.nil?
      end

      def prefix_new_line!
        the_lines = lines
        the_lines[line_number-1...line_number-1] = [current_line_indentation]
        self.dirty_content = the_lines.join("\n")
        self.caret_position = caret_position_for_line_index(line_number-1) + current_line_indentation.size
        self.selection_count = 0
      end

      def insert_new_line!
        the_lines = lines
        the_lines[line_number...line_number] = [current_line_indentation]
        self.dirty_content = the_lines.join("\n")
        self.caret_position = caret_position_for_line_index(line_number) + current_line_indentation.size
        self.selection_count = 0
      end

      def comment_line!
        old_lines = lines
        return if old_lines.size < 1
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
        old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        new_lines = lines
        delta = 0
        line_indices_for_selection(caret_position, selection_count).reverse.each do | the_line_index |
          delta = 0
          the_line = old_lines[the_line_index]
          return if the_line.nil?
          if the_line.strip.start_with?('# ')
            new_lines[the_line_index] = the_line.sub(/# /, '')
            delta -= 2
          elsif the_line.strip.start_with?('#')
            new_lines[the_line_index] = the_line.sub(/#/, '')
            delta -= 1
          else
            new_lines[the_line_index] = "# #{the_line}"
            delta += 2
          end
        end
        self.dirty_content = new_lines.join("\n")
        if old_selection_count.to_i > 0
          self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
          self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
        else
          new_caret_position = old_caret_position + delta
          new_caret_position = [new_caret_position, old_caret_position_line_caret_position].max
          self.caret_position = new_caret_position
        end
      end

      def indent!
        new_lines = lines
        old_lines = lines
        return if old_lines.size < 1
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
        old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        delta = 2
        line_indices_for_selection(caret_position, selection_count).each do |the_line_index|
          the_line = old_lines[the_line_index]
          new_lines[the_line_index] = "  #{the_line}"
        end
        old_caret_position = self.caret_position
        self.dirty_content = new_lines.join("\n")
        if old_selection_count.to_i > 0
          self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
          self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
        else
          self.caret_position = old_caret_position + delta
        end
      end

      def outdent!
        new_lines = lines
        old_lines = lines
        return if old_lines.size < 1
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
        old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        delta = 0
        line_indices_for_selection(caret_position, selection_count).each do |the_line_index|
          the_line = old_lines[the_line_index]
          if the_line.to_s.start_with?('  ')
            new_lines[the_line_index] = the_line.sub(/  /, '')
            delta = -2
          elsif the_line&.start_with?(' ')
            new_lines[the_line_index] = the_line.sub(/ /, '')
            delta = -1
          end
        end
        self.dirty_content = new_lines.join("\n")
        if old_selection_count.to_i > 0
          self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
          self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
        else
          new_caret_position = old_caret_position + delta
          new_caret_position = [new_caret_position, old_caret_position_line_caret_position].max
          self.caret_position = new_caret_position
        end
      end

      def kill_line!
        new_lines = lines
        return if new_lines.size < 1
        line_indices = line_indices_for_selection(caret_position, selection_count)
        new_lines = new_lines[0...line_indices.first] + new_lines[(line_indices.last+1)...new_lines.size]
        old_caret_position = self.caret_position
        old_line_index = self.line_number - 1
        line_position = line_position_for_caret_position(old_caret_position)
        self.dirty_content = "#{new_lines.join("\n")}\n"
        self.caret_position = caret_position_for_line_index(old_line_index) + [line_position, lines[old_line_index].to_s.size].min
        self.selection_count = 0
      end

      def duplicate_line!
        new_lines = lines
        old_lines = lines
        return if old_lines.size < 1
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
        old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position_line_index)
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        the_line_indices = line_indices_for_selection(caret_position, selection_count)
        the_lines = lines_for_selection(caret_position, selection_count)
        delta = the_lines.join("\n").size + 1
        the_lines.each_with_index do |the_line, i|
          new_lines.insert(the_line_indices.first + i, the_line)
        end
        self.dirty_content = new_lines.join("\n")
        if old_selection_count.to_i > 0
          self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
          self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
        else
          self.caret_position = old_caret_position + delta
        end
      end

      def find_next
        return if find_text.to_s.empty?
        all_lines = lines
        the_line_index = line_index_for_caret_position(caret_position)
        line_position = line_position_for_caret_position(caret_position)
        found = found_text?(caret_position)
        2.times do |i|
          rotation = the_line_index
          all_lines.rotate(rotation).each_with_index do |the_line, the_index|
            the_index = (the_index + rotation)%all_lines.size
            start_position = 0
            start_position = line_position + find_text.to_s.size if i == 0 && the_index == the_line_index && found_text?(caret_position)
            text_to_find_in = the_line[start_position..-1]
            occurrence_index = case_sensitive ? text_to_find_in&.index(find_text.to_s) : text_to_find_in&.downcase&.index(find_text.to_s.downcase)
            if occurrence_index
              self.caret_position = caret_position_for_line_index(the_index) + start_position + occurrence_index
              self.selection_count = find_text.to_s.size
              return
            end
          end
        end
      end

      def find_previous
        return if find_text.to_s.empty?
        all_lines = lines
        the_line_index = line_index_for_caret_position(caret_position)
        line_position = line_position_for_caret_position(caret_position)
        2.times do |i|
          rotation = - the_line_index - 1 + all_lines.size
          all_lines.reverse.rotate(rotation).each_with_index do |the_line, the_index|
            the_index = all_lines.size - 1 - (the_index + rotation)%all_lines.size
            if the_index == the_line_index
              start_position = i > 0 ? 0 : (the_line.size - line_position)
            else
              start_position = 0
            end
            text_to_find_in = the_line.downcase.reverse[start_position...the_line.size].to_s
            occurrence_index = text_to_find_in.index(find_text.to_s.downcase.reverse)
            if occurrence_index
              self.caret_position = caret_position_for_line_index(the_index) + (the_line.size - (start_position + occurrence_index + find_text.to_s.size))
              self.selection_count = find_text.to_s.size
              return
            end
          end
        end
      end

      def ensure_find_next
        return if find_text.to_s.empty? || dirty_content.to_s.strip.size < 1
        find_next unless found_text?(self.caret_position)
      end

      def found_text?(caret_position)
        dirty_content[caret_position.to_i, find_text.to_s.size].to_s.downcase == find_text.to_s.downcase
      end

      def replace_next!
        return if find_text.to_s.empty? || dirty_content.to_s.strip.size < 1
        ensure_find_next
        new_dirty_content = dirty_content
        new_dirty_content[caret_position, find_text.size] = replace_text.to_s
        self.dirty_content = new_dirty_content
        find_next
        find_next if replace_text.to_s.include?(find_text) && !replace_text.to_s.start_with?(find_text)
      end
      
      def page_up
        self.selection_count = 0
        self.line_number = [(self.line_number - 15), 1].max
      end

      def page_down
        self.selection_count = 0
        self.line_number = [(self.line_number + 15), lines.size].min
      end

      def home
        self.selection_count = 0
        self.line_number = 1
      end

      def end
        self.selection_count = 0
        self.line_number = lines.size
      end

      def start_of_line
        self.caret_position = caret_position_for_line_index(self.line_number - 1)
      end

      def end_of_line
        self.caret_position = caret_position_for_line_index(self.line_number) - 1
      end

      def move_up!
        old_lines = lines
        return if old_lines.size < 2
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position)
        old_caret_position_line_position = old_caret_position - old_caret_position_line_caret_position
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        new_lines = lines
        the_line_indices = line_indices_for_selection(caret_position, selection_count)
        the_lines = lines_for_selection(caret_position, selection_count)
        new_line_index = [the_line_indices.first - 1, 0].max
        new_lines[the_line_indices.first..the_line_indices.last] = []
        new_lines[new_line_index...new_line_index] = the_lines
        self.dirty_content = new_lines.join("\n")
        self.caret_position = caret_position_for_line_index(new_line_index) + [old_caret_position_line_position, new_lines[new_line_index].size].min
        self.selection_count = old_selection_count.to_i if old_selection_count.to_i > 0
      end

      def move_down!
        old_lines = lines
        return if old_lines.size < 2
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position)
        old_caret_position_line_position = old_caret_position - old_caret_position_line_caret_position
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        new_lines = lines
        the_line_indices = line_indices_for_selection(caret_position, selection_count)
        the_lines = lines_for_selection(caret_position, selection_count)
        new_line_index = [the_line_indices.first + 1, new_lines.size - 1].min
        new_lines[the_line_indices.first..the_line_indices.last] = []
        new_lines[new_line_index...new_line_index] = the_lines
        self.dirty_content = new_lines.join("\n")
        self.caret_position = caret_position_for_line_index(new_line_index) + [old_caret_position_line_position, new_lines[new_line_index].size].min
        self.selection_count = old_selection_count.to_i if old_selection_count.to_i > 0
      end

      def lines
        dirty_content.split("\n")
      end

      def line_for_caret_position(caret_position)
        lines[line_index_for_caret_position(caret_position.to_i)]
      end

      def line_index_for_caret_position(caret_position)
        dirty_content[0...caret_position.to_i].count("\n")
      end

      def caret_position_for_line_index(line_index)
        cp = lines[0...line_index].join("\n").size
        cp += 1 if line_index > 0
        cp
      end

      def caret_position_for_caret_position_start_of_line(caret_position)
        caret_position_for_line_index(line_index_for_caret_position(caret_position))
      end

      # position within line containing "caret position" (e.g. for caret position 5 in 1st line, they match as 5, for 15 in line 2 with line 1 having 10 characters, line position is 4)
      # TODO consider renaming to line_character_position_for_caret_position
      def line_position_for_caret_position(caret_position)
        caret_position = caret_position.to_i
        caret_position - caret_position_for_caret_position_start_of_line(caret_position)
      end

      def line_caret_positions_for_selection(caret_position, selection_count)
        line_indices = line_indices_for_selection(caret_position, selection_count)
        line_caret_positions = line_indices.map { |line_index| caret_position_for_line_index(line_index) }.to_a
      end

      def end_caret_position_line_index(caret_position, selection_count)
        end_caret_position = caret_position + selection_count.to_i
        end_caret_position -= 1 if dirty_content[end_caret_position - 1] == "\n"
        end_line_index = line_index_for_caret_position(end_caret_position)
      end

      def lines_for_selection(caret_position, selection_count)
        line_indices = line_indices_for_selection(caret_position, selection_count)
        lines[line_indices.first..line_indices.last]
      end

      def line_indices_for_selection(caret_position, selection_count)
        start_line_index = line_index_for_caret_position(caret_position)
        if selection_count.to_i > 0
          end_line_index = end_caret_position_line_index(caret_position, selection_count)
        else
          end_line_index = start_line_index
        end
        (start_line_index..end_line_index).to_a
      end

      def children
        []
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