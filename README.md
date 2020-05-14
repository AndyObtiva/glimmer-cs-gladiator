# Gladiator (Glimmer Editor) 0.1.2 - Glimmer Custom Shell
[![Gem Version](https://badge.fury.io/rb/glimmer-cs-gladiator.svg)](http://badge.fury.io/rb/glimmer-cs-gladiator)

![Gladiator](images/glimmer-gladiator.png)

Gladiator (short for Glimmer Editor) is a Glimmer sample project under on-going development.
It is not intended to be a full-fledged editor by any means, yet mostly a fun educational exercise in using Glimmer to build a text editor.
Gladiator is also a personal tool for shaping an editor exactly the way I like. 
I leave building truly professional text editors to software tooling experts who would hopefully use Glimmer one day.

Gladiator currently supports the following text editing features:
- File explorer navigation to open file
- File lookup by name
- Find & Replace
- Show Line Numbers
- Jump to Line
- Remember last opened file, caret position, and top line
- Autosave on focus out/quit/open new file
- Watch open file for external changes to reflect in editor
- Watch subdirectories for changes to reflect in file explorer/file lookup
- Duplicate Line(s)
- Kill Line(s)
- Move up one line
- Move down one line

## Pre-requisites

- JRuby 9.2.11.1 (supporting Ruby 2.5.x syntax) (find at https://www.jruby.org/download)
- Java SE Runtime Environment 7 or higher (find at https://www.oracle.com/java/technologies/javase-downloads.html)

## Setup Instructions

Install Gladiator gem by running (`jgem`, `jruby -S gem`, or `gem` directly if you have RVM):

```
jgem install glimmer-cs-gladiator
```

Afterwards, you may run `gladiator` to bring up the text editor:

```
gladiator
```

Note: If you cloned this project and bundle installed, you may invoke via `bin/gladiator` instead. 

### Glimmer Custom Shell Reuse

To reuse Gladiator as a Glimmer Custom Shell inside another Glimmer application, add the 
following to the application's `Gemfile`:

```
gem 'glimmer-cs-gladiator', '0.1.2'
```

Run:

```
jruby -S bundle
```

And, then instantiate the Gladiator custom shell in your Glimmer application via the `gladiator` keyword.

## Env Var Options

Gladiator opens with the current directory as the root by default. 
If you would like to open another directory, set `LOCAL_DIR` environment variable.

Example:

```
LOCAL_DIR="/Users/User/code" gladiator
```

Opens Gladiator with "/Users/User/code" as the root directory.

## Configuration

Gladiator automatically saves configuration data in a `.gladiator` file at the directory it is run from.

It currently remembers:
- Last opened file
- Caret position
- Top line position

## Gotcha

Gladiator repetitively displays a signaling error that is harmless in practice:
```
The signal HUP is in use by the JVM and will not work correctly on this platform
The signal INT is in use by the JVM and will not work correctly on this platform
The signal TERM is in use by the JVM and will not work correctly on this platform
```

## TODO

[TODO.md](TODO.md)

## Contributing to glimmer-cs-gladiator
 
- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
- Fork the project.
- Start a feature/bugfix branch.
- Commit and push until you are happy with your contribution.
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2020 Andy Maleh. See LICENSE.txt for
further details.
