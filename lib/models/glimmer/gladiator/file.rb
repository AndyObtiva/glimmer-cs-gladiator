require 'models/glimmer/gladiator/dir'

module Glimmer
  class Gladiator
    class File
      include Glimmer
  
      attr_accessor :dirty_content, :line_numbers_content, :caret_position, :selection_count, :line_number, :find_text, :replace_text, :top_index
      attr_reader :path, :display_path
  
      def initialize(path)
        raise "Not a file path: #{path}" unless ::File.file?(path)
        @display_path = path
        @path = ::File.expand_path(path)
        read_dirty_content = ::File.read(path)
        begin
          # test read dirty content
          read_dirty_content.split("\n")
          observe(self, :dirty_content) do
            lines_text_size = lines.size.to_s.size
            self.line_numbers_content = lines.size.times.map {|n| (' ' * (lines_text_size - (n+1).to_s.size)) + (n+1).to_s }.join("\n")
          end
          self.dirty_content = read_dirty_content
          observe(self, :caret_position) do
            self.line_number = line_index_for_caret_position(caret_position) + 1
          end
          observe(self, :line_number) do
            if line_number
              new_caret_position = lines[0...(line_number.to_i - 1)].map(&:size).sum + line_number.to_i - 1
              self.caret_position = new_caret_position unless line_index_for_caret_position(new_caret_position) == line_index_for_caret_position(caret_position)
            end
          end
        rescue
          # no op in case of a binary file
        end
      end
  
      def start_filewatcher
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
  
      def write_dirty_content
        new_dirty_content = "#{dirty_content.gsub("\r\n", "\n").gsub("\r", "\n").sub(/\n+\z/, '')}\n"      
        self.dirty_content = new_dirty_content if new_dirty_content != self.dirty_content
        ::File.write(path, dirty_content) if ::File.exists?(path) && dirty_content.to_s.strip.size > 0
      end
  
      def write_raw_dirty_content
        ::File.write(path, dirty_content) if ::File.exists?(path) && dirty_content.to_s.strip.size > 0
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
        if old_selection_count > 0
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
        if old_selection_count > 0
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
          if the_line.start_with?('  ')
            new_lines[the_line_index] = the_line.sub(/  /, '')
            delta = -2
          elsif the_line.start_with?(' ')
            new_lines[the_line_index] = the_line.sub(/ /, '')
            delta = -1
          end
        end
        self.dirty_content = new_lines.join("\n")   
        if old_selection_count > 0
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
        return if new_lines.size < 2
        line_indices = line_indices_for_selection(caret_position, selection_count)
        new_lines = new_lines[0...line_indices.first] + new_lines[(line_indices.last+1)...new_lines.size]
        old_caret_position = self.caret_position
        self.dirty_content = new_lines.join("\n")
        self.caret_position = old_caret_position
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
        if old_selection_count > 0
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
        all_lines.rotate(the_line_index + 1).each_with_index do |the_line, the_index|
          the_index = (the_index + the_line_index + 1)%all_lines.size
          if the_line.downcase.include?(find_text.to_s.downcase)
            self.caret_position = the_line.downcase.index(find_text.to_s.downcase) + caret_position_for_line_index(the_index)
            self.selection_count = find_text.to_s.size
            return
          end
        end
      end
  
      def find_previous
        return if find_text.to_s.empty?
        all_lines = lines
        the_line_index = line_index_for_caret_position(caret_position)
        all_lines.rotate(the_line_index).each_with_index.map do |the_line, the_index|
          the_index = (the_index + the_line_index)%all_lines.size
          [the_line, the_index]
        end.reverse.each do |the_line, the_index|
          if the_line.downcase.include?(find_text.to_s.downcase)
            self.caret_position = the_line.downcase.index(find_text.to_s.downcase) + caret_position_for_line_index(the_index)
            self.selection_count = find_text.to_s.size
            return
          end
        end
      end
  
      def ensure_find_next
        return if find_text.to_s.empty? || dirty_content.to_s.strip.size < 1
        find_next unless dirty_content[caret_position.to_i, find_text.to_s.size] == find_text
      end
  
      def replace_next!
        return if find_text.to_s.empty? || dirty_content.to_s.strip.size < 1
        ensure_find_next
        new_dirty_content = dirty_content
        new_dirty_content[caret_position, find_text.size] = replace_text.to_s
        self.dirty_content = new_dirty_content
        find_next
      end
  
      def page_up
        self.line_number = [(self.line_number - 15), 1].max
      end
  
      def page_down
        self.line_number = [(self.line_number + 15), lines.size].min
      end
  
      def home
        self.line_number = 1
      end
  
      def end
        self.line_number = lines.size
      end
  
      def move_up!
        old_lines = lines
        return if old_lines.size < 2
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
        old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position_line_index)
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        new_lines = lines
        the_line_indices = line_indices_for_selection(caret_position, selection_count)
        the_lines = lines_for_selection(caret_position, selection_count)
        new_line_index = [the_line_indices.first - 1, 0].max
        delta = -1 * (new_lines[new_line_index].size + 1)
        new_lines[the_line_indices.first..the_line_indices.last] = []
        new_lines[new_line_index...new_line_index] = the_lines
        self.dirty_content = new_lines.join("\n")
        if old_selection_count > 0
          self.caret_position = caret_position_for_line_index(old_caret_position_line_index) + delta
          self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position + delta)
        else
          self.caret_position = old_caret_position + delta
        end
      end
  
      def move_down!
        old_lines = lines
        return if old_lines.size < 2
        old_selection_count = self.selection_count
        old_caret_position = self.caret_position
        old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
        old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position_line_index)
        old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
        new_lines = lines
        the_line_indices = line_indices_for_selection(caret_position, selection_count)
        the_lines = lines_for_selection(caret_position, selection_count)
        new_line_index = [the_line_indices.first + 1, new_lines.size - 1].min
        delta = new_lines[new_line_index].size + 1
        new_lines[the_line_indices.first..the_line_indices.last] = []
        new_lines[new_line_index...new_line_index] = the_lines
        self.dirty_content = new_lines.join("\n")
        if old_selection_count > 0
          self.caret_position = caret_position_for_line_index(old_caret_position_line_index) + delta
          self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position + delta)
        else
          self.caret_position = old_caret_position + delta
        end
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
        lines[0...line_index].join("\n").size + 1
      end
  
      def caret_position_for_caret_position_start_of_line(caret_position)
        caret_position_for_line_index(line_index_for_caret_position(caret_position))
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
    end  
  end
end
