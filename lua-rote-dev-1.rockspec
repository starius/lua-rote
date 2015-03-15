package = "lua-rote"
version = "dev-1"
source = {
    url = "git://github.com/starius/lua-rote.git"
}
description = {
    summary = "Lua binding to ROTE, Terminal Emulation library",
    homepage = "https://github.com/starius/lua-rote",
    license = "LGPL 2.1",
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
}
