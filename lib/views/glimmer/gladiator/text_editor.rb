module Glimmer
  class Gladiator
    class TextEditor
      include Glimmer::UI::CustomWidget

      options :file

      attr_reader :text_widget

      after_body {
        @text_widget = @text.swt_widget
      }
      
      body {
        composite {
          layout_data :fill, :fill, true, true
          grid_layout 2, false
          @line_numbers_text = text(:multi) {
            layout_data(:right, :fill, false, true)
            font name: 'Consolas', height: 15
            background color(:widget_background)
            foreground rgb(75, 75, 75)
            text bind(file, 'line_numbers_content')
            top_index bind(file, 'top_index')
            on_focus_gained {
              @text&.swt_widget.setFocus
            }
            on_key_pressed {
              @text&.swt_widget.setFocus
            }
            on_mouse_up {
              @text&.swt_widget.setFocus
            }
          }
          @text = text(:multi, :border, :h_scroll, :v_scroll) {
            layout_data :fill, :fill, true, true
            font name: 'Consolas', height: 15
            foreground rgb(75, 75, 75)
            text bind(file, 'dirty_content')
            focus true
            caret_position bind(file, 'caret_position')
            selection_count bind(file, 'selection_count')
            top_index bind(file, 'top_index')
            on_focus_lost {
              file&.write_dirty_content
            }
      	     on_key_pressed { |key_event|
              if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '/'
                file.comment_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'k'
                file.kill_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'd'
                file.duplicate_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '['
                file.outdent!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == ']'
                file.indent!
              elsif key_event.keyCode == swt(:page_up)
                file.page_up
                key_event.doit = false
              elsif key_event.keyCode == swt(:page_down)
                file.page_down
                key_event.doit = false
              elsif key_event.keyCode == swt(:home)
                file.home
                key_event.doit = false
              elsif key_event.keyCode == swt(:end)
                file.end
                key_event.doit = false
              elsif key_event.stateMask == swt(:command) && key_event.keyCode == swt(:arrow_up)
                file.move_up!
                key_event.doit = false
              elsif key_event.stateMask == swt(:command) && key_event.keyCode == swt(:arrow_down)
                file.move_down!
                key_event.doit = false
              end
            }
            on_verify_text { |verify_event|
              key_code = verify_event.keyCode
              case key_code
              when swt(:tab)
                if file.selection_count.to_i > 0
                  file.indent!
                  verify_event.doit = false
                else
                  verify_event.text = '  '
                end
              end
            }
          }
        }
      }
    end
  end
end
