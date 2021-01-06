# TODO

## Up Next

- Maximize Editor Keyboard Shortcut / Menu Item
- Restore Editor Keyboard Shortcut / Menu Item
- Maximize Split Pane Size Keyboard Shortcut / Menu Item
- Restore Split Pane Keyboard Shortcut / Menu Item
- Upgrade to glimmer-dsl-swt v4.18.0.0

- Fix issue with about menu item / look into why a weird java dialog comes up on about (maybe a non-issue once packaged)
- Fix issue with find highlighting of already selected word and hitting enter causing word to get deleted first time done in a just open file
- Fix issue with creating a new directory in a different project from the main one open
- Have Find and Line number shortcuts show Navigation section if hidden
- Fix issue with select-all not permitting file-wide operations like CMD+D afterwards (duplicates first line only despite file looking fully highlighted)
- Fix issue where typing does not bring caret_position to screen to make visible anymore
- Make paste an undoable command separate from change_content!

- Package gladidator as a DMG/MSI
- Add gladiator-setup to make gladiator executable available everywhere

- Display File:  as Scratchpad in Navigation for Scratchpad
- Edit Menu with all possible keyboard shortcut actions into the menu and denote their shorcuts
- Add Menu for Rake Tasks
- Try optimizing by avoiding line style coloring if file content hasn't changed
- Split via CMD+SHIFT+O shortcut
- Add Launch Glimmer App menu item (load Gemfile of app directory with Bundler when launching Gladiator to enable instant launching withing same Ruby VM)

- Show Progress Bar ticks while opening a new project
- Show Progress Bar ticks while opening last open files
- Run specs (rake spec) by preloading Rakefile of open app in addition to app Gemfile (default,development,test)
- Add Edit menu with copy, paste, duplicate, comment, uncomment, indent, outdent
- Add Coolbar/Toolbar with edit menu operations

- Support instrumenting Gladiator with DRuby to start on a new project quickly if open already
- Support simultaneous multiple workspaces/projects
- Support opening a single file
- Fix issue with creating empty dir followed by empty file inside it does not work
- Support emojis in text editor
- Strip line strings on save
- Do not strip the final line out if possible
- Support Preferences dialog for setting up ignored paths
- Use a Sash between the text editor area and tree/list area
- Consider replacing tab_folder with c_tab_folder to have tabs show up on the left if there is only one tab (not center like it currently is)
- A new line on a comment produces a new comment
- Have the closing curly brace or "end" keyword light up the opening curly brace or "do" keyword when landing on it
- Make a text editor fit the screen (from the left or right) from the sash form (add keyboard shortcuts and menu items for that)
- Recent Projects menu item
- Add rubocop like warnings while using Gladiator like when a file is too large or a method is too long, showing a special color somewhere live.
- Ability to right-click tabs and close them with the mouse
- Menu bar items for rake tasks and keyboard shortcut to bring them up

## Bugs

- Fix caret position after formatting dirty content (perhaps relying on diffing)
- troubleshoot why adding margin to body root composite in Texteditor with margin_height 0 causes gladiator to start resizing window smaller than necessary upon launch of Gladiator
- Fix issue with slowdown upon inserting a new file/directory into the tree
- Fix case-sensitive Find Back (currently ignoring case sensitivity option)
- Fix issue with line numbers not expanding when adding enough lines to hit 3 digits (from 2 digits)
- Stop tree from scrolling upon renaming a file
- Fix issue with Find/Replace showing word again inside replacement if it stayed but was prefixed (have it skip it instead)
- Fix issue with Replace continuing to replace if Enter was pressed after all occurrences were replaced
- Eliminate flicker upon indent/outdent of multiple lines

## Refactorings

- Refactor code around ignore_paths
- Automate running tests on git push
- Upgrade undo/redo support to be diff based
- Look into ensuring freeing of memory upon closing projects

## Enhancements

- Make tabs not take memory when not selected (they unload/dispose their control)
- Make gladiator command accept file argument and automatically open file and parent directory
- Support Automatic Version/Revision History with an auto-clear after size

## Features

- Make into a tray icon always-on app
- Jump to method feature
- Add popups to Gladiator showing the shortcut of each field (e.g. CMD+L for Line)
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
- Make tree data binding editing (adding new node) resort into the right place
- Strip lines of empty space when performing copy/cut/paste/duplicate/comment/uncomment actions
- Support CMD+SHIFT+T for Tab Close Undo
- Text Column selection (StyledText setBlockSelection)
- Enhance File Explorer Tree with directory/file icons
- Enhance Tabs with file type icons
