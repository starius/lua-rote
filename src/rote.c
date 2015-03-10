// lua-rote, libROTE Lua bindings
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#include <assert.h>

#include "lua-rote.h"

RoteTerm* lua_RoteTerm_self(lua_State* L, int index) {
    RoteTerm** rt = luaL_checkudata(L, index, "rote_RoteTerm");
    return *rt;
}

int lua_RoteTerm_gc(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    rote_vt_destroy(rt);
    return 0;
}

static const luaL_Reg RoteTerm_mt[] = {
    {"__gc", lua_RoteTerm_gc},
    // TODO
    {NULL, NULL}
};

// create metatables of types, add them to the registry
void register_types(lua_State* L) {
    // metatable of RoteTerm
    luaL_newmetatable(L, "rote_RoteTerm");
    my_setfuncs(L, RoteTerm_mt);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // mt.__index = mt
    lua_pop(L, 1);
}

// create instance of RoteTerm
// arguments:
// 1. int rows
// 2. int cols
int lua_RoteTerm(lua_State* L) {
    int rows = luaL_checkinteger(L, 1);
    int cols = luaL_checkinteger(L, 2);
    RoteTerm** rt = lua_newuserdata(L, sizeof(RoteTerm*));
    luaL_getmetatable(L, "rote_RoteTerm");
    assert(lua_type(L, -1) == LUA_TTABLE);
    lua_setmetatable(L, -2);
    (*rt) = rote_vt_create(rows, cols);
    return 1;
}
