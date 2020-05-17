# Change Log

## 0.1.4

- Fix issue with file explorer tree losing selection on refresh
- Fix file explorer opening of files on every selection change instead of just hitting ENTER or mouse click
- Make file explorer tree show file/directory names not paths
- Make file explorer tree show current project directory name as the root instead of "."
- Improve file lookup by ignoring dots
- Add number command + 2-8 tab shortcuts

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
