# TODO

## Up Next

- Make gladiator command work globally and not just for application that has gem configured
- Make gladiator accept argument instead of LOCAL_DIR and automatically open file and directory if file was passed in

## Bugs

- Fix issue with line numbers not scrolling perfectly along with open file (off by a few pixels)
- Fix issue with not rendering list and tree sometimes upon opening a small file like VERSION
- Fix tree slow refresh and lost refreshes on directory file changes

## Enhancements

- Make tabs not take memory when not selected (they unload/dispose their control)

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
