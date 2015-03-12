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
    return 0; // TODO
}

// converts attribute to foreground, background colors
// agrument 1: int attribute
// output 1: int foreground
// output 2: int background
// output 3: boolean bold
// output 4: boolean blink
int lua_fromAttr(lua_State *L) {
    return 0; // TODO
}
