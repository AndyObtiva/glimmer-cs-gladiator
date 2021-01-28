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

require 'fileutils'
require 'os'

require 'models/glimmer/gladiator/dir'
require 'models/glimmer/gladiator/file'
require 'models/glimmer/gladiator/command'

require 'views/glimmer/gladiator/text_editor'
require 'views/glimmer/gladiator/file_lookup_list'
require 'views/glimmer/gladiator/file_explorer_tree'
require 'views/glimmer/gladiator/gladiator_menu_bar'
require 'views/glimmer/gladiator/progress_shell'

Clipboard.implementation = Clipboard::Java
Clipboard.copy(Clipboard.paste) # pre-initialize library to avoid slowdown during use

module Glimmer
  # Gladiator (Glimmer Editor)
  class Gladiator
    include Glimmer::UI::CustomShell

    APP_ROOT = ::File.expand_path('../../../..', __FILE__)
    # TODO make sure COMMAND_KEY doesn't clash on Linux/Windows for CMD+CTRL shortcuts
    COMMAND_KEY = OS.mac? ? :command : :ctrl
    VERSION = ::File.read(::File.join(APP_ROOT, 'VERSION')).to_s.strip
    LICENSE = ::File.read(::File.join(APP_ROOT, 'LICENSE.txt')).to_s.strip
    ICON = ::File.expand_path(::File.join(APP_ROOT, 'images', 'glimmer-cs-gladiator-logo.png'))

    class << self
      attr_accessor :drag_and_drop
      attr_accessor :drag
      attr_accessor :startup
    end
    
    ## Add options like the following to configure CustomShell by outside consumers
    #
    # options :title, :background_color
    # option :width, 320
    # option :height, 240
    option :project_dir_path
    
    def project_dir
      @project_dir ||= Dir.new(project_dir_path)
    end

    def split_orientation=(value)
      @split_orientation = value
      save_config
      if @loaded_config && !split_pane? && !value.nil?
        Gladiator.drag = true
        child_path = project_dir.selected_child_path
        project_dir.selected_child = nil
        project_dir.selected_child_path = child_path
        Gladiator.drag = false
      end
      @split_orientation
    end
    
    def split_pane?
      pane_count = @tab_folder_sash_form&.children&.size
      pane_count && pane_count > 1
    end
    
    attr_reader :find_text, :filter_text, :line_number_text, :split_orientation, :tab_folder_sash_form, :side_bar_sash_form, :file_area_and_editor_area_sash_form, :file_explorer_expand_item, :file_explorer_expand_item, :file_lookup_expand_item, :file_explorer_expand_item, :file_lookup_expand_item_height, :file_explorer_expand_item_height
    attr_accessor :current_tab_item, :current_tab_folder, :current_text_editor, :tab_folder1, :tab_folder2, :maximized_pane, :maximized_editor
    alias maximized_pane? maximized_pane
    alias maximized_editor? maximized_editor

    ## Uncomment before_body block to pre-initialize variables to use in body
    #
    #
    before_body {
      # TODO consider doing loading project files after displaying the GUI instead of holding it up before
      project_dir #pre-initialize directory
      TOPLEVEL_BINDING.receiver.send(:at_exit) do
        project_dir.selected_child&.write_raw_dirty_content
      end
      Display.setAppName('Gladiator')
      Display.setAppVersion(VERSION)
      # make sure the display events are only hooked once if multiple gladiators are created
      unless defined?(@@display)
        @@display = display {
          # TODO look into why a weird java dialog comes up on about (maybe a non-issue once packaged)
          on_about {
            display_about_dialog
          }
          on_quit {
            save_config
            project_dir.selected_child&.write_dirty_content
            display.swt_display.shells.each(&:close)
          }
          on_swt_keydown { |key_event|
            focused_gladiator = display.focus_control.shell&.get_data('custom_shell')
            focused_gladiator.handle_display_shortcut(key_event) if !focused_gladiator.nil? && key_event.widget.shell == focused_gladiator&.swt_widget
          }
          on_swt_Close {
            save_config
            project_dir.selected_child&.write_dirty_content
          }
        }
      end

      @default_foreground = :dark_blue
      @split_orientation = swt(:horizontal)
      @config_file_path = ::File.join(project_dir.path, '.gladiator')
      @config = {}
      load_config_ignore_paths
#       project_dir.all_children # pre-caches children
    }

    ## Uncomment after_body block to setup observers for widgets in body
    #
    after_body {
      observe(project_dir, 'children') do
        @file_explorer_tree.select_tree_item unless Gladiator.startup
      end
      observe(project_dir, 'selected_child') do |selected_file|
        if selected_file
          if Gladiator.drag && !@tab_folder2
            self.tab_folder1 = current_tab_folder
            @tab_folder_sash_form.content {
              self.current_tab_folder = self.tab_folder2 = tab_folder {}
              @current_tab_folder.swt_widget.setData('proxy', @current_tab_folder)
            }
            body_root.pack_same_size
          end
          @file_explorer_tree.select_tree_item unless Gladiator.startup
          found_tab_item = selected_tab_item
          if found_tab_item
            @current_tab_folder.swt_widget.setSelection(found_tab_item)
            @current_tab_item = found_tab_item.getData('proxy')
            @current_text_editor = found_tab_item.getData('text_editor') unless found_tab_item.getData('text_editor').nil?
            @current_tab_folder.swt_widget.setData('selected_tab_item', @current_tab_item)
          elsif selected_file
            @current_tab_folder.content {
              @current_tab_item = tab_item { |the_tab_item|
                text selected_file.name
                fill_layout(:horizontal) {
                 margin_width 0
                 margin_height 0
                }
                tab_folder = nil
                the_text_editor = nil
                the_tab_item.content {
                  @current_text_editor = the_text_editor = text_editor(project_dir: project_dir, file: selected_file) {
                    layout_data :fill, :fill, true, true
                  }
                  @current_tab_folder.swt_widget.setData('selected_tab_item', @current_tab_item)
                  the_tab_item.swt_tab_item.setData('text_editor', @current_text_editor)
                  @current_text_editor.text_proxy.content {
                    on_focus_gained {
                      tab_folder = the_text_editor.swt_widget.getParent.getParent
                      self.current_tab_folder = tab_folder.getData('proxy')
                      @current_tab_item = the_tab_item
                      @current_text_editor = the_text_editor
                      @current_tab_folder.swt_widget.setData('selected_tab_item', @current_tab_item)
                      @current_tab_folder.swt_widget.setSelection(@current_tab_item.swt_tab_item)
                      project_dir.selected_child = @current_tab_item.swt_tab_item.getData('file')
                    }
                  }
                }
                
                on_swt_show {
                  @current_tab_item = the_tab_item
                  @current_text_editor = the_text_editor
                  self.current_tab_folder = @current_tab_item.swt_widget.getParent.getData('proxy')
                  @current_tab_folder.swt_widget.setData('selected_tab_item', @current_tab_item)
                  @current_tab_folder.swt_widget.setSelection(@current_tab_item.swt_tab_item)
                  project_dir.selected_child = selected_file
                  @current_text_editor&.text_widget&.setFocus
                }
                on_widget_disposed {
                  project_dir.selected_child&.write_dirty_content
                  tab_item_file = the_tab_item.swt_tab_item.get_data('file')
                  tab_item_file.close unless [@tab_folder1, @tab_folder2].compact.map(&:items).flatten(1).detect {|ti| ti.get_data('file') == tab_item_file}
                }
              }
              @current_tab_item.swt_tab_item.setData('file_path', selected_file.path)
              @current_tab_item.swt_tab_item.setData('file', selected_file)
              @current_tab_item.swt_tab_item.setData('proxy', @current_tab_item)
            }
            @current_tab_folder.swt_widget.setSelection(@current_tab_item.swt_tab_item)
            body_root.pack_same_size
          end
          @current_text_editor&.text_widget&.setFocus
        end
      end
      observe(self, 'maximized_pane') do
        if tab_folder2
          @tab_folder_sash_form.maximized_control = (current_tab_folder.swt_widget if maximized_pane?)
        end
      end
      observe(self, 'maximized_editor') do
        @file_area_and_editor_area_sash_form.maximized_control = (@editor_area_composite.swt_widget if maximized_editor?)
        if !maximized_editor?
          expand_navigation_expand_bar_height
        else
          collapse_navigation_expand_bar_height
        end
        @navigation_expand_item.swt_expand_item.set_expanded !maximized_editor?
        body_root.pack_same_size
        async_exec { body_root.pack_same_size }
      end
      observe(project_dir, 'selected_child') do
        save_config
      end
      observe(project_dir, 'selected_child.caret_position') do
        save_config
      end
      observe(project_dir, 'selected_child.top_pixel') do
        save_config
      end
      load_config
    }

    ## Add widget content inside custom shell body
    ## Top-most widget must be a shell or another custom shell
    #
    body {
      if !::Dir.glob(::File.join(project_dir_path, 'glimmer-cs-gladiator.jar')).empty?
        shell(:no_trim, :no_background) {
          gladiator_menu_bar(gladiator: self, editing: false)
          
          on_swt_show {
            open_project
          }
        }
      else
        shell {
          text "Gladiator - #{::File.expand_path(project_dir.path)}"
          minimum_size 590, 250
          image ICON
          
          on_swt_show {
            unless @shell_visible
              if @config[:shell_width] && @config[:shell_height]
                swt_widget.set_size(@config[:shell_width], @config[:shell_height])
              else
                swt_widget.set_size(display.bounds.width, display.bounds.height)
              end
            end
            swt_widget.setLocation(@config[:shell_x], @config[:shell_y]) if @config[:shell_x] && @config[:shell_y]
            @loaded_config = true
            @shell_visible = true
          }
          
          on_shell_closed {
            save_config
            project_dir.selected_child&.write_dirty_content
            if @tab_folder2
              current_tab_folder.swt_widget.getItems.each do |tab_item|
                tab_item.getData('proxy')&.dispose
              end
              close_tab_folder
            end
            current_tab_folder.swt_widget.getItems.each do |tab_item|
              tab_item.getData('proxy')&.dispose
            end
            body_root.close unless current_tab_folder.swt_widget.getItems.empty?
          }
          on_widget_disposed {
            project_dir.selected_child&.write_dirty_content
          }
          on_control_resized {
            save_config
          }
          on_control_moved {
            save_config
          }
          on_shell_deactivated {
            project_dir.selected_child&.write_dirty_content
          }
  
          # Menu Bar
          gladiator_menu_bar(gladiator: self, editing: true)
          
          @file_area_and_editor_area_sash_form = sash_form(:horizontal) {
            weights 1, 5
  
            composite {
              grid_layout(1, false) {
                margin_width 0
                margin_height 0
              }
              
              @side_bar_sash_form = sash_form(:vertical) {
                layout_data(:fill, :fill, true, true)
                sash_width 4
                
                resize_expand_items = lambda { |event=nil|
                  @file_lookup_expand_item&.swt_expand_item&.height = @file_lookup_expand_bar.size.y - @file_lookup_expand_item.swt_expand_item.header_height
                  @file_explorer_expand_item&.swt_expand_item&.height = @file_explorer_expand_bar.size.y - @file_explorer_expand_item.swt_expand_item.header_height
                }
                
                @file_lookup_expand_bar = expand_bar {
                  layout_data :fill, :fill, true, true
                  font height: 17, style: :bold
                  foreground @default_foreground
                  
                  on_swt_show {
                    @file_lookup_expand_item.swt_expand_item.height = @file_lookup_expand_bar.size.y - @file_lookup_expand_item.swt_expand_item.header_height
                  }
                  
                  on_swt_Resize(&resize_expand_items)
                  
                  @file_lookup_expand_item = expand_item {
                    grid_layout {
                      margin_width 0
                      margin_height 0
                    }
                    text 'File Lookup'
                    height display.bounds.height
                    
                    @filter_text = text {
                      layout_data :fill, :center, true, false
                      text bind(project_dir, 'filter')
                      on_key_pressed { |key_event|
                        if key_event.keyCode == swt(:tab) ||
                            key_event.keyCode == swt(:cr) ||
                            key_event.keyCode == swt(:arrow_up) ||
                            key_event.keyCode == swt(:arrow_down)
                          @file_lookup_list.swt_widget.select(0) if @file_lookup_list.swt_widget.getSelectionIndex() == -1
                          @file_lookup_list.swt_widget.setFocus
                        end
                      }
                    }
                  
                    @file_lookup_list = file_lookup_list(gladiator: self, foreground_color: @default_foreground) {
                      layout_data :fill, :fill, true, true
                    }
                  }
                  
                  on_item_collapsed { |event|
                    if @file_explorer_expand_item.swt_expand_item.get_expanded
                      @file_lookup_expand_item_height = @file_lookup_expand_item.swt_expand_item.height
                      @file_lookup_expand_item.swt_expand_item.height = 0
                      @file_lookup_expand_bar_height = @file_lookup_expand_bar.swt_widget.size.y
                      @file_explorer_expand_bar_height = @file_explorer_expand_bar.swt_widget.size.y
                      @side_bar_sash_form.weights = [@file_lookup_expand_item.swt_expand_item.header_height, @file_lookup_expand_bar_height + @file_explorer_expand_bar_height - @file_lookup_expand_item.swt_expand_item.header_height]
                    end
                  }
                
                  on_item_expanded {
                    @file_lookup_expand_item.swt_expand_item.height = @file_lookup_expand_item_height if @file_lookup_expand_item_height
                    @side_bar_sash_form.weights = [@file_lookup_expand_bar_height, @file_explorer_expand_bar_height]
                  }
                  
                }
                
                @file_explorer_expand_bar = expand_bar {
                  layout_data :fill, :fill, true, true
                  font height: 17, style: :bold
                  foreground @default_foreground
                  
                  on_swt_show {
                    @file_explorer_expand_item.swt_expand_item.height = @file_explorer_expand_bar.size.y - @file_explorer_expand_item.swt_expand_item.header_height
                  }
                  
                  on_swt_Resize(&resize_expand_items)
                              
                  @file_explorer_expand_item = expand_item {
                    grid_layout {
                      margin_width 0
                      margin_height 0
                    }
                    text 'File Explorer'
                    height display.bounds.height
                    
                    @file_explorer_tree = file_explorer_tree(gladiator: self, foreground_color: @default_foreground) {
                      layout_data :fill, :fill, true, true
                    }
                  }
                  
                  on_item_collapsed { |event|
                    if @file_lookup_expand_item.swt_expand_item.get_expanded
                      @file_explorer_expand_item_height = @file_explorer_expand_item.swt_expand_item.height
                      @file_explorer_expand_item.swt_expand_item.height = 0
                      @file_explorer_expand_bar_height = @file_explorer_expand_bar.swt_widget.size.y
                      @file_lookup_expand_bar_height = @file_lookup_expand_bar.swt_widget.size.y
                      @side_bar_sash_form.weights = [@file_explorer_expand_bar_height + @file_explorer_expand_bar_height - @file_explorer_expand_item.swt_expand_item.header_height, @file_explorer_expand_item.swt_expand_item.header_height]
                    end
                  }
                
                  on_item_expanded {
                    @file_explorer_expand_item.swt_expand_item.height = @file_explorer_expand_item_height if @file_explorer_expand_item_height
                    @side_bar_sash_form.weights = [@file_lookup_expand_bar_height, @file_explorer_expand_bar_height]
                  }
                  
                }
    
              }
      
            }
            
            @editor_area_composite = composite {
              grid_layout(1, false) {
                margin_width 0
                margin_height 0
              }
              
              @navigation_expand_bar = expand_bar {
                layout_data(:fill, :top, true, false) {
                  minimum_width 480
                }
                font height: 17, style: :bold
                foreground @default_foreground
                
                @navigation_expand_item = expand_item {
                  text 'Navigation'
                  height 115
    
                  grid_layout(5, false) {
                    margin_right 5
                  }
                  
                  stat_font = {name: 'Consolas', height: OS.mac? ? 15 : 12}
      
                  # row 1
      
                  label {
                    layout_data(:left, :center, false, false)
                    text 'File:'
                    foreground @default_foreground
                  }
      
                  @file_path_label = styled_text(:none) {
                    layout_data(:fill, :center, true, false) {
                      horizontal_span 2
                    }
                    background color(:widget_background)
                    foreground @default_foreground
                    editable false
                    caret nil
                    text bind(project_dir, 'selected_child.path')
                    on_mouse_up {
                      @file_path_label.swt_widget.selectAll
                    }
                    on_focus_lost {
                      @file_path_label.swt_widget.setSelection(0, 0)
                    }
                  }
                              
                  label {
                    layout_data(:left, :center, false, false) {
                      minimum_width 100
                    }
                    text 'Caret Position:'
                    foreground @default_foreground
                  }
                  label(:right) {
                    layout_data(:fill, :center, true, false) {
                      minimum_width 50
                    }
                    text bind(project_dir, 'selected_child.caret_position')
                    foreground @default_foreground
                    font stat_font
                  }
                  
                  # row 2
      
                  label {
                    layout_data(:left, :center, false, false)
                    text 'Line:'
                    foreground @default_foreground
                  }
                  @line_number_text = text {
                    layout_data(:fill, :center, true, false) {
                      width_hint 400
                      minimum_width 100
                    }
                    text bind(project_dir, 'selected_child.line_number', on_read: :to_s, on_write: :to_i)
                    foreground @default_foreground
                    font stat_font
                    on_key_pressed { |key_event|
                      if key_event.keyCode == swt(:cr)
                        @current_text_editor&.text_widget&.setFocus
                      end
                    }
                    on_verify_text { |event|
                      event.doit = !event.text.match(/^\d*$/).to_a.empty?
                    }
                  }
                  label # filler
      
                  label {
                    layout_data(:left, :center, false, false) {
                      minimum_width 100
                    }
                    text 'Line Position:'
                    foreground @default_foreground
                  }
                  label(:right) {
                    layout_data(:fill, :center, true, false) {
                      minimum_width 50
                    }
                    text bind(project_dir, 'selected_child.line_position')
                    foreground @default_foreground
                    font stat_font
                  }
      
                  # row 3
      
                  label {
                    layout_data(:left, :center, false, false)
                    text 'Find:'
                    foreground @default_foreground
                  }
                  @find_text = text {
                    layout_data(:fill, :center, true, false) {
                      width_hint 400
                      minimum_width 100
                    }
                    text bind(project_dir, 'selected_child.find_text')
                    foreground @default_foreground
                    font stat_font
                    on_key_pressed { |key_event|
                      if key_event.stateMask == swt(COMMAND_KEY) && key_event.keyCode == swt(:cr)
                        project_dir.selected_child.case_sensitive = !project_dir.selected_child.case_sensitive
                        project_dir.selected_child&.find_next
                      end
                      if key_event.keyCode == swt(:cr)
                        project_dir.selected_child&.find_next
                      end
                    }
                  }
                  composite {
                    layout_data(:left, :center, true, false) {
                      minimum_width 120
                    }
                    row_layout {
                      margin_width 0
                      margin_height 0
                    }
                    button(:check) {
                      selection bind(project_dir, 'selected_child.case_sensitive')
                      on_key_pressed { |key_event|
                        if key_event.keyCode == swt(:cr)
                          project_dir.selected_child&.find_next
                        end
                      }
                    }
                    label {
                      text 'Case-sensitive'
                      foreground @default_foreground
                    }
                  }
                  
                  label {
                    layout_data(:left, :center, false, false) {
                      minimum_width 100
                    }
                    text 'Selection Count:'
                    foreground @default_foreground
                  }
                  label(:right) {
                    layout_data(:fill, :center, true, false) {
                      minimum_width 50
                    }
                    text bind(project_dir, 'selected_child.selection_count')
                    foreground @default_foreground
                    font stat_font
                  }
                  
                  # row 4
      
                  label {
                    layout_data(:left, :center, false, false)
                    text 'Replace:'
                    foreground @default_foreground
                  }
                  @replace_text = text {
                    layout_data(:fill, :center, true, false) {
                      width_hint 400
                      minimum_width 100
                    }
                    text bind(project_dir, 'selected_child.replace_text')
                    foreground @default_foreground
                    font stat_font
                    on_focus_gained {
                      project_dir.selected_child&.ensure_find_next
                    }
                    on_key_pressed { |key_event|
                      if key_event.keyCode == swt(:cr)
                        if project_dir.selected_child
                          Command.do(project_dir.selected_child, :replace_next!)
                        end
                      end
                    }
                  }
                  label # filler
                  label {
                    layout_data(:left, :center, false, false) {
                      minimum_width 100
                    }
                    text 'Top Pixel:'
                    foreground @default_foreground
                  }
                  label(:right) {
                    layout_data(:fill, :center, true, false) {
                      minimum_width 50
                    }
                    text bind(project_dir, 'selected_child.top_pixel')
                    foreground @default_foreground
                    font stat_font
                  }
                }
                
                on_item_collapsed {
                  collapse_navigation_expand_bar_height
                }
              
                on_item_expanded {
                  expand_navigation_expand_bar_height
                }
              
              }
              
              @tab_folder_sash_form = sash_form {
                layout_data(:fill, :fill, true, true) {
                  width_hint 768
                  height_hint 576
                  minimum_width 168
                  minimum_height 176
                }
                orientation bind(self, :split_orientation) {|value| async_exec { body_root.pack_same_size}; value}
                self.current_tab_folder = self.tab_folder1 = tab_folder {
                  drag_source(DND::DROP_COPY) {
                    transfer [TextTransfer.getInstance].to_java(Transfer)
                    event_data = nil
                    on_drag_start {|event|
                      Gladiator.drag = true
                      tab_folder = event.widget.getControl
                      tab_item = tab_folder.getItem(Point.new(event.x, event.y))
                      event_data = tab_item.getData('file_path')
                    }
                    on_drag_set_data { |event|
                      event.data = event_data
                    }
                  }
                }
                @current_tab_folder.swt_widget.setData('proxy', @current_tab_folder)
              }
            }
          } # end of sash form
        }
      end
    }
    
    def load_config_ignore_paths
      # TODO eliminate duplication with load_config
      if ::File.exists?(@config_file_path)
        config_yaml = ::File.read(@config_file_path)
        return if config_yaml.to_s.strip.empty?
        @config = YAML.load(config_yaml)
        project_dir.ignore_paths = @config[:ignore_paths] if @config[:ignore_paths]
        project_dir.ignore_paths ||= ['packages', 'tmp']
      else
        @loaded_config = true
      end
    end

    def load_config
      if ::File.exists?(@config_file_path)
        config_yaml = ::File.read(@config_file_path)
        return if config_yaml.to_s.strip.empty?
        @config = YAML.load(config_yaml)
        project_dir.ignore_paths = @config[:ignore_paths] if @config[:ignore_paths]
        project_dir.ignore_paths ||= ['packages', 'tmp']
        open_file_paths1 = @config[:open_file_paths1] || @config[:open_file_paths]
        open_file_paths2 = @config[:open_file_paths2]
        self.split_orientation = (swt(@config[:split_orientation]) rescue swt(:horizontal)) if @config[:split_orientation]
        if @progress_shell.nil?
          @progress_shell = progress_shell(gladiator: self, progress_text: 'Opening Last Open Files')
          async_exec {
            @progress_shell.open
          }
        end
        open_file_paths1.to_a.each do |file_path|
          async_exec {
            Gladiator.drag = false
            Gladiator.startup = file_path != open_file_paths1.to_a[-1]
            project_dir.selected_child_path = file_path
          }
        end
        # TODO replace the next line with one that selects the visible tab
        async_exec {
          # TODO check why this is not working
          if open_file_paths1.to_a.include?(@config[:selected_child_path])
            Gladiator.drag = false
            Gladiator.startup = false
            project_dir.selected_child_path = @config[:selected_child_path] if @config[:selected_child_path]
            project_dir.selected_child&.caret_position  = project_dir.selected_child&.caret_position_for_caret_position_start_of_line(@config[:caret_position].to_i) if @config[:caret_position]
            project_dir.selected_child&.top_pixel = @config[:top_pixel].to_i if @config[:top_pixel]
          end
        }
        async_exec {
          open_file_paths2.to_a.each do |file_path|
            async_exec {
              Gladiator.drag = true
              Gladiator.startup = file_path != open_file_paths2.to_a[-1]
              project_dir.selected_child_path = file_path
            }
          end
          # TODO replace the next line with one that selects the visible tab
          async_exec {
            # TODO check why this is not working
            if open_file_paths2.to_a.include?(@config[:selected_child_path])
              Gladiator.drag = true
              Gladiator.startup = false
              project_dir.selected_child_path = @config[:selected_child_path] if @config[:selected_child_path]
              project_dir.selected_child&.caret_position  = project_dir.selected_child&.caret_position_for_caret_position_start_of_line(@config[:caret_position].to_i) if @config[:caret_position]
              project_dir.selected_child&.top_pixel = @config[:top_pixel].to_i if @config[:top_pixel]
            end
          }
          async_exec {
            Gladiator.drag = false
            @progress_shell&.close
            @progress_shell = nil
            @loaded_config = true
          }
        }
        async_exec {
          Thread.new {
            all_files = open_file_paths1.to_a + open_file_paths2.to_a
            all_files.each do |file|
              project_dir.find_child_file(file)&.dirty_content
            end
          }
        }
      else
        @loaded_config = true
      end
    end

    def save_config
      return if !@loaded_config || body_root&.disposed?
      child = project_dir.selected_child
      return if child.nil?
      tab_folder1 = @tab_folder1 || @current_tab_folder
      tab_folder2 = @tab_folder2
      open_file_paths1 = tab_folder1&.swt_widget&.items.to_a.map {|i| i.get_data('file_path')}
      open_file_paths2 = tab_folder2&.swt_widget&.items.to_a.map {|i| i.get_data('file_path')}
      split_orientation_value = split_orientation == swt(:horizontal) ? 'horizontal' : (split_orientation == swt(:vertical) ? 'vertical' : nil)
      @config = {
        selected_child_path: child.path,
        split_orientation: split_orientation_value,
        caret_position: child.caret_position,
        top_pixel: child.top_pixel,
        shell_width: swt_widget&.getBounds&.width,
        shell_height: swt_widget&.getBounds&.height,
        shell_x: swt_widget&.getBounds&.x,
        shell_y: swt_widget&.getBounds&.y,
        open_file_paths1: open_file_paths1,
        open_file_paths2: open_file_paths2,
        ignore_paths: project_dir.ignore_paths
      }
      config_yaml = YAML.dump(@config)
      ::File.write(@config_file_path, config_yaml) unless config_yaml.to_s.empty?
    rescue => e
      puts e.full_message
    end
    
    def navigate_to_next_tab_folder
      if tab_folder2
        self.maximized_pane = false
        if current_tab_folder == tab_folder1
          self.current_tab_folder = tab_folder2
        else
          self.current_tab_folder = tab_folder1
        end
        self.current_tab_item = current_tab_folder.swt_widget.getData('selected_tab_item')
        self.project_dir.selected_child = current_tab_item&.swt_tab_item&.getData('file')
        self.current_tab_item = current_tab_folder.swt_widget.getData('selected_tab_item')
        current_tab_item&.swt_tab_item&.getData('text_editor')&.text_widget&.setFocus
      end
    end

    def navigate_to_previous_tab_folder
     if tab_folder2
        self.maximized_pane = false
        if current_tab_folder == tab_folder2
          self.current_tab_folder = tab_folder1
        else
          self.current_tab_folder = tab_folder2
        end
        self.current_tab_item = current_tab_folder.swt_widget.getData('selected_tab_item')
        self.project_dir.selected_child = current_tab_item&.swt_tab_item&.getData('file')
        self.current_tab_item = current_tab_folder.swt_widget.getData('selected_tab_item')
        current_tab_item&.swt_tab_item&.getData('text_editor')&.text_widget&.setFocus
      end
    end

    def close_all_tabs(closing_tab_folder = nil)
      closing_tab_folder ||= current_tab_folder
      closing_tab_folder.swt_widget.getItems.each do |tab_item|
        project_dir.selected_child_path_history.delete(tab_item.getData('file_path'))
        tab_item.getData('proxy')&.dispose
      end
      close_tab_folder(closing_tab_folder)
      if self.current_tab_item.nil?
        filter_text.swt_widget.selectAll
        filter_text.swt_widget.setFocus
      end
    end
    
    def close_tab_folder(closing_tab_folder = nil, single_tab: false)
      closing_tab_folder ||= current_tab_folder
      if @tab_folder2 && !selected_tab_item
        if closing_tab_folder == @tab_folder2
          @tab_folder2.swt_widget.dispose
          self.current_tab_folder = @tab_folder1
        else
          @tab_folder1.swt_widget.dispose
          self.current_tab_folder = self.tab_folder1 = @tab_folder2
        end
        self.tab_folder2 = nil
        body_root.pack_same_size

        @current_tab_item = current_tab_folder.swt_widget.getData('selected_tab_item')
        @current_text_editor = @current_tab_item.swt_tab_item.getData('text_editor')
        project_dir.selected_child = @current_tab_item.swt_tab_item.getData('file')
        @current_text_editor&.text_widget&.setFocus
        async_exec { @current_text_editor&.text_widget&.setFocus }
      elsif !single_tab
        self.current_tab_item = self.current_text_editor = project_dir.selected_child = nil
      end
    end

    def find_tab_item(file_path)
      @current_tab_folder.swt_widget.getItems.detect { |ti| ti.getData('file_path') == file_path }
    end

    def selected_tab_item
      find_tab_item(project_dir.selected_child&.path)
    end

    def other_tab_items
      @current_tab_folder.swt_widget.getItems.reject { |ti| ti.getData('file_path') == project_dir.selected_child&.path }
    end
    
    def collapse_navigation_expand_bar_height
      @navigation_expand_item_height = @navigation_expand_item.swt_expand_item.height if @navigation_expand_item.swt_expand_item.height > 0
      @navigation_expand_item.swt_expand_item.height = 0
      body_root.pack_same_size
      async_exec { body_root.pack_same_size }
    end

    def expand_navigation_expand_bar_height
      @navigation_expand_item.swt_expand_item.height = @navigation_expand_item_height || 140
      body_root.pack_same_size
      async_exec { body_root.pack_same_size }
    end

    def extract_char(event)
      event.keyCode.chr
    rescue => e
      nil
    end
    
    def open_project
      selected_directory = directory_dialog.open
      return if selected_directory.nil?
      @progress_shell = progress_shell(gladiator: self, progress_text: "Opening Project: #{::File.basename(selected_directory)}")
      async_exec {
        @progress_shell.open
      }
      async_exec {
        gladiator(project_dir_path: selected_directory) {
          on_swt_show {
            @progress_shell.close
            @progress_shell = nil
          }
        }.open if selected_directory
      }
    end
    
    def display_about_dialog
      dialog {
        grid_layout(2, false) {
          margin_width 15
          margin_height 15
        }
        
        background :white
        image ICON
        text 'About'
        
        label {
          layout_data :center, :center, false, false
          background :white
          image ICON, height: 260
        }
        label {
          layout_data :fill, :fill, true, true
          background :white
          text "Gladiator v#{VERSION} (Beta)\n\n#{LICENSE}\n\nGladiator icon made by Freepik from www.flaticon.com"
        }
      }.open
    end
    
    def handle_display_shortcut(key_event)
      if key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'f'
        if !@navigation_expand_item.swt_expand_item.get_expanded
          expand_navigation_expand_bar_height
          @navigation_expand_item.swt_expand_item.set_expanded true
        end
        if current_text_editor&.text_widget&.getSelectionText && current_text_editor&.text_widget&.getSelectionText&.size.to_i > 0
          find_text.swt_widget.setText current_text_editor.text_widget.getSelectionText
        end
        find_text.swt_widget.selectAll
        find_text.swt_widget.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'c'
        Clipboard.copy(project_dir.selected_child.path)
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'g'
        project_dir.selected_child.find_previous
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'o'
        self.maximized_pane = false
        old_split_orientation = self.split_orientation
        self.split_orientation = split_pane? && split_orientation == swt(:horizontal) ? swt(:vertical) : swt(:horizontal)
        @tab_folder_sash_form.weights = [1, 1] if old_split_orientation.nil?
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == 'w'
        close_all_tabs
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :alt) && extract_char(key_event) == 'w'
        other_tab_items.each do |tab_item|
          project_dir.selected_child_path_history.delete(tab_item.getData('file_path'))
          tab_item.getData('proxy')&.dispose
        end
      elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'w'
        if selected_tab_item
          project_dir.selected_child_path_history.delete(project_dir.selected_child.path)
          selected_tab_item.getData('proxy')&.dispose
          close_tab_folder(single_tab: true)
#           if self.current_tab_item.nil?
#             filter_text.swt_widget.selectAll
#             filter_text.swt_widget.setFocus
#           else
#             current_text_editor&.text_widget&.setFocus
#           end
          if selected_tab_item.nil?
            self.current_tab_item = self.current_text_editor = project_dir.selected_child = nil
            filter_text.swt_widget.selectAll
            filter_text.swt_widget.setFocus
          else
            current_text_editor&.text_widget&.setFocus
#             async_exec { current_text_editor&.text_widget&.setFocus }
          end
        end
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == ']'
        current_tab_folder.swt_widget.setSelection((current_tab_folder.swt_widget.getSelectionIndex() + 1) % current_tab_folder.swt_widget.getItemCount) if current_tab_folder.swt_widget.getItemCount > 0
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :shift) && extract_char(key_event) == '['
        current_tab_folder.swt_widget.setSelection((current_tab_folder.swt_widget.getSelectionIndex() - 1) % current_tab_folder.swt_widget.getItemCount) if current_tab_folder.swt_widget.getItemCount > 0
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :ctrl) && extract_char(key_event) == ']'
        navigate_to_next_tab_folder
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY, :ctrl) && extract_char(key_event) == '['
        navigate_to_previous_tab_folder
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '1'
        current_tab_folder.swt_widget.setSelection(0) if current_tab_folder.swt_widget.getItemCount >= 1
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '2'
        current_tab_folder.swt_widget.setSelection(1) if current_tab_folder.swt_widget.getItemCount >= 2
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '3'
        current_tab_folder.swt_widget.setSelection(2) if current_tab_folder.swt_widget.getItemCount >= 3
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '4'
        current_tab_folder.swt_widget.setSelection(3) if current_tab_folder.swt_widget.getItemCount >= 4
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '5'
        current_tab_folder.swt_widget.setSelection(4) if current_tab_folder.swt_widget.getItemCount >= 5
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '6'
        current_tab_folder.swt_widget.setSelection(5) if current_tab_folder.swt_widget.getItemCount >= 6
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '7'
        current_tab_folder.swt_widget.setSelection(6) if current_tab_folder.swt_widget.getItemCount >= 7
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '8'
        current_tab_folder.swt_widget.setSelection(7) if current_tab_folder.swt_widget.getItemCount >= 8
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == '9'
        current_tab_folder.swt_widget.setSelection(current_tab_folder.swt_widget.getItemCount - 1) if current_tab_folder.swt_widget.getItemCount > 0
        current_text_editor&.text_widget&.setFocus
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == 'g'
        project_dir.selected_child.find_next
      elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, COMMAND_KEY) && extract_char(key_event) == 'l'
        unless @navigation_expand_item.swt_expand_item.get_expanded
          @navigation_expand_item.swt_expand_item.set_expanded true
          @navigation_expand_item.swt_expand_item.height = @navigation_expand_item_height if @navigation_expand_item_height
          async_exec {
            body_root.pack_same_size
          }
          async_exec {
            line_number_text.swt_widget.selectAll
            line_number_text.swt_widget.setFocus
          }
        else
          line_number_text.swt_widget.selectAll
          line_number_text.swt_widget.setFocus
        end
      elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 'r'
        self.maximized_editor = false
        unless @file_lookup_expand_item.swt_expand_item.get_expanded
          @file_lookup_expand_item.swt_expand_item.set_expanded true
          @file_lookup_expand_item.swt_expand_item.height = @file_lookup_expand_item_height if @file_lookup_expand_item_height
          @side_bar_sash_form.weights = [@file_lookup_expand_bar_height, @file_explorer_expand_bar_height]
        end
        filter_text.swt_widget.selectAll
        filter_text.swt_widget.setFocus
      elsif key_event.stateMask == swt(COMMAND_KEY) && extract_char(key_event) == 't'
        self.maximized_editor = false
        unless @file_explorer_expand_item.swt_expand_item.get_expanded
          @file_explorer_expand_item.swt_expand_item.set_expanded true
          @file_explorer_expand_item.swt_expand_item.height = @file_explorer_expand_item_height if @file_explorer_expand_item_height
          @side_bar_sash_form.weights = [@file_lookup_expand_bar_height, @file_explorer_expand_bar_height]
        end
        @file_explorer_tree.select_tree_item
        @file_explorer_tree.swt_widget.setFocus
      elsif key_event.keyCode == swt(:esc)
        if current_text_editor
          project_dir.selected_child_path = current_text_editor.file.path
          current_text_editor&.text_widget&.setFocus
        end
      end
    end
  end
end
