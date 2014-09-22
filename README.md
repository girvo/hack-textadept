# Hack/HHVM Syntax Highlighting for Textadept

This is a work-in-progress, but it *is* working thus far. It has most of the 
built-in types, classes and interfaces, although it needs tweaking. It's based 
around `php.lua` from Textadept's core lexer set, tweaked to handle Hack 
better. 

!(Screenshot)[http://i.imgur.com/Hn4yPIA.jpg]

## Installation

To install, copy `lexers/hack.lua` into your `~/.textadept/lexers/` folder 
(create it if required). Then, open up `~/.textadept/properties.lua` (again, 
create it if need be) and copy the contents of the `properties.lua` in this 
repository into it.

## Usage

You'll need to change into Hack mode (`Ctrl+Shift+L`), as it defaults to PHP 
for files that have the `.php` extension (`.hh` is fine though!).

## License

See `LICENSE.md`.