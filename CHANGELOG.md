# Change Log

## 0.6.3

- Display Gladiator version in window title
- Set Gladiator icon on window
- Fix issue with wording getting reversed when typing at the end of the file
- Fix issue with not being able to add new lines at the end of the file
- Fix issue with moving lines down at the end of the file making selection go out of wack
- Fix issue with Find keyboard shortcut causing a delay before landing in the Find text field
- Fix transient issue of find_next not jumping properly after replacing a term near the end of the line
- Fix issue with layout upon split
- Fix issue with layout upon opening a new tab
- Fix issue with splitting a file showing in both panes and then unsplitting afterwards detaching data-binding
- Fix issue with losing changes on exit if I do not focus out on a file

## 0.6.2

- Speed up startup time by not truly opening all files beyond showing their tab (till navigated to)
- Made CMD+F and CMD+L expand navigation section if collapsed
- Made CMD+R expand file lookup section if collapsed
- Made CMD+T expand file explorer section if collapsed
- Fix this issue: Type till the end of the line. Hit CMD+SHIFT+ENTER to jump to the previous line while inserting a line. It jumps to the next line instead as if I did CMD+ENTER
- Fix issue with closing a project shell with an x mouse click requiring multiple presses for every tab open
- Fix issue with inserting new line via CMD+ENTER not maintaining indentation

## 0.6.1

- Fixed issue relating to not recording text selection correctly when done by mouse

## 0.6.0

- Collapsable File Lookup/File Explorer/Navigation Expand Bars
- Improve Undo/Redo support by making it work for simple text editing
- Clear Undo/Redo history for a file upon closing
- Fix issue with the text editor caret dancing uncontrollably
- Fix issue with quickly moving multiple lines up or down sometimes splintering and losing multi-line selection

## 0.5.4

- CMD+SHIFT+O now splits the Text Editor without requiring Drag & Drop
- Close open files when deleting their parent directory
- Make rename refocus on the file renamed in the tree if different from the file being edited
- Save/Load Config for the Split Orientation
- Right aligned line numbers in Scratchpad and new files
- Show a friendly progress message when opening last open files
- Use SashForm for container/separator of File Lookup List and File Explorer Tree, making them resizable
- Enhance startup performance by only loading content of last open files
- Avoid extra writes to open files when no changes occurred
- Upgrade to glimmer-dsl-swt gem v4.17.10.1
- Upgrade to clipboard gem v1.3.5
- Fix issue with over-refreshing directories on focus out and back in
- Fix glitches with certain single line file operations causing unnecessary text editor scroll jitter
- Fix issue with creating directories not allowing save/rename
- Fix issue with crashing when closing a file and then trying to delete another file from the tree (might happen if you try to rename closed file) says getData returned nil
- Fix issue with line numbers not lining up perfectly with code/text lines in non-ruby files

## 0.5.3

- Upgraded to glimmer-dsl-swt v4.17.8.3, with performance optimizations for `code_text`

## 0.5.2

- Fix issue with file/directory rename not working
- Fix issue with not renaming tab text when renaming file
- Fix issue with not closing tab when deleting file

## 0.5.1

- Fixed a Windows issue with opening Ruby styled text editors

## 0.5.0

- File Menu to allow Opening a Project
- Scratchpad for running any Ruby/Glimmer code for experimentation/debugging/instrumenting
- CTRL+A and CTRL+E shortcuts for beginning of line and end of line
- Minor performance optimization by not syntax highlighting file line numbers (using standard uniform foreground coloring)
- Fix issue with going back to top of file when CMD+Tabbing to another app (losing focus) and then coming back (gaining focus)
- Fix tree slow refresh and lost refreshes on directory file changes
- Fix scroll jitter on move line up/down
- Fix issue with opening the last file open on both sides of split text editor upon launching Gladiator
- Fix issue with producing extra space at the end of some lines
- Fix issue with CMD+4 not working for jumping to the 4th tab
- Fix issue with keyboard shortcuts triggered in multiple projects

## 0.4.1

- Do not enable Ruby syntax highlighting in non-Ruby files

## 0.4.0

- Syntax highlighting
- Run menu with current file menu item
- View menu with Split Horizontal/Vertical
- Change split orientation with CMD+SHIFT+O shortcut
- Run current file shortcut CMD+SHIFT+R
- Fix issue with line numbers not scrolling perfectly along with open file (off by a few pixels)
- Fix select-all with code_text
- Fix tab with code_text
- Fix caret position after tab with code_text
- Fix issue with ENTER key not putting caret parallel to previous line start
- Fix issue with jumping to bottom when doing CMD+] or [ for indent
- Fix multi-line operations/post-selection with code_text (e.g. comment/uncomment, indent right or left)
- Fix issue with jumping one line up or down when doing CMD+] or [ for indent
- Fix CMD+ENTER and CMD+SHIFT+ENTER with code_text
- Fix Move Line Up or Move Line Down with code_text
- Fix jumping across pages of code on Find Next with code_text (it stays in the same page)
- Fix issue with jumping back to beginning of file upon very quick indent/outdent

## 0.3.1

- Fixed issue with Find/Replace revisiting the same word after Replace, making it jump to the next one.
- Add 'vendor' to ignore paths

## 0.3.0

- Support Ignore Paths ('packges' and 'tmp' by default) to avoid slowing down editor with irrelevant files
- Upgrade support to glimmer-dsl-swt 4.17.2.0 up to 5.0.0.0

## 0.2.4

- Remember split windows on restart
- Fix issue with not being able to rename file by hitting ENTER

## 0.2.3

- Improved performance of file lookup list and display of directories (removing current local directory from file prefix)

## 0.2.2

- Upgraded to glimmer-dsl-swt 0.4.0

## 0.2.1

- Drag and Drop Text Editor Split Screen Support (drag from tree or file lookup list)
- Fix issue with not rendering list and tree sometimes upon opening a small file like VERSION

## 0.2.0

- Upgraded to glimmer 0.9.1 / glimmer-dsl-swt 0.1.0
- Fixed unopen-file related bugs

## 0.1.8

- Undo/Redo
- Case-sensitive Find (and Replace by extension)
- Make CMD+SHIFT+] at the last tab go to the first tab (and vice versa with CMD+SHIFT+[)
- Fix Line/Find/Replace actions when no file is open (to avoid crash)
- Fix issue with file lookup list expanding all the way down, covering the file tree
- Fix issue with hitting home/end with selection keeping selection instead of removing it
- Fix issue with crashing if no file was open, no file is found in lookup list, and you attempt to hit enter in keyboard

## 0.1.7

- Relaxed Glimmer version requirement

## 0.1.6

- Support Linux explicitly (sort of)
- Make file tree maintain expansion state on refreshes caused by internal & external changes

## 0.1.5

- Remember all open text editor tabs when closing and reopening
- Support closing text editor tabs with keyboard shortcuts (closing current tab, closing all tabs other than current one, closing all tabs)
- Support prefix new indented line when hitting CMD+SHIFT+ENTER in the middle of a line
- Make CMD+T auto-select open file in file tree
- Make gladiator command accept directory argument instead of LOCAL_DIR and automatically open directory passed in
- Fix rename bug for when focusing out without changing name
- Fix bug with opening file with ENTER key from file tree
- Fix issue with changes not persisting when done via find/replace on a newly browsed to tab

## 0.1.4

- Fix issue with file explorer tree losing selection on refresh
- Fix file explorer opening of files on every selection change instead of just hitting ENTER or mouse click
- Fix issue with refreshing the tree on every tab switch after making changes (make it check if change is coming from any of all tabs)
- Fix issue with top index not being set from config
- Make file explorer tree show file/directory names not paths
- Make file explorer tree show current project directory name as the root instead of "."
- Make file explorer shortcut auto-reveal open file in file explorer tree
- Make hitting ESC button in line number field, file lookup field, find field, or replace field go back to open file to the same caret position as before
- Make hitting ESC button in file explorer go back to open file to the same caret position as before and reselect it
- Improve file lookup by ignoring dots
- Add number command + 2-8 tab shortcuts
- Add a new file through File Explorer
- Add a new directory through File Explorer
- Delete a file or directory through File Explorer
- Support auto-indent on hitting ENTER to add a new line
- Support insert new indented line when hitting CMD+ENTER in the middle of a line

## 0.1.3

- Fix issue with selection getting out of wack when moving a group of lines up or down
- Fix issue with Find not working for more than one occurrence in a line
- Fix issue with kill line sometimes jumping to the next line afterwards. Seems to happen if following line is empty
- Fix issue with line numbers sometimes getting clipped when openig a new file until resizing window
- Support multiple tabs
- Support tab keyboard shortcuts for next tab, previous tab, first tab, last tab
- Remember window size and location

## 0.1.2

- Fix issue with file name on top being clipped
- Fix issue with Find/Replace not working correctly for first line in the file (being off by one character)

## 0.1.1

- Fix issue with tab button killing selection (make it indent instead)
- Fix issue with crashing upon permission denied for opening a file
- Fix issue with storing .gladiator in running directory instead of LOCAL_DIR when specified
- Make entering the file lookup list automatically highlight the first element
