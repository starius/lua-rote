// lua-rote, Lua binding to ROTE, Terminal Emulation library
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#ifndef LUA_ROTE_H_
#define LUA_ROTE_H_

#include <ncurses.h>
#include <rote/rote.h>
#define LUA_LIB
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#if LUA_VERSION_NUM == 501
#define my_setfuncs(L, funcs) luaL_register(L, NULL, funcs)
#else
#define my_setfuncs(L, funcs) luaL_setfuncs(L, funcs, 0)
#endif

// converts foreground, background colors to attribute
int lua_toAttr(lua_State *L);

// converts attribute to foreground, background colors
int lua_fromAttr(lua_State *L);

// gets and checks attribute at given index
int lua_getAttr(lua_State* L, int index);

// register standard colors
// argument -2 is table name => int
// argument -1 is table int => name
void register_colors(lua_State *L);

// create instance of RoteTerm
int lua_RoteTerm(lua_State* L);

/** Get curses WINDOW from a userdatum at given index.
A userdatum stores a pointer to WINDOW.
Metatable of the userdatum must be "curses:window".
See https://github.com/lcurses/lcurses/blob/master/ext/curses/window.c
*/
WINDOW* lua_getWindow(lua_State* L, int index);

// create metatables of types, add them to the registry
void register_types(lua_State* L);

#endif
