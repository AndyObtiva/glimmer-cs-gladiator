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
    class GladiatorMenuBar
      include Glimmer::UI::CustomWidget
  
      options :gladiator, :editing
      
      body {
        menu_bar {
          menu {
            text '&File'
  
            menu_item {
              text 'Open &Scratchpad'
              accelerator COMMAND_KEY, :shift, :s
              enabled editing
              on_widget_selected {
                project_dir.selected_child_path = ''
              }
            }
            menu_item {
              text 'Open &Project...'
              accelerator COMMAND_KEY, :o
              on_widget_selected {
                gladiator.open_project
              }
            }
            menu_item(:separator)
            menu_item {
              text '&Quit Project'
              accelerator COMMAND_KEY, :alt, :q
              on_widget_selected {
                gladiator.save_config
                project_dir.selected_child&.write_dirty_content
                gladiator.body_root.close
              }
            }
          }
          if editing
            file_edit_menu(gladiator: gladiator)
            menu {
              text '&View'
              menu {
                text '&Split Pane'
                menu { |menu_proxy|
                  text '&Orientation'
                  menu_item(:radio) {
                    text '&Horizontal'
                    selection bind(gladiator, :split_orientation,
                                          on_read: ->(o) { gladiator.split_pane? && o == swt(:horizontal) },
                                          on_write: ->(b) { b.nil? ? nil : (b ? swt(:horizontal) : swt(:vertical)) })
                  }
                  menu_item(:radio) {
                    text '&Vertical'
                    selection bind(gladiator, :split_orientation,
                                          on_read: ->(o) { gladiator.split_pane? && o == swt(:vertical) },
                                          on_write: ->(b) { b.nil? ? nil : (b ? swt(:vertical) : swt(:horizontal)) })
                  }
                }
                menu_item(:check) {
                  text '&Maximize Pane'
                  enabled bind(gladiator, :tab_folder2)
                  accelerator COMMAND_KEY, :shift, :m
                  selection bind(gladiator, :maximized_pane)
                }
                menu_item {
                  text 'Reset &Panes'
                  enabled bind(gladiator, :tab_folder2)
                  accelerator COMMAND_KEY, :shift, :p
                  on_widget_selected {
                    if gladiator.tab_folder2
                      gladiator.maximized_pane = false
                      gladiator.tab_folder_sash_form.weights = [1, 1]
                    end
                  }
                }
                menu_item {
                  text '&Unsplit'
                  enabled bind(gladiator, :tab_folder2)
                  accelerator COMMAND_KEY, :shift, :u
                  on_widget_selected {
                    if gladiator.tab_folder2
                      gladiator.maximized_pane = false
                      gladiator.navigate_to_next_tab_folder if gladiator.current_tab_folder != gladiator.tab_folder2
                      gladiator.close_all_tabs(gladiator.tab_folder2)
                      gladiator.split_orientation = nil
                      gladiator.body_root.pack_same_size
                    end
                  }
                }
              }
              menu_item(:check) {
                text '&Maximize Editor'
                accelerator COMMAND_KEY, CONTROL_KEY, :m
                selection bind(gladiator, :maximized_editor)
              }
              menu_item {
                text '&Reset All'
                accelerator COMMAND_KEY, CONTROL_KEY, :r
                on_widget_selected {
                  gladiator.maximized_editor = false
                  gladiator.file_area_and_editor_area_sash_form.weights = [1, 5]
                  gladiator.side_bar_sash_form.weights = [1, 1]
                  unless gladiator.file_lookup_expand_item.swt_expand_item.get_expanded
                    gladiator.file_lookup_expand_item.swt_expand_item.set_expanded true
                    gladiator.file_lookup_expand_item.swt_expand_item.height = gladiator.file_lookup_expand_item_height if gladiator.file_lookup_expand_item_height
                  end
                  unless gladiator.file_explorer_expand_item.swt_expand_item.get_expanded
                    gladiator.file_explorer_expand_item.swt_expand_item.set_expanded true
                    gladiator.file_explorer_expand_item.swt_expand_item.height = gladiator.file_explorer_expand_item_height if gladiator.file_explorer_expand_item_height
                  end
                }
              }
            }
            menu {
              text '&Run'
    #             menu_item {
    #               text 'Launch Glimmer &App'
    #               on_widget_selected {
    #                 parent_path = project_dir.path
    ##                 current_directory_name = ::File.basename(parent_path)
    ##                 assumed_shell_script = ::File.join(parent_path, 'bin', current_directory_name)
    ##                 assumed_shell_script = ::Dir.glob(::File.join(parent_path, 'bin', '*')).detect {|f| ::File.file?(f) && !::File.read(f).include?('#!/usr/bin/env')} if !::File.exist?(assumed_shell_script)
    ##                 load assumed_shell_script
    #                 FileUtils.cd(parent_path) do
    #                   system 'glimmer run'
    #                 end
    #               }
    #             }
              menu_item {
                text '&Ruby'
                accelerator COMMAND_KEY, :shift, :r
                on_widget_selected {
                  begin
                    project_dir.selected_child.run
                  rescue Exception => e
                    Glimmer::Config.logger.error {e.full_message}
                    error_dialog(message: e.full_message).open
                  end
                }
              }
            }
          end
          menu {
            text '&Help'
            menu_item {
              text '&About'
              accelerator COMMAND_KEY, :shift, :a
              on_widget_selected {
                gladiator.display_about_dialog
              }
            }
          }
        }
      }
      
      def project_dir
        gladiator.project_dir
      end
      
      # Method-based error_dialog custom widget
      def error_dialog(message:)
        return if message.nil?
        dialog(gladiator) { |dialog_proxy|
          row_layout(:vertical) {
            center true
          }
          
          text 'Error Launching'
            
          styled_text(:border, :h_scroll, :v_scroll) {
            layout_data {
              width gladiator.bounds.width*0.75
              height gladiator.bounds.height*0.75
            }
            
            text message
            editable false
            caret nil
          }
          
          button {
            text 'Close'
            
            on_widget_selected {
              dialog_proxy.close
            }
          }
        }
      end
    end
    
  end
  
end
