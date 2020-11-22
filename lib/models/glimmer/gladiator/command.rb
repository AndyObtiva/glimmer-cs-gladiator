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
            command ||= Command.new(file, method, *args)
            command.previous_command = command_history_for(file).last
            unless command_history_for(file).last.method == :change_content! && method == :change_content!
              command_history_for(file).last.next_command = command
            end
            command.do
            command_history_for(file) << command unless command_history_for(file).last.method == :change_content! && method == :change_content!          
          else
            command_history_for(file) << command
          end
rescue => e
puts e.full_message
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
      end
    
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