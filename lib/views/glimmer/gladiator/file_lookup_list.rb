# Copyright (c) 2020-2021 Andy Maleh
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
    class FileLookupList
      include Glimmer::UI::CustomWidget
  
      options :gladiator, :foreground_color
  
      body {
        list(:border, :h_scroll, :v_scroll) {
          selection bind(project_dir, :filtered_path)
#           visible bind(project_dir, 'filter') {|f| pd swt_widget&.get_shell&.get_data('proxy'); swt_widget&.get_shell&.get_data('proxy')&.pack_same_size; !!f}
          foreground foreground_color
          on_mouse_up {
            project_dir.selected_child_path = swt_widget.getSelection.first
          }
          on_key_pressed { |key_event|
            if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr)
              project_dir.selected_child_path = swt_widget.getSelection.first
              current_text_editor&.text_widget&.setFocus
            end
          }
          drag_source(DND::DROP_COPY) {
            transfer :text
            on_drag_set_data { |event|
              Gladiator.drag = true
              list = event.widget.getControl
              event.data = list.getSelection.first
            }
          }
        }
      }
      
      def project_dir
        gladiator.project_dir
      end
      
      def current_text_editor
        gladiator.current_text_editor
      end
  
    end
  end
end
