# Change Log

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
