// lua-rote, Lua binding to ROTE, Terminal Emulation library
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#include "lua-rote.h"

WINDOW* lua_getWindow(lua_State* L, int index) {
    WINDOW** win = luaL_checkudata(L, index,
            "posix.curses:window");
    return *win;
}
