# TODO

## Up Next

- Move files/directories in file tree using Drag & Drop
- Support duplicate file functionality
- Fix issue with file lookup list expanding all the way down, covering the file tree
- Fix issue with hitting home/end with selection keeping selection instead of removing it 

## Bugs

- Fix issue with line numbers not scrolling perfectly along with open file (off by a few pixels)
- Fix issue with not rendering list and tree sometimes upon opening a small file like VERSION
- Fix tree slow refresh and lost refreshes on directory file changes
- Fix issue with Find/Replace showing word again inside replacement if it stayed but was prefixed (have it skip it instead)

## Enhancements

- Make tabs not take memory when not selected (they unload/dispose their control)
- Make gladiator command accept file argument and automatically open file and parent directory
- Make CMD+SHIFT+] at the last tab go to the first tab (and vice versa with CMD+SHIFT+[) 

## Features

- Implement Undo/Redo (it partially works right now from text widget built-in undo/redo)
- Add popups to Gladiator showing the shortcut of each field (e.g. CMD+L for Line)
- Package gladidator as a DMG/APP
- Support autocomplete
- Support jumping between parts of a programming expression underscores or dots instead of an entire expression on ALT LEFT & RIGHT
- Support collapsing blocks of code (e.g. class Name {...}) and expanding them again, collapsing line numbers next to them too. 
This allows easy copying/pasting of big blocks of code without making mistakes in grabbing the end of the block that matches the beginning.
- Remember caret position and top of file in every file opened, not just the last one
- Hot reloading
- Display caret position
- Autohide file tree and file lookup list when not used
- Support changing local directory (e.g. File -> Change Directory)
- Add menus
