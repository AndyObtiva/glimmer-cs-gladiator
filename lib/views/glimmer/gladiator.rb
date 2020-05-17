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
#           elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == 'w'
#             @tab_folder.swt_widget.getItems.each(&:dispose)
#           elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :alt) && key_event.character.chr.downcase == 'w'
#             @tab_folder.swt_widget.getItems.each do |ti|
#               ti.dispose unless ti == @tab_folder.swt_widget.getSelection()
#             end
#           elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'w'
#             @tab_folder.swt_widget.getSelection.each(&:dispose)
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == ']'
            @tab_folder.swt_widget.setSelection([@tab_folder.swt_widget.getSelectionIndex() + 1, @tab_folder.swt_widget.getItemCount - 1].min) if @tab_folder.swt_widget.getItemCount > 0
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == '['
            @tab_folder.swt_widget.setSelection([@tab_folder.swt_widget.getSelectionIndex() - 1, 0].max) if @tab_folder.swt_widget.getItemCount > 0
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '1'
            @tab_folder.swt_widget.setSelection(0) if @tab_folder.swt_widget.getItemCount >= 1
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '2'
            @tab_folder.swt_widget.setSelection(1) if @tab_folder.swt_widget.getItemCount >= 2
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '3'
            @tab_folder.swt_widget.setSelection(2) if @tab_folder.swt_widget.getItemCount >= 3
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '4'
            @tab_folder.swt_widget.setSelection(3) if @tab_folder.swt_widget.getItemCount >= 4
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '5'
            @tab_folder.swt_widget.setSelection(4) if @tab_folder.swt_widget.getItemCount >= 5
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '6'
            @tab_folder.swt_widget.setSelection(5) if @tab_folder.swt_widget.getItemCount >= 6
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '7'
            @tab_folder.swt_widget.setSelection(6) if @tab_folder.swt_widget.getItemCount >= 7
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '8'
            @tab_folder.swt_widget.setSelection(7) if @tab_folder.swt_widget.getItemCount >= 8
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '9'
            @tab_folder.swt_widget.setSelection(@tab_folder.swt_widget.getItemCount - 1) if @tab_folder.swt_widget.getItemCount > 0
            @text_editor.text_widget.setFocus
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
      @tree.select(text: Gladiator::Dir.local_dir.selected_child&.name) if Gladiator::Dir.local_dir.selected_child&.name
      observe(Gladiator::Dir.local_dir, 'selected_child') do
        @tree.select(text: Gladiator::Dir.local_dir.selected_child&.name)
        selected_file = Gladiator::Dir.local_dir.selected_child
        found_tab_item = @tab_folder.swt_widget.getItems.detect {|ti| ti.getData('file_path') == selected_file.path}
        if found_tab_item
          @tab_folder.swt_widget.setSelection(found_tab_item)
          @tab_item = found_tab_item.getData('tab_item')
          @text_editor = found_tab_item.getData('text_editor')
        else
          @tab_folder.content {
            @tab_item = tab_item { |the_tab_item|
              text selected_file.name
              fill_layout :horizontal
              @text_editor = the_text_editor = text_editor(file: selected_file)
              on_event_show {
                Gladiator::Dir.local_dir.selected_child = selected_file
                @tab_item = the_tab_item
                @text_editor = the_text_editor
              }
            }
            @tab_item.swt_tab_item.setData('file_path', selected_file.path)
            @tab_item.swt_tab_item.setData('tab_item', @tab_item)
            @tab_item.swt_tab_item.setData('text_editor', @text_editor)
          }                  
          @tab_folder.swt_widget.setSelection(@tab_item.swt_tab_item)
          body_root.pack_same_size
        end
      end
      observe(Gladiator::Dir.local_dir, 'selected_child') do
        save_config
      end
      observe(Gladiator::Dir.local_dir, 'selected_child.caret_position') do
        save_config
      end
      observe(Gladiator::Dir.local_dir, 'selected_child.top_index') do
        save_config
      end
      load_config
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
        on_control_resized {
          save_config
        }
        on_control_moved {
          save_config
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
              on_mouse_up {
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
              items bind(Gladiator::Dir, :local_dir), tree_properties(children: :children, text: :name)
              on_mouse_up {
                Gladiator::Dir.local_dir.selected_child_path = extract_tree_item_path(@tree.swt_widget.getSelection.first)
              }
              on_key_pressed { |key_event|
                if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr) || Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :lf)
                  Gladiator::Dir.local_dir.selected_child_path = extract_tree_item_path(@tree.swt_widget.getSelection&.first)
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
                minimum_width 400
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
                minimum_width 400
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
          @tab_folder = tab_folder {
            layout_data(:fill, :fill, true, true) 
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
        body_root.on_event_show do
          swt_widget.setSize(@config[:shell_width], @config[:shell_height]) if @config[:shell_width] && @config[:shell_height]
          swt_widget.setLocation(@config[:shell_x], @config[:shell_y]) if @config[:shell_x] && @config[:shell_y]
          @loaded_config = true
        end
      end
    end
  
    def save_config
      return unless @loaded_config
      child = Gladiator::Dir.local_dir.selected_child
      return if child.nil?
      @config = {
        selected_child_path: child.path,
        caret_position: child.caret_position,
        top_index: child.top_index,
        shell_width: swt_widget&.getBounds&.width,
        shell_height: swt_widget&.getBounds&.height,
        shell_x: swt_widget&.getBounds&.x,
        shell_y: swt_widget&.getBounds&.y,
      }
      config_yaml = YAML.dump(@config)
      ::File.write(@config_file_path, config_yaml) unless config_yaml.to_s.empty?
    rescue => e
      puts e.full_message
    end

    def extract_tree_item_path(tree_item)
      if tree_item.getParentItem
        ::File.join(extract_tree_item_path(tree_item.getParentItem), tree_item.getText)
      else
        '.'
      end
    end
  end
end
