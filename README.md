# lua-rote, Lua binding to ROTE, Terminal Emulation library

[![Build Status](https://travis-ci.org/starius/lua-rote.png?branch=master)](https://travis-ci.org/starius/lua-rote)
[![Coverage Status](https://coveralls.io/repos/starius/lua-rote/badge.png?branch=master)](https://coveralls.io/r/starius/lua-rote?branch=master)
[![License](http://img.shields.io/badge/License-LGPL2.1-brightgreen.png)][4]

## Description

[ROTE][1] is a simple C library for VT102 terminal emulation.
It allows the programmer to set up virtual 'screens' and send
them data. The virtual screens will emulate the behavior of a
VT102 terminal, interpreting escape sequences, control
characters and such. The library supports ncurses as well so
that you may render the virtual screen to the real screen
when you need to.

There are several programs that do terminal emulation, such
as xterm, rxvt, screen and even the Linux console driver
itself. However, it is not easy to isolate their terminal
emulation logic and put it in a module that can be easily
reused in other programs. That's where the ROTE library
comes in.

The goal of the lua-rote library is to provide terminal
emulation support for Lua applications, making it
possible to write programs that display terminals in
embedded windows within them, or even monitor the display
produced by other programs. The lua-rote library depends
only on Lua, ROTE itself, ncurses, lcurses and luaposix.

The ROTE library is able to render the
virtual screens to the physical screen (actually any
ncurses window) and can also translate ncurses key codes to
the escape sequences the Linux console would have produced
(and feed them into the terminal). Using ncurses is not
mandatory however, and ROTE will work fine without it, but
in that case the application must take care of drawing the
terminal to the screen in whichever way it sees fit.

ROTE also encapsulates the functionality needed to execute
a child process using the virtual screen as the controlling
terminal. It will handle the creation of the
pseudo-terminal and the child process. All the application
has to do is tell it the command to run in the terminal and
call an update function at regular intervals to allow the
terminal to update itself.

ROTE is extremely useful to programmatically interact
with curses applications (e.g., for unit testing).

## Prerequisites

 - Lua 5.1, 5.2, 5.3 or LuaJIT
 - luaposix
 - curses (binary + headers)
 - lcurses (install after installing curses headers!)
 - [ROTE][1] (install after installing curses headers!)

> Curses and luaposix are needed for drawing state of ROTE
> terminal on curses' WINDOW object
> (method [RoteTerm:draw()](#draw)).
> If you do not need this feature and want to exclude these
> dependencies, then remove CURSES, lcurses and luaposix from
> file `lua-rote-*.rockspec`.

See [shell script][5] with installation
commands for Debian Wheezy.

## Installation

This library is built using [LuaRocks](http://luarocks.org).

### Option 1: install from LuaRocks server

```bash
$ luarocks install lua-rote
```

If you have installed ROTE to prefix other than "/usr",
you have to provide this path to LuaRocks.
For example, if you have installed ROTE to "/usr/local",
use the following command:

```bash
$ luarocks install lua-rote ROTE_DIR=/usr/local
```

### Option 2: install from local source tree

```bash
$ git clone https://github.com/starius/lua-rote.git
$ cd lua-rote
$ luarocks make
```

## Running unit tests

Unit tests are written using unit testing framework
[busted](http://olivinelabs.com/busted/).
Unit tests can serve as reference documentation and
code examples.

To run unit tests, install busted from LuaRocks:

```bash
$ luarocks install busted
```

Go to the source folder of lua-rote and run command `busted`:

```bash
$ busted
++++++++++++++++++++++++++++++++
32 successes / 0 failures / 0 errors / 0 pending : 1.5 seconds
```

## Running the demo

Program [boxshell.lua][6] is a clone of
ROTE's example program "boxshell.c" (file "demo/boxshell.c"
in ROTE's source tree).
Both programs include the following steps:

 - start curses,
 - fill the screen with blue,
 - create curses window in the middle of the screen,
 - start ROTE terminal, fork bash inside,
 - do in a loop until child process dies:
    - redraw curses window accorsing to ROTE terminal,
    - `getch()`, results of which are passed to ROTE terminal.

Run `lua demo/boxshell.lua`, `ls`, `busted`:

![boxshell.lua](http://i.imgur.com/F5K9gJt.png)

> Currently lua-rote does not support unicode characters,
> that is why busted was changed to produce "+" instead of "●".

> There are some differences between boxshell.c and
> boxshell.lua. Program boxshell.lua can fork other commands
> as well as bash. boxshell.c uses `nodelay` mode
> repeating draw-getch cycle without a delay,
> while boxshell.lua uses `halfdelay` mode repeating
> draw-getch cycle 10 times a second.
> That is why boxshell.c constantly consumes 100% CPU,
> while boxshell.lua consumes almost no CPU when inactive.

## Reference

### Module rote

Library lua-rote is loaded from module "rote":

```lua
rote = require 'rote'
```

All code of the library "lives" inside this module.

### Class RoteTerm

The main part of the library is class RoteTerm.
It wraps C structure RoteTerm, declared in library ROTE.
RoteTerm represents terminal emulator.

Create a new virtual terminal with the given dimensions.
(Height is 24 rows, width is 80 columns.)

```lua
rt = rote.RoteTerm(24, 80)
```

Instance of RoteTerm is destroyed automatically
when the corresponding Lua object is collected.

### Start child process

Start a forked process in the terminal:

```lua
pid = rt:forkPty('less /some/file')
```

The command will be interpreted by '/bin/sh -c'.

Returns PID of the child process.
On error returns `-1`.
Notice that passing an invalid command will not cause
an error at this level: the shell will try to execute
the command and will exit with status 127. You can catch
that by installing a `SIGCHLD` handler if you want.

> If you want to be notified when child processes exits,
> you should handle the `SIGCHLD` signal.
> If, on the other hand, you want to ignore exitting
> child processes, you should set the `SIGCHLD` handler to
> `SIG_IGN` to prevent child processes from hanging
> around the system as 'zombie processes'.
>
> You can use luaposix to manage child processes as described
> above. See file [demo/boxshell.lua][6].
>
> Continuing to write to a RoteTerm whose child process
> has died does not accomplish a lot, but is not an error
> and should not cause your program to crash or block
> indefinitely or anything of that sort :-)
>
> If, however, you want to be tidy and inform the RoteTerm
> that its child has died, call method `forsakeChild`
> when appropriate.

You can get the PID later by calling `rt:childPid()`.

Disconnect the RoteTerm from its forked child process:

```lua
rt:forsakeChild()
```

### Getting contents of the terminal

You can get number of rows and columns of the terminal:

```lua
print(rt:rows()) -- integer
print(rt:cols()) -- integer
```

Get cursor coordinates:

```lua
print(rt:row()) -- integer
print(rt:col()) -- integer
```

Before getting any output from the child process, call method
`rt:update()` to update internal state of RoteTerm.

You can get value of character and attribute of any cell:

```lua
row = 0
col = 0
print(rt:cellChar(row, col)) -- string of length 1
attr = rt:cellAttr(row, col) -- integer
```

lua-rote provides [several functions](#handling-attributes)
to handle attribute values.

Get current attribute, that is the attribute that will be
used for newly characters:

```lua
print(rt:attr()) -- integer
```

Get a row as a string (not terminated with `\n`):

```lua
row = 0
print(rt:rowText(row)) -- string
```

Get whole terminal as a string (rows are terminated with `\n`):

```lua
print(rt:termText()) -- string
```

<a name="draw" id="draw"></a>
Draw contents of ROTE terminal on curses WINDOW:

```lua
curses = require 'curses'
-- setup curses, see demo/boxshell.lua
window = ...
rt = ...
start_row = 0
start_col = 0
rt:draw(window, start_row, start_col)
```

### Changing the terminal state

You can directly change internal state of RoteTerm by
calling the following methods:

```lua
rt:setCellChar(row, col, character) -- character at (row, col)
rt:setCellAttr(row, col, attr) -- attribute at (row, col)
rt:setAttr(attr) -- current attribute
```

You can pass data to the child process or to the terminal:

```lua
-- Puts data ':wq\n' into the terminal.
-- If there is a forked process, the data will be sent to it.
-- If there is no forked process, the data will simply
-- be injected into the terminal (as in inject()).
rt:write(':wq\n')

-- Inject data directly into the terminal.
rt:inject(':wq\n')

-- Indicates to the terminal that the key has been pressed.
-- Appropriate escape sequence is passed to method write().
local keycode = string.byte('\n') -- integer
rt:keyPress(keycode)
```

You can get values of keycodes from [curses][3].
Unfortunately it should be initialized, otherwise
constants are not available. Initialization of curses
may be undesirable in an application (testing tool),
which runs another application, which runs curses.
There is a workaround: module [`"rote.cursesConsts"`][14].
It uses rote to run child Lua process, which initializes
curses and prints values of constants.
The module `"rote.cursesConsts"` returns them
as a table.

### Snapshots

```lua
-- take a snapshot of the current contents of the terminal
snapshot = rt:takeSnapshot()
-- ... do something ...
-- restore a snapshot previously taken
rt:restoreSnapshot(snapshot)
```

Snapshot object is deleted automatically when the
corresponding Lua object is collected.

<a name="handling-attributes" id="handling-attributes"></a>

### Handling attributes

An 'attribute' as used in this library means an 8-bit value
that conveys a foreground color code, a background color code,
and the bold and blink bits. Each cell in the virtual terminal
screen is associated with an attribute that specifies
its appearance.

The bits of an attribute, from most significant to
least significant, are

```
 bit:      7 6 5 4 3 2 1 0
 content:  S F F F H B B B
           | `-,-' | `-,-'
           |   |   |   |
           |   |   |   `----- 3-bit background color (0 - 7)
           |   |   `--------- blink bit
           |   `------------- 3-bit foreground color (0 - 7)
           `----------------- bold bit
```


Color codes:

 - 0 = black,
 - 1 = red,
 - 2 = green,
 - 3 = yellow,
 - 4 = blue,
 - 5 = magenta,
 - 6 = cyan,
 - 7 = white.

There are functions provided to "pack" and "unpack"
attribute bits:

```lua
foreground, background, bold, blink = rote.fromAttr(attr)
attr = rote.toAttr(foreground, background, bold, blink)
-- foreground and background are integers (0 - 7)
-- bold and blink are booleans
```

The library provides tables converting color codes to and from
human readable names:

```lua
print(rote.color2name[2]) -- prints "green"
print(rote.name2color.green) -- prints "2"
```

## Bugs

 - Unicode characters are printed and read with errors.
 - Method `RoteTerm:draw()` is [unreliable][2].
 - ROTE can't read cell 0x0 in 1x2 window when
    reads second time. It seems to be related to
    low number of columns.

[Report a bug][7]

## Author

Corresponding author: Boris Nagaev, email: bnagaev@gmail.com

Copyright (C) 2015 Boris Nagaev

See the [LICENSE][4] file for terms of use.

ROTE was written by Bruno T. C. de Oliveira,
see [rote.sourceforge.net][1] for more information.

## Links

 - [Home page][13]
 - [ROTE][1]
 - [Report a bug][7]
 - [Reddit][8]
 - [Хабрахабр][9]
 - [lua-l][12]
 - [Busted][10]
 - [lua-travis-example][11]

[1]: http://rote.sourceforge.net/
[2]: https://travis-ci.org/starius/lua-rote/jobs/54479120#L1160
[3]: https://lcurses.github.io/lcurses/
[4]: LICENSE
[5]: .travis/install_rote.sh
[6]: demo/boxshell.lua
[7]: https://github.com/starius/lua-rote/issues/new
[8]: https://www.reddit.com/r/lua/comments/30ast4/ann_luarote_lua_binding_to_rote_terminal/
[9]: http://habrahabr.ru/post/254089/
[10]: http://olivinelabs.com/busted/
[11]: https://github.com/moteus/lua-travis-example
[12]: http://lua-users.org/lists/lua-l/2015-03/msg00325.html
[13]: http://starius.github.io/lua-rote
[14]: src/cursesConsts.lua
