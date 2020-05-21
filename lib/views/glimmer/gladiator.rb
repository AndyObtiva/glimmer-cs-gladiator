begin
  require 'puts_debuggerer' if ENV['puts_debuggerer'].to_s.downcase == 'true'
rescue LoadError
  # no op
end
require 'fileutils'

require 'models/glimmer/gladiator/dir'
require 'models/glimmer/gladiator/file'

require 'views/glimmer/gladiator/text_editor'

java_import 'org.eclipse.swt.custom.TreeEditor'

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
      @display = display {
        on_event_keydown { |key_event|
          if key_event.stateMask == swt(:command) && key_event.character.chr == 'f'
            if @text_editor.text_widget.getSelectionText && @text_editor.text_widget.getSelectionText.size > 0
              @find_text.swt_widget.setText @text_editor.text_widget.getSelectionText
            end
            @find_text.swt_widget.selectAll
            @find_text.swt_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr == 'c'
            Clipboard.copy(Gladiator::Dir.local_dir.selected_child.path)
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr == 'g'
            Gladiator::Dir.local_dir.selected_child.find_previous
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr == 'w'
            @tab_folder.swt_widget.getItems.each do |tab_item|
              Dir.local_dir.selected_child_path_history.delete(tab_item.getData('file_path'))
              tab_item.getData('proxy').dispose
            end
            @tab_item = @text_editor = Dir.local_dir.selected_child = nil 
            @filter_text.swt_widget.selectAll     
            @filter_text.swt_widget.setFocus            
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character == 8721
            other_tab_items.each do |tab_item|
              Dir.local_dir.selected_child_path_history.delete(tab_item.getData('file_path'))
              tab_item.getData('proxy').dispose
            end
          elsif key_event.stateMask == swt(:command) && key_event.character.chr == 'w'
            if selected_tab_item
              Dir.local_dir.selected_child_path_history.delete(Dir.local_dir.selected_child.path)
              selected_tab_item.getData('proxy').dispose
              if selected_tab_item.nil?
                @tab_item = @text_editor = Dir.local_dir.selected_child = nil 
                @filter_text.swt_widget.selectAll     
                @filter_text.swt_widget.setFocus
              else
                @text_editor.text_widget.setFocus
              end              
            end
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr == ']'
            @tab_folder.swt_widget.setSelection([@tab_folder.swt_widget.getSelectionIndex() + 1, @tab_folder.swt_widget.getItemCount - 1].min) if @tab_folder.swt_widget.getItemCount > 0
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr == '['
            @tab_folder.swt_widget.setSelection([@tab_folder.swt_widget.getSelectionIndex() - 1, 0].max) if @tab_folder.swt_widget.getItemCount > 0
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '1'
            @tab_folder.swt_widget.setSelection(0) if @tab_folder.swt_widget.getItemCount >= 1
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '2'
            @tab_folder.swt_widget.setSelection(1) if @tab_folder.swt_widget.getItemCount >= 2
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '3'
            @tab_folder.swt_widget.setSelection(2) if @tab_folder.swt_widget.getItemCount >= 3
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '4'
            @tab_folder.swt_widget.setSelection(3) if @tab_folder.swt_widget.getItemCount >= 4
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '5'
            @tab_folder.swt_widget.setSelection(4) if @tab_folder.swt_widget.getItemCount >= 5
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '6'
            @tab_folder.swt_widget.setSelection(5) if @tab_folder.swt_widget.getItemCount >= 6
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '7'
            @tab_folder.swt_widget.setSelection(6) if @tab_folder.swt_widget.getItemCount >= 7
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '8'
            @tab_folder.swt_widget.setSelection(7) if @tab_folder.swt_widget.getItemCount >= 8
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == '9'
            @tab_folder.swt_widget.setSelection(@tab_folder.swt_widget.getItemCount - 1) if @tab_folder.swt_widget.getItemCount > 0
            @text_editor.text_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == 'g'
            Gladiator::Dir.local_dir.selected_child.find_next
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == 'l'
            @line_number_text.swt_widget.selectAll
            @line_number_text.swt_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == 'r'
            @filter_text.swt_widget.selectAll
            @filter_text.swt_widget.setFocus
          elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr == 't'
            select_tree_item unless @rename_in_progress
            @tree.swt_widget.setFocus
          elsif key_event.keyCode == swt(:esc)
            if @text_editor
              Dir.local_dir.selected_child_path = @text_editor.file.path
              @text_editor.text_widget.setFocus
            end
          end
        }
      }

      local_dir = ENV['LOCAL_DIR'] || '.'
      @config_file_path = ::File.join(local_dir, '.gladiator')
      @config = {}
      Gladiator::Dir.local_dir.all_children # pre-caches children
    }

    ## Uncomment after_body block to setup observers for widgets in body
    #
    after_body {
      observe(Gladiator::Dir.local_dir, 'children') do
        select_tree_item unless @rename_in_progress
      end
      observe(Gladiator::Dir.local_dir, 'selected_child') do
        select_tree_item unless @rename_in_progress
        selected_file = Gladiator::Dir.local_dir.selected_child
        found_tab_item = selected_tab_item
        if found_tab_item
          @tab_folder.swt_widget.setSelection(found_tab_item)
          @tab_item = found_tab_item.getData('tab_item')
          @text_editor = found_tab_item.getData('text_editor')
        elsif selected_file
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
            @tab_item.swt_tab_item.setData('proxy', @tab_item)
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
        on_shell_deactivated {
          @text_editor&.file&.write_dirty_content
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
                  key_event.keyCode == swt(:arrow_up) ||
                  key_event.keyCode == swt(:arrow_down)
                @list.swt_widget.select(0) if @list.swt_widget.getSelectionIndex() == -1
                @list.swt_widget.setFocus
              end
            }    
          }
          composite {
            layout_data(:fill, :fill, true, true)
            @list = list(:border, :h_scroll, :v_scroll) {
              layout_data(:fill, :fill, true, true) {
                #exclude bind(Gladiator::Dir.local_dir, :filter) {|f| !f}
                minimum_height 400
              }
              #visible bind(Gladiator::Dir, 'local_dir.filter') {|f| !!f}
              selection bind(Gladiator::Dir.local_dir, :filtered_path)
              on_mouse_up {
                Gladiator::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
              }
              on_key_pressed { |key_event|
                if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr)
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
              menu {
                @open_menu_item = menu_item {
                  text 'Open'
                  on_widget_selected {
                    Gladiator::Dir.local_dir.selected_child_path = extract_tree_item_path(@tree.swt_widget.getSelection.first)
                  }
                }
                menu_item(:separator)
                menu_item {
                  text 'Delete'
                  on_widget_selected {
                    tree_item = @tree.swt_widget.getSelection.first
                    delete_tree_item(tree_item)
                  }
                }
                menu_item {
                  text 'Refresh'
                  on_widget_selected {
                    Gladiator::Dir.local_dir.refresh
                  }
                }
                menu_item {
                  text 'Rename'
                  on_widget_selected {
                    rename_selected_tree_item
                  }
                }
                menu_item {
                  text 'New Directory'
                  on_widget_selected {
                    add_new_directory_to_selected_tree_item
                  }
                }
                menu_item {
                  text 'New File'
                  on_widget_selected {
                    add_new_file_to_selected_tree_item
                  }
                }
              }
              on_event_menudetect { |event|
                path = extract_tree_item_path(@tree.swt_widget.getSelection.first)
                @open_menu_item.swt_widget.setEnabled(!::Dir.exist?(path)) if path
              }
              on_mouse_up {
                Gladiator::Dir.local_dir.selected_child_path = extract_tree_item_path(@tree.swt_widget.getSelection&.first)
                @text_editor&.text_widget&.setFocus
              }
              on_key_pressed { |key_event|
                if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr)
                  Gladiator::Dir.local_dir.selected_child_path = extract_tree_item_path(@tree.swt_widget.getSelection&.first)
                  @text_editor&.text_widget&.setFocus
                end
              }
              on_paint_control {
                root_item = @tree.swt_widget.getItems.first
                if root_item && !root_item.getExpanded
                  root_item.setExpanded(true)
                end
              }
            }
          }

          @tree_editor = TreeEditor.new(@tree.swt_widget);
          @tree_editor.horizontalAlignment = swt(:left);
          @tree_editor.grabHorizontal = true;
          @tree_editor.minimumHeight = 20;

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
        @config[:open_file_paths].to_a.each do |file_path|
          Gladiator::Dir.local_dir.selected_child_path = file_path
        end
        Gladiator::Dir.local_dir.selected_child_path = @config[:selected_child_path] if @config[:selected_child_path]
        Gladiator::Dir.local_dir.selected_child&.caret_position  = Gladiator::Dir.local_dir.selected_child&.caret_position_for_caret_position_start_of_line(@config[:caret_position].to_i) if @config[:caret_position]
        Gladiator::Dir.local_dir.selected_child&.top_index = @config[:top_index].to_i if @config[:top_index]
        body_root.on_event_show {
          swt_widget.setSize(@config[:shell_width], @config[:shell_height]) if @config[:shell_width] && @config[:shell_height]
          swt_widget.setLocation(@config[:shell_x], @config[:shell_y]) if @config[:shell_x] && @config[:shell_y]          
          @loaded_config = true
        }
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
        open_file_paths: Dir.local_dir.selected_child_path_history,
      }
      config_yaml = YAML.dump(@config)
      ::File.write(@config_file_path, config_yaml) unless config_yaml.to_s.empty?
    rescue => e
      puts e.full_message
    end
    
    def selected_tab_item
      @tab_folder.swt_widget.getItems.detect { |ti| ti.getData('file_path') == Gladiator::Dir.local_dir.selected_child&.path }
    end

    def other_tab_items
      @tab_folder.swt_widget.getItems.reject { |ti| ti.getData('file_path') == Gladiator::Dir.local_dir.selected_child&.path }
    end

    def extract_tree_item_path(tree_item)
      return if tree_item.nil?
      if tree_item.getParentItem
        ::File.join(extract_tree_item_path(tree_item.getParentItem), tree_item.getText)
      else
        Dir.local_dir.path
      end
    end
    
    def select_tree_item
      return unless Gladiator::Dir.local_dir.selected_child&.name
      tree_items_to_select = @tree.depth_first_search { |ti| ti.getData.path == Gladiator::Dir.local_dir.selected_child.path }
      @tree.swt_widget.setSelection(tree_items_to_select)
    end

    def delete_tree_item(tree_item)
      file = tree_item.getData
      parent_path = ::File.dirname(file.path)
      file.delete!
      Dir.local_dir.refresh(async: false)
      parent_tree_item = @tree.depth_first_search {|ti| ti.getData.path == parent_path}.first
      @tree.swt_widget.showItem(parent_tree_item)
      parent_tree_item.setExpanded(true)
      # TODO close text editor tab 
#       if file.is_a?(::File)
        # close tab
#       end
    end
    
    def rename_selected_tree_item
      Dir.local_dir.pause_refresh
      tree_item = @tree.swt_widget.getSelection.first
      rename_tree_item(tree_item)
    end
    
    def add_new_directory_to_selected_tree_item
      Dir.local_dir.pause_refresh
      tree_item = @tree.swt_widget.getSelection.first
      directory_path = extract_tree_item_path(tree_item)
      if !::Dir.exist?(directory_path)
        tree_item = tree_item.getParentItem
        directory_path = ::File.dirname(directory_path)
      end
      new_directory_path = ::File.expand_path(::File.join(directory_path, 'new_directory'))
      FileUtils.mkdir_p(new_directory_path)
      Dir.local_dir.refresh(async: false, force: true)
      new_tree_item = @tree.depth_first_search {|ti| ti.getData.path == new_directory_path}.first
      @tree.swt_widget.showItem(new_tree_item)
      rename_tree_item(new_tree_item, true)
    end
    
    def add_new_file_to_selected_tree_item
      Dir.local_dir.pause_refresh
      tree_item = @tree.swt_widget.getSelection.first
      directory_path = extract_tree_item_path(tree_item)
      if !::Dir.exist?(directory_path)
        tree_item = tree_item.getParentItem
        directory_path = ::File.dirname(directory_path)
      end
      new_file_path = ::File.expand_path(::File.join(directory_path, 'new_file'))
      FileUtils.touch(new_file_path)
      Dir.local_dir.refresh(async: false, force: true)
      new_tree_item = @tree.depth_first_search {|ti| ti.getData.path == new_file_path}.first
      @tree.swt_widget.showItem(new_tree_item)
      rename_tree_item(new_tree_item, true)
    end
    
    def rename_tree_item(tree_item, open_afterwards = false)
      @tree.edit_tree_item(
        tree_item,
        after_write: -> (edited_tree_item) {
          file = edited_tree_item.getData
          file_path = file.path
          # TODO rename file in tab title
          Dir.local_dir.selected_child_path = file_path if open_afterwards
          Dir.local_dir.resume_refresh            
        },
        after_cancel: -> {
          Dir.local_dir.resume_refresh            
        }
      )
    end
  end
end
