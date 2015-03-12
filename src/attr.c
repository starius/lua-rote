// lua-rote, Lua binding to ROTE, Terminal Emulation library
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#include "lua-rote.h"

// converts foreground, background colors to attribute
// agrument 1: int foreground
// agrument 2: int background
// agrument 3: boolean bold (optinal)
// agrument 4: boolean blink (optinal)
int lua_toAttr(lua_State *L) {
    int foreground = luaL_checkinteger(L, 1);
    int background = luaL_checkinteger(L, 2);
    int bold = lua_toboolean(L, 3);
    int blink = lua_toboolean(L, 4);
    luaL_argcheck(L, foreground >= 0, 1, "foreground >= 0");
    luaL_argcheck(L, foreground < 8, 2, "foreground < 8");
    luaL_argcheck(L, background >= 0, 3, "background >= 0");
    luaL_argcheck(L, background < 8, 4, "background < 8");
    unsigned char ch = 0;
    ROTE_ATTR_MOD_FG(ch, foreground);
    ROTE_ATTR_MOD_BG(ch, background);
    ROTE_ATTR_MOD_BOLD(ch, bold);
    ROTE_ATTR_MOD_BLINK(ch, blink);
    lua_pushinteger(L, ch);
    return 1;
}

// converts attribute to foreground, background colors
// agrument 1: int attribute
// output 1: int foreground
// output 2: int background
// output 3: boolean bold
// output 4: boolean blink
int lua_fromAttr(lua_State *L) {
    int attr = lua_getAttr(L, 1);
    lua_pushinteger(L, ROTE_ATTR_FG(attr));
    lua_pushinteger(L, ROTE_ATTR_BG(attr));
    lua_pushboolean(L, ROTE_ATTR_BOLD(attr));
    lua_pushboolean(L, ROTE_ATTR_BLINK(attr));
    return 4;
}
