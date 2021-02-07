# <img src='https://raw.githubusercontent.com/AndyObtiva/glimmer-cs-gladiator/master/images/glimmer-cs-gladiator-logo.svg' height=85 /> Gladiator 0.8.1 - [Ugliest Text Editor Ever!](https://www.reddit.com/r/ruby/comments/hgve8k/gladiator_glimmer_editor_ugliest_text_editor_ever/)
## [<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=40 /> Glimmer Custom Shell](https://github.com/AndyObtiva/glimmer-dsl-swt#custom-shell-gem)
[![Gem Version](https://badge.fury.io/rb/glimmer-cs-gladiator.svg)](http://badge.fury.io/rb/glimmer-cs-gladiator)

![Gladiator](images/glimmer-gladiator.png)

Gladiator (short for Glimmer Editor) is a [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) sample beta project under on-going development that demonstrates how to build a text editor in Ruby using [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) (JRuby Desktop Development GUI Library).
It is not intended to be a full-fledged editor by any means, yet mostly a fun educational exercise in using [Glimmer](https://github.com/AndyObtiva/glimmer).
Gladiator is also a personal tool for shaping an editor exactly the way I like, with all the keyboard shortcuts I prefer.
I leave building truly professional text editors to software tooling experts who would hopefully use [Glimmer](https://github.com/AndyObtiva/glimmer) one day. Otherwise, I have been happily using Gladiator to develop all my [open-source projects](https://github.com/AndyObtiva) since May of 2020.

You may now [download](#download) a packaged version of Gladiator.

## Features

Gladiator currently supports the following text editing features (including keyboard shortcuts with Mac CMD=CTRL/CTRL=ALT on Windows/Linux)

![Gladiator Demo](images/glimmer-gladiator.gif)

### Text Editor

- Text Editor with Colored Syntax Highlighting for [Multiple Languages](#multiple-language-syntax-highlighting)
- Show Line Numbers
- Multi-tab support (CMD+SHIFT+[ & CMD+SHIFT+] for tab navigation. CMD+1-9 to jump to a specific tab)
- Drag and drop split pane (drag a file from File Tree or File Lookup List, and it splits the pane)
- Duplicate Line(s)/selection (CMD+D)
- Kill Line(s)/selection (CMD+K)
- Move line/selection up (CMD+UP)
- Move line/selection down (CMD+DOWN)
- Comment/Uncomment line/selection (CMD+/)
- Indent/Unindent line/selection (CMD+] & CMD+[)
- Insert/Prefix New Line (CMD+ENTER & CMD+SHIFT+ENTER)

### File Explorer Tree

- Collapsable file explorer tree listing files and directories for open project
- Context menu to open file, rename, delete, add new file, add new directory, and refresh tree
- Jump to open file in tree (CMD+T)

### File Lookup List Filter

- Collapsable file lookup list filter (CMD+R)
- Semi-fuzzy filtering by ignoring slashes, underscores, and dots to ease lookup

### Navigation Area

- Show current text editor file name
- Show file navigation stats (Caret Position / Line Position / Selection Count / Top Pixel)
- Jump to Line (CMD+L)
- Find & Replace (CMD+F)

### Menus

- File Menu:
  - Open Project (CMD+O)
  - Quit Project (CMD+ALT+Q)
  - New Scratchpad for running arbitrary Ruby/Glimmer code without saving to disk (CMD+SHIFT+S)
- View Menu
  - Split Pane
    - Orientation change to Horizontal/Vertical (CMD+SHIFT+O)
    - Maximize Pane: maximizes current pane in split pane to take entire area (CMD+SHIFT+M)
    - Reset Panes: resets pane sizes if split width/height was adjusted (CMD+SHIFT+P)
    - Unsplit: closes the second pane (CMD+SHIFT+U)
  - Maximize Editor: maximizes editor area to hide file lookup list and file explorer tree (CMD+CTRL+M)
  - Reset All: resizes sizes of all areas in the editor (CMD+CTRL+R)
- Run Menu to run Ruby code (CMD+SHIFT+R)

### Watch External Changes

- Watch open file for external changes to automatically refresh in editor
- Watch project subdirectories for changes to automatically refresh in file explorer/file lookup

### Automatic Data Management

- Autosave on focus out/quit/open new file
- Remember opened tabs, caret position, top pixel, window size, and window location
- [Default](#configuration) "ignore paths" to avoid bogging down editor with irrelevant directory files

### Multiple Language Syntax Highlighting

- Ruby
- Markdown
- JavaScript
- JSON
- Yaml
- HTML
- C
- Haskell
- Gradle
- C++
- CSS
- Java
- JSP
- plist
- Haml
- XML
- INI
- Perl
- Tcl
- SASS
- SCSS
- SQL
- Shell (Bash / Zsh)
- Vue

## Platforms

- Mac: Gladiator works best on the Mac. This is the platform it is most used on and receives the most maintenance for.
- Windows: Gladiator works fine on Windows, but has a few minor issues.
- Linux: Gladiator works with handicaps on Linux (performing some text editing operations causes scroll jitter). Contributers could help fix.

## Pre-requisites

- [JDK](https://www.oracle.com/java/technologies/javase-downloads.html): Same version required by [Glimmer](https://github.com/AndyObtiva/glimmer-dsl-swt)
- [JRuby](https://www.jruby.org/download): Same version required by [Glimmer](https://github.com/AndyObtiva/glimmer-dsl-swt)
- [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) (JRuby Desktop Development GUI Framework) (dependency included in Ruby gem).

## Download

[Download Gladiator Mac DMG Installer](https://www.dropbox.com/s/uklftb8q16czgo6/Gladiator-0.8.1.dmg?dl=1)

[Download Gladiator Windows MSI Installer](https://www.dropbox.com/s/uuvo5h6golzmr82/Gladiator-0.8.1.msi?dl=1)

Otherwise, if you prefer a command line version, then follow the Setup Instructions below.

## Setup Instructions

Note: if you encounter any issues, check if they are documented in [TODO.md](TODO.md), [issues](https://github.com/AndyObtiva/glimmer-cs-gladiator/issues), or [pull requests](https://github.com/AndyObtiva/glimmer-cs-gladiator/pulls) as they might be on my radar to fix. Otherwise, please report as an [issue](https://github.com/AndyObtiva/glimmer-cs-gladiator/issues) or better yet fix and submit a [pull request](https://github.com/AndyObtiva/glimmer-cs-gladiator/pulls).

Install Gladiator gem by running (`jgem`, `jruby -S gem`, or `gem` directly if you have [RVM](https://rvm.io/)):

```
jgem install glimmer-cs-gladiator
```

Or add to a JRuby project Bundler `Gemfile` under the `:developement` group:

```
group :development do
  gem 'glimmer-cs-gladiator'
end
```

Run (`jruby -S bundle` or `bundle` directly if you have [RVM](https://rvm.io/)):

```
jruby -S bundle
```

Afterwards, to ensure system wide availablility of the `gladiator` command, run this command in an environment that has JRuby:

```
gladiator-setup
```

Finally, start a new terminal session or source .gladiator_source:

```
source ~/.gladiator_source
```

You should be able to run `gladiator` from anywhere now, even cross-rubies in [RVM](https://rvm.io).

## Usage

You may run the `gladiator` command to bring up the text editor in the project directory you would like to edit:

```
gladiator
```

On Linux, you may need to run with extra memory via this command instead:

```
gladiator -J-Xmx1200M
```

On Windows, you may need to run with extra memory via this command instead:

```
gladiator -J-Xmx3000M
```

If you are in a different directory from the project you would like to edit, then pass its path as an argument:

```
gladiator relative-or-absolute-path/to/project
```

Note: If you cloned this project and bundle installed, you may invoke via `bin/gladiator` instead.

### Glimmer Custom Shell Reuse

To reuse Gladiator as a Glimmer Custom Shell inside another Glimmer application, add the
following to the application's `Gemfile`:

```
gem 'glimmer-cs-gladiator', '>= 0.8.1'
```

Run:

```
jruby -S bundle
```

And, then instantiate the Gladiator [custom shell](https://github.com/AndyObtiva/glimmer-dsl-swt#custom-shells) in your [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) application via the `gladiator` keyword assuming you already have `include Glimmer` in your class, module, or main object.

## Env Var Options

Gladiator opens with the current directory as the root by default.
If you would like to open another directory, set `LOCAL_DIR` environment variable.

Example:

```
LOCAL_DIR="/Users/User/code" gladiator
```

Opens Gladiator with "/Users/User/code" as the root directory.

## Configuration

Gladiator automatically saves configuration data in a `.gladiator` file at the directory it is run from. It may be edited to add extra ignore paths.

It currently remembers:
- Last opened files (in both split panes if split)
- Window size and position
- Ignore Paths under `Glimmer::Gladiator::Dir::IGNORE_PATHS` (default: `['.gladiator', '.git', 'coverage', 'packages', 'node_modules', 'tmp', 'vendor', 'pkg', 'dist']`)

## Gotcha

Gladiator repetitively displays a signaling error that is harmless in practice:
```
The signal HUP is in use by the JVM and will not work correctly on this platform
The signal INT is in use by the JVM and will not work correctly on this platform
The signal TERM is in use by the JVM and will not work correctly on this platform
```

## TODO

[TODO.md](TODO.md)

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## Contributing to glimmer-cs-gladiator
 
- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
- Fork the project.
- Start a feature/bugfix branch.
- Commit and push until you are happy with your contribution.
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
- On windows, add this Git config: `git config core.autocrlf input` (or globally if you're working on multiple Glimmer projects)

## Copyright

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2020-2021 Andy Maleh. See [LICENSE.txt](LICENSE.txt) for further details.

--

[<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=40 />](https://github.com/AndyObtiva/glimmer) Built with [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) (JRuby Desktop Development GUI Framework)

Gladiator icon made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a>
