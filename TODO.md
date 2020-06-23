# TODO

## Up Next

TBD

## Bugs

- Fix issue with line numbers not scrolling perfectly along with open file (off by a few pixels)
- Fix issue with not rendering list and tree sometimes upon opening a small file like VERSION
- Fix tree slow refresh and lost refreshes on directory file changes
- Fix issue with Find/Replace showing word again inside replacement if it stayed but was prefixed (have it skip it instead)
- Fix issue with Replace continuing to replace if Enter was pressed after all occurrences were replaced
- Fix issue with crashing when closing a file and then trying to delete another file from the tree (might happen if you try to rename closed file) says getData returned nil

## Enhancements

- Make tabs not take memory when not selected (they unload/dispose their control)
- Make gladiator command accept file argument and automatically open file and parent directory

## Features

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

