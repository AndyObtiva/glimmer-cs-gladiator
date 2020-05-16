require 'models/glimmer/gladiator/dir'
require 'models/glimmer/gladiator/file'

require 'views/glimmer/gladiator/text_editor'

Clipboard.implementation = Clipboard::Java
Clipboard.copy(Clipboard.paste) # pre-initialize library to avoid slowdown during use

module Glimmer
  # Gladiator (Glimmer Editor)
  class Gladiator
    include Glimmer::UI::CustomShell

    ## Add options like the following to configure CustomShell by outside consumers
    #
    # options :title, :background_color
    # option :width, 320
    # option :height, 240

    ## Uncomment before_body block to pre-initialize variables to use in body
    #
    #
    before_body {
      Display.setAppName('Gladiator')
      local_dir = ENV['LOCAL_DIR'] || '.'
      @config_file_path = ::File.join(local_dir, '.gladiator')
      @config = {}
      Gladiator::Dir.local_dir.all_children # pre-caches children
      load_config
      @display = display {
        on_event_keydown { |key_event|
          if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'f'
            if @text_editor.text_widget.getSelectionText && @text_editor.text_widget.getSelectionText.size > 0
              @find_text.swt_widget.setText @text_editor.text_widget.getSelectionText
            end
            @find_text.swt_widget.selectAll
            @find_text.swt_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == 'c'
            Clipboard.copy(Gladiator::Dir.local_dir.selected_child.path)
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == 'g'
            Gladiator::Dir.local_dir.selected_child.find_previous
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'g'
            Gladiator::Dir.local_dir.selected_child.find_next
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'l'
            @line_number_text.swt_widget.selectAll
            @line_number_text.swt_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'r'
            @filter_text.swt_widget.selectAll
            @filter_text.swt_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 't'
            @tree.swt_widget.setFocus
          end
        }
      }
    }

    ## Uncomment after_body block to setup observers for widgets in body
    #
    after_body {
      observe(Gladiator::Dir.local_dir, 'selected_child.line_numbers_content') do
        if @last_line_numbers_content != Gladiator::Dir.local_dir.selected_child.line_numbers_content
          body_root.pack_same_size
          @last_line_numbers_content = Gladiator::Dir.local_dir.selected_child.line_numbers_content
        end
      end
      observe(Gladiator::Dir.local_dir, 'selected_child.caret_position') do
        save_config
      end
      observe(Gladiator::Dir.local_dir, 'selected_child.top_index') do
        save_config
      end     
    }

    ## Add widget content inside custom shell body
    ## Top-most widget must be a shell or another custom shell
    #
    body {
      shell {
        text "Gladiator - #{::File.expand_path(Gladiator::Dir.local_dir.path)}"
        minimum_size 720, 450
        size 1440, 900 
        grid_layout 2, false
        on_event_close {
          Gladiator::Dir.local_dir.selected_child&.write_dirty_content
        }
        on_widget_disposed {
          Gladiator::Dir.local_dir.selected_child&.write_dirty_content
        }
        composite {
          grid_layout 1, false
          layout_data(:fill, :fill, false, true) {
            width_hint 300
          }
          @filter_text = text {
            layout_data :fill, :center, true, false
            text bind(Gladiator::Dir.local_dir, 'filter')
      	    on_key_pressed { |key_event|
              if key_event.keyCode == swt(:tab) || 
                  key_event.keyCode == swt(:cr) || 
                  key_event.keyCode == swt(:lf) ||
                  key_event.keyCode == swt(:arrow_up) ||
                  key_event.keyCode == swt(:arrow_down)
                @list.swt_widget.select(0) if @list.swt_widget.getSelectionIndex() == -1
                @list.swt_widget.setFocus
              elsif key_event.keyCode == swt(:esc)
                @text_editor.text_widget.setFocus
              end
            }    
          }
          composite {
            layout_data(:fill, :fill, true, true)
            @list = list(:border, :h_scroll, :v_scroll) {
              layout_data(:fill, :fill, true, true) {
                #exclude bind(Gladiator::Dir.local_dir, :filter) {|f| !f}
              }
              #visible bind(Gladiator::Dir, 'local_dir.filter') {|f| !!f}
              selection bind(Gladiator::Dir.local_dir, :filtered_path)
              on_widget_selected {
                Gladiator::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
              }
              on_key_pressed { |key_event|
                if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr) || Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :lf)
                  Gladiator::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
                  @text_editor.text_widget.setFocus
                end
              }
            }
            @tree = tree(:virtual, :border, :h_scroll, :v_scroll) {
              layout_data(:fill, :fill, true, true) {
                #exclude bind(Gladiator::Dir.local_dir, :filter) {|f| !!f}
              }
              #visible bind(Gladiator::Dir, 'local_dir.filter') {|f| !f}
              items bind(Gladiator::Dir, :local_dir), tree_properties(children: :children, text: :display_path)
              on_widget_selected {
                Gladiator::Dir.local_dir.selected_child_path = @tree.swt_widget.getSelection.first.getText
              }
              on_key_pressed { |key_event|
                if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr) || Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :lf)
                  Gladiator::Dir.local_dir.selected_child_path = @tree.swt_widget.getSelection&.first&.getText
                  @text_editor.text_widget.setFocus
                end
              }
              on_paint_control {
                root_item = @tree.swt_widget.getItems.first
                if root_item && !root_item.getExpanded
                  root_item.setExpanded true
                end
              }
            }
          }
        }
        @editor_container = composite {
          grid_layout 1, false
          layout_data :fill, :fill, true, true
          composite {
            grid_layout 2, false
            @file_path_label = styled_text(:none) {
              layout_data(:fill, :fill, true, false) {
                horizontal_span 2
              }
              background color(:widget_background)
              editable false
              caret nil
              text bind(Gladiator::Dir.local_dir, 'selected_child.path')
              on_mouse_up {
                @file_path_label.swt_widget.selectAll
              }
              on_focus_lost {
                @file_path_label.swt_widget.setSelection(0, 0)
              }
            }
            label {
              text 'Line:'
            }
            @line_number_text = text {
              layout_data(:fill, :fill, true, false) {
                minimum_width 300
              }
              text bind(Gladiator::Dir.local_dir, 'selected_child.line_number', on_read: :to_s, on_write: :to_i)
              on_key_pressed { |key_event|
                if key_event.keyCode == swt(:cr)
                  @text_editor.text_widget.setFocus
                end
              }
            }
            label {
              text 'Find:'
            }
            @find_text = text {
              layout_data(:fill, :fill, true, false) {
                minimum_width 300
              }
              text bind(Gladiator::Dir.local_dir, 'selected_child.find_text')
              on_key_pressed { |key_event|
                if key_event.keyCode == swt(:cr)
                  Gladiator::Dir.local_dir.selected_child.find_next
                elsif key_event.keyCode == swt(:esc)
                  @text_editor.text_widget.setFocus
                end
              }
            }
            label {
              text 'Replace:'
            }
            @replace_text = text {
              layout_data(:fill, :fill, true, false) {
                minimum_width 300
              }
              text bind(Gladiator::Dir.local_dir, 'selected_child.replace_text')
              on_focus_gained {              
                Gladiator::Dir.local_dir.selected_child.ensure_find_next
              }
              on_key_pressed { |key_event|
                if key_event.keyCode == swt(:cr)
                  Gladiator::Dir.local_dir.selected_child.replace_next!
                elsif key_event.keyCode == swt(:esc)
                  @text_editor.text_widget.setFocus
                end
              }
            }
          }
          tab_folder {
            layout_data(:fill, :fill, true, true) 
            tab_item {
              text bind(Gladiator::Dir.local_dir, 'selected_child.name')
              fill_layout :horizontal
              @text_editor = text_editor
            }
          }
        }
      }
    }
  
    def load_config
      if ::File.exists?(@config_file_path)
        config_yaml = ::File.read(@config_file_path)
        return if config_yaml.to_s.strip.empty?
        @config = YAML.load(config_yaml)
        Gladiator::Dir.local_dir.selected_child_path = @config[:selected_child_path] if @config[:selected_child_path]
        Gladiator::Dir.local_dir.selected_child&.caret_position  = Gladiator::Dir.local_dir.selected_child&.caret_position_for_caret_position_start_of_line(@config[:caret_position]) if @config[:caret_position]
        Gladiator::Dir.local_dir.selected_child&.top_index = @config[:top_index] if @config[:top_index]
      end
    end
  
    def save_config
      child = Gladiator::Dir.local_dir.selected_child
      return if child.nil?
      @config = {
        selected_child_path: child.path,
        caret_position: child.caret_position,
        top_index: child.top_index,
      }
      config_yaml = YAML.dump(@config)
      ::File.write(@config_file_path, config_yaml) unless config_yaml.to_s.empty?
    rescue => e
      puts e.full_message
    end
  end
end
