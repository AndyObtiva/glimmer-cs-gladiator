module Glimmer
  class Gladiator
    class TextEditor
      include Glimmer::UI::CustomWidget

      options :file

      attr_reader :text_proxy, :text_widget

      after_body {
        @text_widget = @text.swt_widget
        @text_proxy = @text
      }
      
      body {
        composite {
          layout_data :fill, :fill, true, true
          grid_layout 2, false
          @line_numbers_text = code_text(:border, :multi) {
            layout_data(:right, :fill, false, true)
            font name: 'Consolas', height: OS.mac? ? 15 : 12
            background color(:widget_background)
            foreground rgb(75, 75, 75)
            text bind(file, 'line_numbers_content')
            top_pixel bind(file, 'top_pixel', read_only: true)
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
          
          @text = code_text {
            layout_data :fill, :fill, true, true
            font name: 'Consolas', height: OS.mac? ? 15 : 12
            foreground rgb(75, 75, 75)
            text bind(file, :content)
            focus true
            selection bind(file, :selection)
            top_pixel bind(file, :top_pixel)
            drop_target(DND::DROP_COPY) {
              transfer [TextTransfer.getInstance].to_java(Transfer)
              on_drag_enter { |event|
                event.detail = DND::DROP_COPY
              }
              on_drop { |event|
                Gladiator.drag_and_drop = true
                Dir.local_dir.selected_child = nil
                Dir.local_dir.selected_child_path = event.data
                Gladiator.drag = false
              }
            }                  
            
            on_focus_lost {
              file&.write_dirty_content
            }              
            on_verify_key { |key_event|
              if (Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'z') || (key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'y')                
                key_event.doit = !Command.redo(file)
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'r'
                Dir.local_dir.selected_child.write_dirty_content              
                begin
                  load Dir.local_dir.selected_child.path
                rescue => e
                  puts e.full_message
                end
              elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'z'
                key_event.doit = !Command.undo(file)
              elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'a'
                key_event.widget.selectAll
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
              elsif key_event.keyCode == swt(:home)
                file.home
                key_event.doit = false
              elsif key_event.keyCode == swt(:end)
                file.end
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
                if file.selection_count.to_i > 0
                  Command.do(file, :indent!)
                  verify_event.doit = false
                else
                  verify_event.text = '  '
                end
              end
            }
          }
        }
      }
      
      
      def extract_char(event)
        event.keyCode.chr
      rescue => e
        nil
      end
                                                                                                                                                                                                                                                                                                      
    end
  end
end
                                              
