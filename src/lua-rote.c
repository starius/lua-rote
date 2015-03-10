// lua-rote, libROTE Lua bindings
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#include "lua-rote.h"

static const luaL_Reg rote_funcs[] = {
    {"RoteTerm", lua_RoteTerm},
    {"toAttr", lua_toAttr},
    {"fromAttr", lua_fromAttr},
    {NULL, NULL}
};

int luaopen_rote(lua_State *L) {
    register_types(L);
    lua_newtable(L); // module "rote"
    my_setfuncs(L, rote_funcs);
    register_colors(L);
    return 1;
}
