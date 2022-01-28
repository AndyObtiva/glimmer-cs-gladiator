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
