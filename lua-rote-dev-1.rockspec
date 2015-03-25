package = "lua-rote"
version = "dev-1"
source = {
    url = "git://github.com/starius/lua-rote.git"
}
description = {
    summary = "Lua binding to ROTE, Terminal Emulation library",
    homepage = "https://starius.github.io/lua-rote",
    license = "LGPL 2.1",
    detailed = [[
lua-rote is a Lua binding to ROTE, Terminal Emulation library

ROTE is a simple C library for VT102 terminal emulation.
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
produced by other programs. The lua-rote library depend
only on Lua, ROTE itself, ncurses and luaposix.

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
]],
}
dependencies = {
    "lua >= 5.1",
    "luaposix",
}
external_dependencies = {
    ROTE = {
        header = "rote/rote.h"
    },
    CURSES = {
        header = "curses.h"
    },
}
build = {
    type = "builtin",
    modules = {
        ['rote'] = {
            sources = {
                "src/rote.c",
                "src/attr.c",
                "src/color.c",
                "src/ncurses.c",
                "src/lua-rote.c",
            },
            incdirs = {"$(ROTE_INCDIR)", "$(CURSES_INCDIR)"},
            libdirs = {"$(ROTE_LIBDIR)"},
            libraries = {"rote"},
        },
    },
    install = {
        bin = { "demo/boxshell.lua" }
    },
}
