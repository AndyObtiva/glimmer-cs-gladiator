# TODO

## Up Next

- Support TypeScript, Rust, Elixir, and C# (C Sharp)
- Refator code_text to utilize line numbers from Glimmer not from Gladiator
- System-wide ZOOM setup
- Show saved scratch from last scratchpad session when opening scratchpad
- Fix issue with scratchpad getting opened twice if you perform a FIND in the scratchpad then hit ESC
- Ignore `:` character in File Lookup (just like ignoring `_`)

- Preferences for installing extensions from packaged version

- Show TODO code lines in a list
- Filter File Lookup List by non-binary files
- Duplicate file feature
- Duplicate dir feature
- Fix issue with CTRL+F Find backwards not taking case-sensitivity into account (only forward)
- Fix issue with CTRL+F Find/Replace forward sometimes relanding on the same word after it's been updated
- Exclude `:` character from file lookup list search (just like `_`) as it's used in Ruby namespaces
- Add a Dark Theme
- Support increasing/decreasing size of font in text editor
- Support project-wide full-text-search
- Add Refresh File Exporer Tree action as a Menu Bar menu item
- Duplicate file from file explorer tree
- Duplicate dir from file explorer tree
- Reopen last closed tab with the CMD+SHIFT+T shortcut just like in web browsers
- Highlight all found strings of text when performing find with CMD+F (CTRL+F)
- Avoid using a file watcher per file. Watch the entire project directory with one watcher instead. This should yield less CPU usage.
- Fix issue with split view that happens when splitting a file, closing the file on the left side (original), and then attempting to make changes to file on the right side (no changes occur visibly though if file is closed and reopend, changes made do show up)
- Fix issue with CTRL+F Find backwards not taking case-sensitivity into account (only forward)
- Fix issue with CTRL+F Find/Replace forward sometimes relanding on the same word after it's been updated (it seems to happen when the replace word includes the original word at the end)
- Fix crazy cursor jumping on indent/outdent on Windows
- Fix issue with losing white space indent on hitting ENTER in an indented method on Windows
- Fix issue with not being able to close Gladiator ran from Terminal via CTRL+C (caused by filewatcher gem, consider replacing by another file monitoring gem)
- Fix issue with clearing open file when closing Gladiator from terminal with CMD+C
- Fix issue where if you split view, resulting in same file open on both sides, and then close the originally opened file on the left, leaving the one on the right open, when you go to edit the file on the right side, it does not respond to any command shortcuts like CMD+D for duplicate
- Optimize performance of file tree updates in bigger projects
- Prefix with the correct single-line comment character depending on the current file's language when hitting the CMD+/ shortcut (e.g. '#' in Ruby and '//' in Java)

- Support find and replace all across all (multiple) files in project
- Support a menu bar menu item to Format Ruby code using prettier or rubocop
- Run tests/specs through the GUI, with options to re-run failed tests only or a specific test.
- Have gladiator always open in app_mode and then quickly open a project afterwards to provide app_mode even in command line mode once open project is closed
- Save open tabs under a named group (or auto-save all open tabs under an automatically incremented name for convenience)
- Upgrade tabs to c_tab_folder to enable more tabs to fit and to support reordering tabs
- Support reordering tabs
- Add a fuzz factor to CMD+R file look up with `operation_length.times.map {|n| operation.chars.combination(operation_length - n).to_a}.reduce(:+).map(&:join)`
- Auto-close brackets/do-end blocks
- Make Undo/Redo menu items disabled when operation is not valid (not undoable or redoable)
- Fix issue with right-clicking a tree node in Windows getting defaulted back to selected node (thus unable to create a new file deep in the tree nesting when an outside file is selected)
- Add a Gladiator log feature for when running in app mode
- Fix issue with startup via app mode leaving an extra shell after opening first project (look into closing first shell if a new one replaces it)
- Fix issue with rename directory (and perhaps file) not renaming in tab file path, thus losing file changes
- Add a startup splash screen for app mode
- Support opening another existing project quickly in Gladiator if open already (via druby or dumping a file somewhere monitored)
- Support jumping up to dots only in code method invocation expressions (e.g. object.methods.anothermethod) using ALT+LEFT / ALT+RIGHT
- Fix reset view making sure it expands left expand bars
- Fix issue with going into both maximizes (editor and pane) and then hitting CMD+F not bringing up Find
- Fix issue with split and reopen file originally showing on the left side, opens again on the right side (shouldn't)
- Copy file or entire directory (into the OS)
- avoid issue in Run -> Run with eval not allowing 'include Glimmer' by evaling in the right context
- Build a console for showing feedback in running Ruby code
- Add extra indentation on new line if after a method declaration, class/module declaration, or block declaration
- Add menu bar menu items for file lockup and file explorer go to file
- Add menu bar menu items for file explorer right click menu on currently selected file
- Support zoom-font-in and zoom-font-out (CMD - & CMD + & CMD 0 for reset)
- Consider extracting tab_folder with all its dynamic logic/observers
- Consider pushing observer related logic for tree into tree
- Merge File Lookup with File Explorer
- Fix issue where typing does not bring caret_position to screen to make the word edited visible
- Fix issue with about menu item / look into why a weird java dialog comes up on about (maybe a non-issue once packaged)
- Fix issue with select-all not permitting file-wide operations like CMD+D afterwards (duplicates first line only despite file looking fully highlighted)
- Make paste an undoable command separate from change_content!
- Make the same file split on both sides have different scroll positions on both sides
- Make short gif videos of all features
- Add support for themes (perhaps a view menu quick theme switcher in addition to preferences)

- Package gladidator as a MSI
- Add gladiator-setup to make gladiator executable available everywhere

- Make file external change events undoable commands
- Display File:  as Scratchpad in Navigation for Scratchpad
- Edit Menu with all possible keyboard shortcut actions into the menu and denote their shorcuts
- Add Menu for Rake Tasks
- Try optimizing by avoiding line style coloring if file content hasn't changed
- Add Launch Glimmer App menu item (load Gemfile of app directory with Bundler when launching Gladiator to enable instant launching withing same Ruby VM)

- Show Progress Bar ticks while opening a new project
- Show Progress Bar ticks while opening last open files
- Show Progress Bar while refreshing File Explorer Tree directories/files
- Run specs (rake spec) by preloading Rakefile of open app in addition to app Gemfile (default,development,test)
- Add Edit menu with copy, paste, duplicate, comment, uncomment, indent, outdent
- Add Coolbar/Toolbar with edit menu operations

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
- Recent Projects menu item
- Reopen last open projects when run as Gladiator app (e.g. Mac app) instead of the command
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
- Support feature extensions via Ruby
- Support feature of "repeat last operation" similar to that of VIM with .
- Implement a feature showing beginning of a block when landing on a line that has end or }

## Maybe

- Build a bug commit finder that relies on `git bisect` just like [RubyMine's plugin](https://artspb.me/posts/getting-started-with-git-bisect-run-plugin/)
- Show the lexical nesting of the code somewhere as breadcrumb (e.g. scope :module -> resoucres :campaigns -> resources :templates )
- Explore the idea of following search results of text with a checkbox (e.g. some text leads to an en.yml key, and by following key, we find the true end-result needed)
- Consider saving tab groups into named tab groups that can be switched between and easily filled/cleared
- Bookmark a line of code in a file (and have a bookmarks dialog)
- Git Merge Comparison Text Editor View
- Support tightly integrated Git features in Gladiator
- Support tab and menu extensions
- gladiator-browser extension 
- Automatically split text-editor by 2 text-editor panes by dividing open tabs in half and moving the 2nd half to the 2nd text-editor pane

