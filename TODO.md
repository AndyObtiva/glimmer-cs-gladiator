# TODO

## Up Next

- Fix tree slow refresh and lost refreshes on directory file changes
- Do syntax coloring in a background thread
- Don't monitor .gladiator for changes
- Add all possible keyboard shortcut actions into the menu and denote their shorcuts
- Try optimizing by avoiding line style coloring if file content hasn't changed
- Support CTRL+A and CTRL+E shortcuts for beginning of line and end of line 
- Split via CMD+SHIFT+O shortcut
- Add Launch Glimmer App menu item (load Gemfile of app directory with Bundler when launching Gladiator to enable instant launching withing same Ruby VM)
- Support a scratch pad to run any ruby code
- Fix scroll jitter on move line up/down
- Support CMD+CTRL+UP and DOWN for moving between split editor panes (since we can split vertically too now)

- Run specs (rake spec) by preloading Rakefile of open app in addition to app Gemfile (default,development,test)
- Add Edit menu with copy, paste, duplicate, comment, uncomment, indent, outdent
- Add Coolbar/Toolbar with edit menu operations

- Support instrumenting Gladiator with DRuby to start on a new project quickly if open already
- Support simultaneous multiple workspaces/projects
- Support opening a single file
- Add gladiator-setup to make gladiator executable available everywhere
- Fix issue with creating empty dir followed by empty file inside it does not work
- Support emojis in text editor
- Pack when you close a text editor split pane
- Fix issue with creating directories not allowing save/rename
- Remember Undo/Redo per text editor tab
- Strip line strings on save
- Do not strip the final line out if possible
- Support Preferences dialog for setting up ignored paths
- Save/Load Config for the Split Orientation
- Use a Sash between the text editor area and tree/list area
- Make the File/Line/Find/Replace area collapsable
- Consider replacing tab_folder with c_tab_folder to have tabs show up on the left if there is only one tab (not center like it currently is)
- A new line on a comment produces a new comment
- Have the closing curly brace or "end" keyword light up the opening curly brace or "do" keyword when landing on it

## Bugs

- Fix issue with opening the last file open on both sides of split text editor upon launching Gladiator
- Fix case-sensitive Find Back (currently ignoring case sensitivity option)
- Fix issue with line numbers sometimes not lining up perfectly with text editor (problem is back)
- Fix issue with line numbers not expanding when adding enough lines to hit 3 digits (from 2 digits)
- Stop tree from scrolling upon renaming a file
- Fix issue with Find/Replace showing word again inside replacement if it stayed but was prefixed (have it skip it instead)
- Fix issue with Replace continuing to replace if Enter was pressed after all occurrences were replaced
- Fix issue with crashing when closing a file and then trying to delete another file from the tree (might happen if you try to rename closed file) says getData returned nil
- Eliminate flicker upon indent/outdent of multiple lines
- Fix this issue (happens after closing all tabs and then attempting a file lookup find operation):
The signal TERM is in use by the JVM and will not work correctly on this platform
Unhandled Java exception: org.eclipse.swt.SWTException: Failed to execute runnable (org.jruby.exceptions.NoMethodError: (NoMethodError) undefined method `text_widget' for nil:NilClass)
org.eclipse.swt.SWTException: Failed to execute runnable (org.jruby.exceptions.NoMethodError: (NoMethodError) undefined method `text_widget' for nil:NilClass)
                              error at org/eclipse/swt/SWT.java:4723
                              error at org/eclipse/swt/SWT.java:4638
                   runAsyncMessages at org/eclipse/swt/widgets/Synchronizer.java:188
                   runAsyncMessages at org/eclipse/swt/widgets/Display.java:4126
                    readAndDispatch at org/eclipse/swt/widgets/Display.java:3793
                             invoke at java/lang/reflect/Method.java:498
  invokeDirectWithExceptionHandling at org/jruby/javasupport/JavaMethod.java:441
                       invokeDirect at org/jruby/javasupport/JavaMethod.java:305
                   start_event_loop at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-dsl-swt-0.1.3/lib/glimmer/swt/shell_proxy.rb:133
                               open at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-dsl-swt-0.1.3/lib/glimmer/swt/shell_proxy.rb:77
                               open at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-dsl-swt-0.1.3/lib/glimmer/ui/custom_shell.rb:16
                  invokeOther3:open at Users/User/code/glimmer_minus_cs_minus_gladiator/bin//Users/User/code/glimmer-cs-gladiator/bin/gladiator_runner.rb:5
                             <main> at Users/User/code/glimmer_minus_cs_minus_gladiator/bin//Users/User/code/glimmer-cs-gladiator/bin/gladiator_runner.rb:5
                invokeWithArguments at java/lang/invoke/MethodHandle.java:627
                          runScript at org/jruby/Ruby.java:1205
                        runNormally at org/jruby/Ruby.java:1128
                        runNormally at org/jruby/Ruby.java:1146
                        runFromMain at org/jruby/Ruby.java:958
                      doRunFromMain at org/jruby/Main.java:412
                        internalRun at org/jruby/Main.java:304
                                run at org/jruby/Main.java:234
                               main at org/jruby/Main.java:206

Caused by:
org.jruby.exceptions.NoMethodError: (NoMethodError) undefined method `text_widget' for nil:NilClass
    method_missing at org/jruby/RubyBasicObject.java:1708
    method_missing at Users/User/$_dot_rvm/gems/jruby_minus_9_dot_2_dot_11_dot_1_at_40_glimmer_minus_cs_minus_gladiator/gems/glimmer_minus_0_dot_9_dot_3/lib//Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer.rb:57
         Gladiator at Users/User/code/glimmer_minus_cs_minus_gladiator/lib/views/glimmer//Users/User/code/glimmer-cs-gladiator/lib/views/glimmer/gladiator.rb:206
  start_event_loop at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-dsl-swt-0.1.3/lib/glimmer/swt/shell_proxy.rb:133
              open at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-dsl-swt-0.1.3/lib/glimmer/swt/shell_proxy.rb:77
              open at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-dsl-swt-0.1.3/lib/glimmer/ui/custom_shell.rb:16
            <main> at Users/User/code/glimmer_minus_cs_minus_gladiator/bin//Users/User/code/glimmer-cs-gladiator/bin/gladiator_runner.rb:5

- Fix issue which happens when closing all tabs while in Find text box (or something like that):
Glimmer::InvalidKeywordError: Glimmer keyword swt with args [:tab] cannot be handled! Check the validity of the code.
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:38
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
                 handle at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/expression_handler.rb:31
              interpret at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/engine.rb:154
  add_static_expression at /Users/User/.rvm/gems/jruby-9.2.11.1@glimmer-cs-gladiator/gems/glimmer-0.9.3/lib/glimmer/dsl/engine.rb:107
              Gladiator at /Users/User/code/glimmer-cs-gladiator/lib/views/glimmer/gladiator.rb:264

- Make file renames also rename the open file tab

## Refactorings

- Refactor code around ignore_paths
- Automate running tests on git push

## Enhancements

- Make tabs not take memory when not selected (they unload/dispose their control)
- Make gladiator command accept file argument and automatically open file and parent directory
- Support Automatic Version/Revision History with an auto-clear after size

## Features

- Add popups to Gladiator showing the shortcut of each field (e.g. CMD+L for Line)
- Package gladidator as a DMG/APP
- Support autocomplete (primarily Glimmer DSL syntax)
- Support jumping between parts of a programming expression underscores or dots instead of an entire expression on ALT LEFT & RIGHT
- Support collapsing blocks of code (e.g. class Name {...}) and expanding them again, collapsing line numbers next to them too. 
This allows easy copying/pasting of big blocks of code without making mistakes in grabbing the end of the block that matches the beginning.
- Remember caret position and top of file in every file opened, not just the last one
- Hot reloading
- Display caret position
- Autohide file tree and file lookup list when not used
- Support changing local directory (e.g. File -> Change Directory)
- Split screen
- Support Copy/Paste in File Tree
- Support Cut/Paste in File Tree
- Support project-wide full-text-search
- Move files/directories in file tree using Drag & Drop
- Support duplicate file functionality
- Drag & Drop Editor Tabs
- Store Undo/Redo history in config permenantly per file path (not file object)
- Find/Replace All
- Highlight line we are on in the line number text widget on the left side
- Multi-selection in tree and multi-deletion
- Close open file if deleted
- Make tree data binding editing (adding new node) resort into the right place
- Strip lines of empty space when performing copy/cut/paste/duplicate/comment/uncomment actions
- Support CMD+SHIFT+TAB for Tab Close Undo
- Text Column selection (StyledText setBlockSelection)
- Add multi-project support
