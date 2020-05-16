module Glimmer
  class Gladiator
    class TextEditor
      include Glimmer::UI::CustomWidget

      attr_reader :text_widget
      
      body {
        composite {
          layout_data :fill, :fill, true, true
          grid_layout 2, false  
          @line_numbers_text = text(:multi) {
            layout_data(:right, :fill, false, true)
            font name: 'Consolas', height: 15
            background color(:widget_background)
            foreground rgb(75, 75, 75)
            text bind(Gladiator::Dir.local_dir, 'selected_child.line_numbers_content')
            top_index bind(Gladiator::Dir.local_dir, 'selected_child.top_index')
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
            text bind(Gladiator::Dir.local_dir, 'selected_child.dirty_content')
            focus true
            caret_position bind(Gladiator::Dir.local_dir, 'selected_child.caret_position')
            selection_count bind(Gladiator::Dir.local_dir, 'selected_child.selection_count')
            top_index bind(Gladiator::Dir.local_dir, 'selected_child.top_index')
            on_focus_lost {
              Gladiator::Dir.local_dir.selected_child&.write_dirty_content
            }
      	     on_key_pressed { |key_event|
              if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '/'
                Gladiator::Dir.local_dir.selected_child.comment_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'k'
                Gladiator::Dir.local_dir.selected_child.kill_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'd'
                Gladiator::Dir.local_dir.selected_child.duplicate_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '['
                Gladiator::Dir.local_dir.selected_child.outdent!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == ']'
                Gladiator::Dir.local_dir.selected_child.indent!
              elsif key_event.keyCode == swt(:page_up)
                Gladiator::Dir.local_dir.selected_child.page_up
                key_event.doit = false
              elsif key_event.keyCode == swt(:page_down)
                Gladiator::Dir.local_dir.selected_child.page_down
                key_event.doit = false
              elsif key_event.keyCode == swt(:home)
                Gladiator::Dir.local_dir.selected_child.home
                key_event.doit = false
              elsif key_event.keyCode == swt(:end)
                Gladiator::Dir.local_dir.selected_child.end
                key_event.doit = false
              elsif key_event.stateMask == swt(:command) && key_event.keyCode == swt(:arrow_up)
                Gladiator::Dir.local_dir.selected_child.move_up!
                key_event.doit = false
              elsif key_event.stateMask == swt(:command) && key_event.keyCode == swt(:arrow_down)
                Gladiator::Dir.local_dir.selected_child.move_down!
                key_event.doit = false
              end
            }
            on_verify_text { |verify_event|
              key_code = verify_event.keyCode
              case key_code
              when swt(:tab)
                if Gladiator::Dir.local_dir.selected_child.selection_count.to_i > 0
                  Gladiator::Dir.local_dir.selected_child.indent!
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
