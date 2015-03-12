// lua-rote, Lua binding to ROTE, Terminal Emulation library
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#include "lua-rote.h"

// argument -2 is table name => int
// argument -1 is table int => name
static void register_color(lua_State *L,
        const char* name, int value) {
    // table name => int
    lua_pushinteger(L, value);
    lua_setfield(L, -3, name);
    // table int => name
    lua_pushinteger(L, value);
    lua_pushstring(L, name);
    lua_settable(L, -3);
}

// register standard colors
void register_colors(lua_State *L) {
    lua_newtable(L); // rote.name2color
    lua_newtable(L); // rote.color2name
    //
    register_color(L, "black", 0);
    register_color(L, "red", 1);
    register_color(L, "green", 2);
    register_color(L, "yellow", 3);
    register_color(L, "blue", 4);
    register_color(L, "magenta", 5);
    register_color(L, "cyan", 6);
    register_color(L, "white", 7);
    //
    lua_setfield(L, -3, "color2name");
    lua_setfield(L, -2, "name2color");
}
