module Glimmer
  class Gladiator
    class FileEditMenu
      include Glimmer::UI::CustomWidget
  
      # Either receives a gladiator instance for menu bar parent or file instance for text editor parent
      options :gladiator, :file
  
      body {
        menu { |menu_proxy|
          text '&Edit' unless menu_proxy.swt_menu_item.nil? # unless used on the text editor directly

          menu_item {
            text '&Undo'
            # TODO disable if not undoable
            
            on_widget_selected {
              Command.undo(current_file)
            }
          }
          menu_item {
            text '&Redo'
            # TODO disable if not redoable
            
            on_widget_selected {
              Command.redo(current_file)
            }
          }
          menu_item(:separator)
          menu_item {
            text 'Cu&t'
            
            on_widget_selected {
              Command.do(current_file, :cut!)
            }
          }
          menu_item {
            text '&Copy'
            
            on_widget_selected {
              current_file.copy
            }
          }
          menu_item {
            text '&Paste'
            
            on_widget_selected {
              Command.do(current_file, :paste!)
            }
          }
          menu_item(:separator)
          menu_item {
            text 'Select &All'
            
            on_widget_selected {
              current_file.select_all
            }
          }
        }
      }
  
      def current_file
        file.nil? ? gladiator.project_dir.selected_child : file
      end
    end
  end
end
