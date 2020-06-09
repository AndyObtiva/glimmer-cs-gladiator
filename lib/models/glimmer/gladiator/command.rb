module Glimmer
  class Gladiator
    class Command
      class << self
        def command_history
          @command_history ||= {}
        end
        
        def command_history_for(file)
          # keeping a first command to make redo support work by remembering next command after undoing all
          command_history[file] ||= [Command.new(file)] 
        end
        
        def do(file, method = nil, command: nil)
          command ||= Command.new(file, method)
          command_history_for(file)&.last&.next_command = command unless command_history_for(file)&.last&.next_command
          command.do
          command_history_for(file) << command
        end
        
        def undo(file)
          return if command_history_for(file).size <= 1        
          command_history_for(file).pop.undo
        end
        
        def redo(file)
          command_history_for(file).last&.redo
        end
      end
    
      attr_accessor :file, :method, :next_command, :previous_file_content, :previous_file_caret_position, :previous_file_selection_count
    
      def initialize(file, method = nil)
        @file = file
        @method = method
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
        Command.do(next_command.file, command: next_command)
      end
      
      def backup
        @previous_file_dirty_content = @file.dirty_content.clone
        @previous_file_caret_position = @file.caret_position
        @previous_file_selection_count = @file.selection_count
      end
      
      def restore
        @file.dirty_content = @previous_file_dirty_content.clone
        @file.caret_position = @previous_file_caret_position
        @file.selection_count = @previous_file_selection_count
      end
      
      def execute
        @file.send(@method)
      end
    end
  end
end
