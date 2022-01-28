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
    class FileExplorerTree
      include Glimmer::UI::CustomWidget
  
      options :gladiator, :foreground_color
      
      body {
        tree {
          #visible bind(self, 'project_dir.filter') {|f| !f}
          items bind(self, :project_dir), tree_properties(children: :children, text: :name)
          foreground foreground_color
          drag_source(:drop_copy) {
            transfer :text
            on_drag_set_data { |event|
              Gladiator.drag = true
              tree = event.widget.getControl
              tree_item = tree.getSelection.first
              event.data = tree_item.getData.path
            }
          }
          
          menu {
            @open_menu_item = menu_item {
              text 'Open'
              on_widget_selected {
                project_dir.selected_child_path = extract_tree_item_path(swt_widget.getSelection.first)
              }
            }
            menu_item(:separator)
            menu_item {
              text 'Delete'
              on_widget_selected {
                tree_item = swt_widget.getSelection.first
                delete_tree_item(tree_item)
              }
            }
            menu_item {
              text 'Refresh'
              on_widget_selected {
                project_dir.refresh
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
          
          on_swt_menudetect { |event|
            path = extract_tree_item_path(swt_widget.getSelection.first)
            @open_menu_item.swt_widget.setEnabled(!::Dir.exist?(path)) if path
          }
          on_mouse_up {
            if Gladiator.drag_and_drop
              Gladiator.drag_and_drop = false
            else
              project_dir.selected_child_path = extract_tree_item_path(swt_widget.getSelection&.first)
              gladiator.current_text_editor&.text_widget&.setFocus
            end
          }
          on_key_pressed { |key_event|
            if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr)
              project_dir.selected_child_path = extract_tree_item_path(swt_widget.getSelection&.first)
              gladiator.current_text_editor&.text_widget&.setFocus
            end
          }
          on_paint_control {
            root_item = swt_widget.getItems.first
            if root_item && !root_item.getExpanded
              root_item.setExpanded(true)
            end
          }
          
        }
      }
      
      def project_dir
        gladiator.project_dir
      end
      
      def current_text_editor
        gladiator.current_text_editor
      end
        
      def extract_tree_item_path(tree_item)
        return if tree_item.nil?
        if tree_item.getParentItem
          ::File.join(extract_tree_item_path(tree_item.getParentItem), tree_item.getText)
        else
          project_dir.path
        end
      end
  
      def select_tree_item
        return unless project_dir.selected_child&.name
        tree_items_to_select = body_root.depth_first_search { |ti| ti.getData.path == project_dir.selected_child.path }
        swt_widget.setSelection(tree_items_to_select)
      end
  
      def delete_tree_item(tree_item)
        return if tree_item.nil?
        file = tree_item.getData
        parent_path = ::File.dirname(file.path)
        if file.is_a?(Gladiator::Dir)
          file_paths = file.all_children.select {|f| f.is_a?(Gladiator::File)}.map(&:path)
          file.remove_all_observers
        else
          file_paths = [file.path]
        end
        file_paths.each do |file_path|
          found_tab_item = gladiator.find_tab_item(file_path)
          if found_tab_item
            project_dir.selected_child_path_history.delete(found_tab_item.getData('file_path'))
            found_tab_item.getData('proxy')&.dispose
          end
        end
        file.delete! # TODO consider supporting command undo/redo
        project_dir.refresh(async: false)
        parent_tree_item = body_root.depth_first_search {|ti| ti.getData.path == parent_path}.first
        swt_widget.showItem(parent_tree_item)
        parent_tree_item.setExpanded(true)
      rescue => e
        puts e.full_message
      end
  
      def add_new_directory_to_selected_tree_item
        project_dir.pause_refresh
        tree_item = swt_widget.getSelection.first
        directory_path = extract_tree_item_path(tree_item)
        return if directory_path.nil?
        if !::Dir.exist?(directory_path)
          tree_item = tree_item.getParentItem
          directory_path = ::File.dirname(directory_path)
        end
        new_directory_path = ::File.expand_path(::File.join(directory_path, 'new_directory'))
        FileUtils.mkdir_p(new_directory_path)
        project_dir.refresh(async: false, force: true)
        new_tree_item = body_root.depth_first_search {|ti| ti.getData.path == new_directory_path}.first
        swt_widget.showItem(new_tree_item)
        rename_tree_item(new_tree_item)
      end
  
      def add_new_file_to_selected_tree_item
        project_dir.pause_refresh
        tree_item = swt_widget.getSelection.first
        directory_path = extract_tree_item_path(tree_item)
        if !::Dir.exist?(directory_path)
          tree_item = tree_item.getParentItem
          directory_path = ::File.dirname(directory_path)
        end
        new_file_path = ::File.expand_path(::File.join(directory_path, 'new_file'))
        FileUtils.touch(new_file_path)
        # TODO look into refreshing only the parent directory to avoid slowdown
        project_dir.refresh(async: false, force: true)
        new_tree_item = body_root.depth_first_search {|ti| ti.getData.path == new_file_path}.first
        swt_widget.showItem(new_tree_item)
        rename_tree_item(new_tree_item, true)
      end
  
      def rename_selected_tree_item
        project_dir.pause_refresh
        tree_item = swt_widget.getSelection.first
        rename_tree_item(tree_item)
      end
  
      def rename_tree_item(tree_item, new_file = false)
        original_file = tree_item.getData
        current_file = project_dir.selected_child_path == original_file.path
        found_tab_item = gladiator.find_tab_item(original_file.path)
        found_text_editor = found_tab_item&.getData('text_editor')
        body_root.edit_tree_item(
          tree_item,
          after_write: -> (edited_tree_item) {
            file = edited_tree_item.getData
            file_path = file.path
            file.name
            if ::File.file?(file_path)
              if new_file
                project_dir.selected_child_path = file_path
              else
                found_text_editor&.file = file
                found_tab_item&.setData('file', file)
                found_tab_item&.setData('file_path', file.path)
                found_tab_item&.setText(file.name)
                if current_file
                  project_dir.selected_child_path = file_path
                else
                  gladiator.selected_tab_item&.getData('text_editor')&.text_widget&.setFocus
                end
                async_exec {
                  swt_widget.showItem(edited_tree_item)
                  gladiator.body_root.pack_same_size
                }
              end
            end
            project_dir.resume_refresh
          },
          after_cancel: -> {
            project_dir.resume_refresh
          }
        )
      end
  
    end
    
  end
  
end
