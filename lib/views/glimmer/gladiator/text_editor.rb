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
    class TextEditor
      include Glimmer::UI::CustomWidget

      options :file, :project_dir

      attr_reader :text_proxy
      
      before_body {
        @font_name = display.get_font_list(nil, true).map(&:name).include?('Consolas') ? 'Consolas' : 'Courier'
      }
      
      after_body {
        load_content
      }
      
      body {
        composite {
          grid_layout(2, false)
          
          @line_numbers_text = styled_text(:multi, :border) {
            layout_data(:right, :fill, false, true)
            text ' '*4
            font name: @font_name, height: OS.mac? ? 15 : 12
            background color(:widget_background)
            foreground :dark_blue
            top_margin 5
            right_margin 5
            bottom_margin 5
            left_margin 5
            editable false
            on_focus_gained {
              @text_proxy&.swt_widget.setFocus
            }
            on_key_pressed {
              @text_proxy&.swt_widget.setFocus
            }
            on_mouse_up {
              @text_proxy&.swt_widget.setFocus
            }
          }
          
          @text_proxy = code_text(language: file.language) {
            layout_data :fill, :fill, true, true
            font name: @font_name, height: OS.mac? ? 15 : 12
            foreground rgb(75, 75, 75)
            focus true
            top_margin 5
            right_margin 5
            bottom_margin 5
            left_margin 5
            drop_target(DND::DROP_COPY) {
              transfer [TextTransfer.getInstance].to_java(Transfer)
              on_drag_enter { |event|
                event.detail = DND::DROP_COPY
              }
              on_drop { |event|
                Gladiator.drag_and_drop = true
                project_dir.selected_child = nil
                project_dir.selected_child_path = event.data
                Gladiator.drag = false
              }
            }
            
            on_focus_gained {
              load_content
            }
          }
        }
      }
           
      def extract_char(event)
        event.keyCode.chr
      rescue => e
        nil
      end
           
      def text_widget
        @text_proxy.swt_widget
      end
      
      def load_content
        if !@initialized && !Gladiator.startup
          load_line_numbers_text_content
          load_text_content
          @initialized = true
        end
      end
      
      def load_line_numbers_text_content
        @line_numbers_text.content {
          text bind(self, 'file.line_numbers_content')
          top_pixel bind(self, 'file.top_pixel', read_only: true)
        }
      end
  
      def load_text_content
        @text_proxy.content {
          text bind(self, 'file.content')
          selection_count bind(self, 'file.selection_count')
          caret_position bind(self, 'file.caret_position')
          top_pixel bind(self, 'file.top_pixel')
          # key_binding swt(:ctrl, :home), ST::TEXT_START
          on_focus_lost {
            file&.write_dirty_content
          }
          on_verify_key { |key_event|
            if (Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'z') || (key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'y')
              key_event.doit = !Command.redo(file)
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'z'
              key_event.doit = !Command.undo(file)
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'a'
              key_event.widget.selectAll
            elsif (OS.mac? && key_event.keyCode == swt(:home)) || (!OS.mac? && Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :ctrl) && key_event.keyCode == swt(:home))
              file.home
              key_event.doit = false
            elsif (OS.mac? && key_event.keyCode == swt(:home)) || (!OS.mac? && Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :ctrl) && key_event.keyCode == swt(:end))
              file.end
              key_event.doit = false
            elsif (OS.mac? && key_event.stateMask == swt(:ctrl) && extract_char(key_event) == 'a') || (!OS.mac? && key_event.keyCode == swt(:home))
              file.start_of_line
              key_event.doit = false
            elsif (OS.mac? && key_event.stateMask == swt(:ctrl) && extract_char(key_event) == 'e') || (!OS.mac? && key_event.keyCode == swt(:end))
              file.end_of_line
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == '/'
              Command.do(file, :comment_line!)
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'k'
              Command.do(file, :kill_line!)
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'd'
              Command.do(file, :duplicate_line!)
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == '['
              Command.do(file, :outdent!)
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == ']'
              Command.do(file, :indent!)
              key_event.doit = false
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && key_event.keyCode == swt(:cr)
              Command.do(file, :prefix_new_line!)
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && key_event.keyCode == swt(:cr)
              Command.do(file, :insert_new_line!)
              key_event.doit = false
            elsif key_event.keyCode == swt(:page_up)
              file.page_up
              key_event.doit = false
            elsif key_event.keyCode == swt(:page_down)
              file.page_down
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && key_event.keyCode == swt(:arrow_up)
              Command.do(file, :move_up!)
              key_event.doit = false
            elsif key_event.stateMask == swt(COMMAND_KEY) && key_event.keyCode == swt(:arrow_down)
              Command.do(file, :move_down!)
              key_event.doit = false
            end
          }
          on_verify_text { |verify_event|
            # TODO convert these into File commands to support Undo/Redo
            case verify_event.text
            when "\n"
              if file.selection_count.to_i == 0
                verify_event.text += file.current_line_indentation
              end
            when "\t"
              Command.do(file, :indent!)
              verify_event.doit = false
            end
          }
        }
      end
      
    end
    
  end
  
end
                                              
