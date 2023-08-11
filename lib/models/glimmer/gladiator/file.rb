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

module Glimmer
  class Gladiator
    class File
      include Glimmer

      attr_accessor :line_numbers_content, :line_number, :find_text, :replace_text, :top_pixel, :display_path, :case_sensitive, :caret_position, :selection_count, :last_caret_position, :last_selection_count, :line_position
      attr_reader :name, :path, :project_dir

      def initialize(path='', project_dir=nil)
        raise "Not a file path: #{path}" if path.nil? || (!path.empty? && !::File.file?(path))
        @project_dir = project_dir
        @command_history = []
        @name = path.empty? ? 'Scratchpad' : ::File.basename(path)
        self.path = ::File.expand_path(path) unless path.empty?
        @top_pixel = 0
        @caret_position = 0
        @selection_count = 0
        @last_selection_count = 0
        @line_number = 1
        @init = nil
      end
      
      def extension
        path.split('.').last if path.to_s.include?('.')
      end
      
      def language
        # TODO consider using Rouge::Lexer.guess_by_filename instead and perhaps guess_by_source when it fails
        return 'ruby' if scratchpad?
        return 'ruby' if path.to_s.end_with?('Gemfile') || path.to_s.end_with?('Rakefile')
        return 'ruby' if dirty_content.start_with?('#!/usr/bin/env ruby') || dirty_content.start_with?('#!/usr/bin/env jruby')
        return 'yaml' if path.to_s.end_with?('Gemfile.lock')
        return 'shell' if extension.nil? && path.to_s.include?('/bin/')
        return 'make' if path.to_s.end_with?('Makefile') || path.to_s.end_with?('makefile') || path.to_s.end_with?('GNUmakefile')
        case extension
        # TODO extract case statement to an external config file
        when 'c', 'h'
          'c'
        when 'cpp', 'cc', 'C', 'cxx', 'c++', 'hpp', 'hh', 'H', 'hxx', 'h++'
          'cpp'
        when 'cr'
          'crystal'
        when 'cs'
          'csharp'
        when 'css'
          'css'
        when 'conf'
          'conf'
        when 'coffee'
          'coffeescript'
        when 'erb'
          'erb'
        when 'ex', 'exs'
          'eex'
        when 'feature'
          'gherkin'
        when 'gradle'
          'gradle'
        when 'haml'
          'haml'
        when 'html'
          'html'
        when 'ini'
          'ini'
        when 'java'
          'java'
        when 'js', 'cjs', 'mjs', 'es6', 'es'
          'javascript'
        when 'json'
          'json'
        when 'jsp'
          'jsp'
        when 'jsx'
          'jsx'
        when 'kt', 'ktm', 'kts'
          'kotlin'
        when 'md', 'markdown'
          'markdown'
        when 'patch'
          'diff'
        when 'pl'
          'perl'
        when 'plist'
          'plist'
        when 'pp'
          'puppet'
        when 'properties'
          'properties'
        when 'ps'
          'postscript'
        when 'ps1'
          'powershell'
        when 'py'
          'python'
        when 'rs'
          'rust'
        when 'rb', 'rake'
          'ruby'
        when 'sass'
          'sass'
        when 'scm', 'sps', 'sls', 'sld'
          'scheme'
        when 'scss'
          'scss'
        when 'sh'
          'shell'
        when 'sql'
          'sql'
        when 'tcl'
          'tcl'
        when 'ts'
          'typescript'
        when 'tsx'
          'tsx'
        when 'txt', nil
          'plain_text'
        when 'yaml', 'yml'
          'yaml'
        when 'xml'
          'xml'
        else
          'plain_text'
        end
      end
      
      def single_line_comment_prefix
        case extension
        when 'c', 'h',
             'cpp', 'cc', 'C', 'cxx', 'c++', 'hpp', 'hh', 'H', 'hxx', 'h++',
             'cs',
             'gradle',
             'java',
             'js', 'cjs', 'mjs', 'es6', 'es',
             'jsx',
             'kt', 'ktm', 'kts',
             'rs',
             'ts',
             'tsx',
             'sass',
             'scss'
          '//'
        when 'cr',
             'conf',
             'coffee',
             'ex', 'exs',
             'feature',
             'ini',
             'pl',
             'pp',
             'properties',
             'ps1',
             'py',
             'rb', 'rake',
             'sh',
             'tcl',
             'yaml', 'yml'
          '#'
        when 'css'
          '/*'
        when 'erb',
             'html',
             'jsp',
             'plist',
             'xml'
          # TODO in the future, have .erb support `#` single line comment inside Ruby code scriptlets as opposed to scriptlet-free code
          '<!--'
        when 'haml'
          '/'
        when 'md', 'markdown'
          '<!---'
        when 'ps'
          '%'
        when 'scm', 'sps', 'sls', 'sld'
          ';'
        when 'sql'
          '--'
        when 'json',
             'patch',
             'txt',
             nil
          nil
        else
          '#'
        end
      end
      
      # TODO support: def single_line_comment_postfix
      
      def init_content
        unless @init
          @init = true
          begin
            # test read dirty content
            observe(self, :dirty_content) do
              line_count = lines.empty? ? 1 : lines.size
              lines_text_size = [line_count.to_s.size, 4].max
              old_top_pixel = top_pixel
              self.line_numbers_content = line_count.times.map {|n| (' ' * (lines_text_size - (n+1).to_s.size)) + (n+1).to_s }.join("\n")
              self.top_pixel = old_top_pixel
            end
            the_dirty_content = read_dirty_content
            the_dirty_content.split("\n") # test that it is not a binary file (crashes to rescue block otherwise)
            self.dirty_content = the_dirty_content
            observe(self, :caret_position) do |new_caret_position|
              update_line_number_from_caret_position(new_caret_position)
            end
            observe(self, :line_number) do |new_line_number|
              line_index = line_number - 1
              new_caret_position = caret_position_for_line_index(line_index)
              current_caret_position = caret_position
              line_index_for_new_caret_position = line_index_for_caret_position(new_caret_position)
              line_index_for_current_caret_position = line_index_for_caret_position(current_caret_position)
              self.caret_position = new_caret_position unless (current_caret_position && line_index_for_new_caret_position == line_index_for_current_caret_position)
            end
          rescue # in case of a binary file
            stop_filewatcher
          end
        end
      end
      
      def update_line_number_from_caret_position(new_caret_position)
        new_line_number = line_index_for_caret_position(caret_position) + 1
        current_line_number = line_number
        unless (current_line_number && current_line_number == new_line_number)
          self.line_number = new_line_number
          # TODO check if the following line is needed
        end
        self.line_position = caret_position - caret_position_for_line_index(line_number - 1) + 1
      end
      
      def path=(the_path)
        @path = the_path
        generate_display_path
      end

      def generate_display_path
        return if @path.empty?
        @display_path = @path.sub(project_dir.path, '').sub(/^\//, '')
      end

      def name=(the_name)
        new_path = path.sub(/#{Regexp.escape(@name)}$/, the_name) unless scratchpad?
        @name = the_name
        if !scratchpad? && ::File.exist?(path)
          FileUtils.mv(path, new_path)
          self.path = new_path
        end
      end
      
      def scratchpad?
        path.to_s.empty? # TODO consider updating to set the .gladiator-scratchpad path directly
      end
      
      def scratchpad_file
        scratchpad_file = ::File.join(project_dir.path, '.gladiator-scratchpad')
        ::File.write(scratchpad_file, content)
        scratchpad_file
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
      
      def caret_position=(value)
        @last_caret_position = @caret_position
        @caret_position = value
      end

      def selection_count=(value)
        #@last_selection_count = @selection_count
        @selection_count = value
        @last_selection_count = @selection_count
      end

      def dirty_content
        init_content
        @dirty_content
      end
      
      def dirty_content=(the_content)
        # TODO set partial dirty content by line(s) for enhanced performance
        @dirty_content = the_content
        old_caret_position = caret_position
        old_top_pixel = top_pixel
        
        notify_observers(:content)
        if @formatting_dirty_content_for_writing
          self.caret_position = old_caret_position
          self.top_pixel = old_top_pixel
        end
      end
      
      def content
        dirty_content
      end

      # to use for widget data-binding
      def content=(value)
        value = value.gsub("\t", '  ')
        if dirty_content != value
          Command.do(self, :change_content!, value)
        end
      end
      
      def change_content!(value)
        self.dirty_content = value
        format_dirty_content_for_writing!(force: true) if value.to_s.include?("\r\n")
        update_line_number_from_caret_position(caret_position)
      end

      def start_command
        @commmand_in_progress = true
      end
      
      def end_command
        @commmand_in_progress = false
      end
      
      def command_in_progress?
        @commmand_in_progress
      end
      
      def close
        @closed = true
        stop_filewatcher
        remove_all_observers
        initialize(path, project_dir)
        Command.clear(self)
      end
      
      def closed?
        @closed
      end
      
      def read_dirty_content
        path.empty? ? '' : ::File.read(path)
      end

      def start_filewatcher
        return if scratchpad?
        @filewatcher ||= Filewatcher.new(@path)
        @filewatcher_thread ||= Thread.new(@filewatcher) do |fw|
          fw.watch do |filename, event|
            async_exec do
              begin
                self.dirty_content = read_dirty_content if read_dirty_content != dirty_content
              rescue StandardError, Errno::ENOENT
                # in case of a binary file
                stop_filewatcher
              end
            end
          end
        end
      end

      def stop_filewatcher
        @filewatcher&.stop
        @filewatcher_thread&.kill
        @filewatcher_thread = nil
        @filewatcher&.finalize
        @filewatcher = nil
      end

      def write_dirty_content
        # TODO write partial dirty content by line(s) for enhanced performance
        return if scratchpad? || !::File.exist?(path) || !::File.exists?(path) || read_dirty_content == dirty_content
        format_dirty_content_for_writing!
        ::File.write(path, dirty_content)
      rescue StandardError, ArgumentError => e
        puts "Error in writing dirty content for #{path}"
        puts e.full_message
      end

      def format_dirty_content_for_writing!(force: false)
        return if !force && @commmand_in_progress
        new_dirty_content = dirty_content.to_s.split("\n").map {|line| line.strip.empty? ? line : line.rstrip }.join("\n")
        new_dirty_content = "#{new_dirty_content.gsub("\r\n", "\n").gsub("\r", "\n").sub(/\n+\z/, '')}\n"
        if new_dirty_content != self.dirty_content
          @formatting_dirty_content_for_writing = true
          caret_position_diff = dirty_content.to_s.size - new_dirty_content.size
          self.dirty_content = new_dirty_content
          self.caret_position = caret_position - caret_position_diff
          @formatting_dirty_content_for_writing = false
        end
      end

      def write_raw_dirty_content
        return if scratchpad? || !::File.exist?(path)
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

      def remove!
        FileUtils.rm_rf(path) unless scratchpad?
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
          if the_line.strip.start_with?("#{single_line_comment_prefix} ")
            new_lines[the_line_index] = the_line.sub(/#{single_line_comment_prefix} /, '')
            # TODO single_line_comment_postfix if needed
            delta -= 2
          elsif the_line.strip.start_with?(single_line_comment_prefix)
            new_lines[the_line_index] = the_line.sub(/#{single_line_comment_prefix}/, '')
            # TODO single_line_comment_postfix if needed
            delta -= 1
          else
            new_lines[the_line_index] = "#{single_line_comment_prefix} #{the_line}"
            # TODO single_line_comment_postfix if needed
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
          self.selection_count = 0
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
          self.selection_count = 0
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
          self.selection_count = 0
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
          self.selection_count = 0
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
        write_dirty_content
      end
      
      def page_up
        self.line_number = [(self.line_number - 15), 1].max
        self.selection_count = 0
      end

      def page_down
        self.line_number = [(self.line_number + 15), lines.size].min
        self.selection_count = 0
      end

      def home
        self.line_number = 1
        self.selection_count = 0
      end

      def end
        self.line_number = lines.size
        self.selection_count = 0
      end

      def start_of_line
        self.caret_position = caret_position_for_line_index(self.line_number - 1)
        self.selection_count = 0
      end

      def end_of_line
        self.caret_position = caret_position_for_line_index(self.line_number) - 1
        self.selection_count = 0
      end

      def select_to_start_of_line
        old_caret_position = caret_position
        self.caret_position = caret_position_for_line_index(self.line_number - 1)
        self.selection_count = old_caret_position - caret_position
      end

      def select_to_end_of_line
        self.caret_position = selection_count == 0 ? caret_position : caret_position + selection_count
        self.selection_count = (caret_position_for_line_index(self.line_number) - 1) - caret_position
      end

      # deletes content that is highlighted
      def delete!
        new_dirty_content = dirty_content
        new_dirty_content[caret_position...(caret_position + selection_count)] = ''
        old_caret_position = caret_position
        self.dirty_content = new_dirty_content
        self.caret_position = old_caret_position
      end

      def cut!
        Clipboard.copy(selected_text)
        delete!
      end

      def copy
        Clipboard.copy(selected_text)
      end

      def paste!
        new_dirty_content = dirty_content
        pasted_text = Clipboard.paste
        new_dirty_content[caret_position...(caret_position + selection_count)] = pasted_text
        old_caret_position = caret_position
        self.dirty_content = new_dirty_content
        self.caret_position = old_caret_position + pasted_text.to_s.size
        self.selection_count = 0
      end

      def select_all
        self.caret_position = 0
        self.selection_count = dirty_content.to_s.size
      end

      def selected_text
        dirty_content.to_s[caret_position, selection_count]
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
      
      def run
        if scratchpad?
          load scratchpad_file
        else
          write_dirty_content
          load path
        end
      end
      
      def lines
        need_padding = dirty_content.to_s.end_with?("\n")
        splittable_content = need_padding ? "#{dirty_content} " : dirty_content
        the_lines = splittable_content.split("\n")
        the_lines[-1] = the_lines[-1].strip if need_padding
        the_lines
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
