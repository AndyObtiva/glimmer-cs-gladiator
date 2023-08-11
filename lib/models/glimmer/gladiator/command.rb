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
    class Command
      include Glimmer
      
      class << self
        include Glimmer
        
        def command_history
          @command_history ||= {}
        end
        
        def command_history_for(file)
          # keeping a first command to make redo support work by remembering next command after undoing all
          command_history[file] ||= [Command.new(file)]
        end
        
        def do(file, method = nil, *args, command: nil)
          if command.nil?
            command = Command.new(file, method, *args)
            command.previous_command = command_history_for(file).last
            save_new_command = command_history_for(file).last.method == :change_content! && method == :change_content! && !time_for_new_command?
            command_history_for(file).last.next_command = command unless save_new_command
            command.do
            command_history_for(file) << command unless save_new_command
          else
            command_history_for(file) << command
          end
        end
        
        def undo(file)
          return if command_history_for(file).size <= 1
          command = command_history_for(file).pop
          command&.undo
        end
        
        def redo(file)
          command = command_history_for(file).last
          command&.redo
        end
        
        def clear(file)
          command_history[file] = [Command.new(file)]
        end
        
        def time_for_new_command?
          @time ||= Time.now
          time_for_new_command = (Time.now - @time) > TIME_INTERVAL_SECONDS_NEW_COMMAND
          @time = Time.now if time_for_new_command
          time_for_new_command
        end
      end
      
      TIME_INTERVAL_SECONDS_NEW_COMMAND = (ENV['UNDO_TIME_INTERVAL_SECONDS'] || 1).to_f # seconds
    
      attr_accessor :file, :method, :args, :previous_command, :next_command,
                    :file_dirty_content, :file_caret_position, :file_selection_count, :previous_file_dirty_content, :previous_file_caret_position, :previous_file_selection_count
    
      def initialize(file, method = nil, *args)
        @file = file
        @method = method
        @args = args
      end
      
      
      def native?
        @method.nil?
      end
      
      def do
        return if native?
        backup
        execute
      end
      
      def undo
        return if native?
        restore
      end
      
      def redo
        return if next_command.nil?# || next_command.native?
        @file.dirty_content = next_command.file_dirty_content.clone
        @file.caret_position = next_command.file_caret_position
        @file.selection_count = next_command.file_selection_count
        Command.do(next_command.file, command: next_command)
      end
      
      def backup
        @previous_file_dirty_content = @file.dirty_content.clone
        @previous_file_caret_position = @file.caret_position
        @previous_file_selection_count = @file.selection_count
        if @method == :change_content!
          @previous_file_caret_position = @file.last_caret_position
          @previous_file_selection_count = @file.last_selection_count
        end
      end
      
      def restore
        @file.dirty_content = @previous_file_dirty_content.clone
        @file.caret_position = @previous_file_caret_position
        @file.selection_count = @previous_file_selection_count
      end
      
      def execute
        @file.start_command
        @file.send(@method, *@args)
        @file.end_command
        @file_dirty_content = @file.dirty_content.clone
        @file_caret_position = @file.caret_position
        @file_selection_count = @file.selection_count
        if previous_command.method == :change_content! && @method == :change_content!
          previous_command.file_dirty_content = @file_dirty_content
          previous_command.file_caret_position = @file_caret_position
          previous_command.file_selection_count = @file_selection_count
        end
      end
    end
  end
end
