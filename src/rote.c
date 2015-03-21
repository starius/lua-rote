// lua-rote, Lua binding to ROTE, Terminal Emulation library
// Copyright (C) 2015 Boris Nagaev
// See the LICENSE file for terms of use.

// ROTE is a simple C library for VT102 terminal emulation.
// See http://rote.sourceforge.net/

#include <assert.h>

#include "lua-rote.h"

static RoteTerm* lua_RoteTerm_self(lua_State* L, int index) {
    RoteTerm** rt = luaL_checkudata(L, index, "rote_RoteTerm");
    return *rt;
}

static int lua_RoteTerm_gc(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    rote_vt_destroy(rt);
    return 0;
}

static int lua_RoteTerm_tostring(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    char text[500];
    int length = sprintf(text, "RoteTerm %ix%i",
            rt->rows, rt->cols);
    lua_pushlstring(L, text, length);
    return 1;
}

static int lua_RoteTerm_rows(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    lua_pushinteger(L, rt->rows);
    return 1;
}

static int lua_RoteTerm_cols(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    lua_pushinteger(L, rt->cols);
    return 1;
}

static int lua_RoteTerm_row(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    lua_pushinteger(L, rt->crow);
    return 1;
}

static int lua_RoteTerm_col(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    lua_pushinteger(L, rt->ccol);
    return 1;
}

static void lua_RoteTerm_row_col(lua_State* L,
        RoteTerm* rt, int* row, int* col) {
    *row = luaL_checkinteger(L, 2);
    *col = luaL_checkinteger(L, 3);
    luaL_argcheck(L, *row >= 0, 2, "row >= 0");
    luaL_argcheck(L, *row < rt->rows, 2, "row < rows");
    luaL_argcheck(L, *col >= 0, 3, "col >= 0");
    luaL_argcheck(L, *col < rt->cols, 3, "col < cols");
}

// arguments:
// 1. RowTerm
// 2. int row
// 3. int col
static int lua_RoteTerm_cellChar(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int row, col;
    lua_RoteTerm_row_col(L, rt, &row, &col);
    const char c = rt->cells[row][col].ch;
    lua_pushlstring(L, &c, 1);
    return 1;
}

// arguments:
// 1. RowTerm
// 2. int row
// 3. int col
// 4. string ch
static int lua_RoteTerm_setCellChar(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int row, col;
    lua_RoteTerm_row_col(L, rt, &row, &col);
    size_t length;
    const char* ch = luaL_checklstring(L, 4, &length);
    luaL_argcheck(L, length == 1, 4, "length(ch) == 1");
    char c = ch[0];
    luaL_argcheck(L, c >= 32, 4, "ch >= 32");
    rt->cells[row][col].ch = c;
    return 0;
}

// arguments:
// 1. RowTerm
// 2. int row
// 3. int col
static int lua_RoteTerm_cellAttr(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int row, col;
    lua_RoteTerm_row_col(L, rt, &row, &col);
    lua_pushinteger(L, rt->cells[row][col].attr);
    return 1;
}

int lua_getAttr(lua_State* L, int index) {
    int attr = luaL_checkinteger(L, index);
    luaL_argcheck(L, attr >= 0, index, "attr >= 0");
    luaL_argcheck(L, attr < 256, index, "attr < 256");
    return attr;
}

// arguments:
// 1. RowTerm
// 2. int row
// 3. int col
// 4. int attr
static int lua_RoteTerm_setCellAttr(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int row, col;
    lua_RoteTerm_row_col(L, rt, &row, &col);
    int attr = lua_getAttr(L, 4);
    rt->cells[row][col].attr = attr;
    return 0;
}

static int lua_RoteTerm_attr(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    lua_pushinteger(L, rt->curattr);
    return 1;
}

// arguments:
// 1. RowTerm
// 2. int attr
static int lua_RoteTerm_setAttr(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int attr = lua_getAttr(L, 2);
    rt->curattr = attr;
    return 0;
}

// arguments:
// 1. RowTerm
// 2. int row
static int lua_RoteTerm_rowText(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int row = luaL_checkinteger(L, 2);
    luaL_argcheck(L, row >= 0, 2, "row >= 0");
    luaL_argcheck(L, row < rt->rows, 2, "row < rows");
    char* buffer = lua_newuserdata(L, rt->cols);
    int col;
    RoteCell* cells = rt->cells[row];
    for (col = 0; col < rt->cols; col++) {
        buffer[col] = cells[col].ch;
    }
    lua_pushlstring(L, buffer, rt->cols);
    return 1;
}

static int lua_RoteTerm_termText(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int size = rt->rows * (rt->cols + 1);
    char* buffer = lua_newuserdata(L, size);
    int row;
    for (row = 0; row < rt->rows; row++) {
        char* b1 = buffer + row * (rt->cols + 1);
        int col;
        RoteCell* cells = rt->cells[row];
        for (col = 0; col < rt->cols; col++) {
            b1[col] = cells[col].ch;
        }
        b1[rt->cols] = '\n';
    }
    lua_pushlstring(L, buffer, size);
    return 1;
}

static int lua_RoteTerm_childPid(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    lua_pushinteger(L, rt->childpid);
    return 1;
}

// arguments:
// 1. RowTerm
// 2. command
// returns:
// 1. pid
static int lua_RoteTerm_forkPty(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    size_t command_len;
    const char* command = luaL_checklstring(L, 2,
            &command_len);
    size_t size = command_len + 100;
    char* cmd = lua_newuserdata(L, size);
    sprintf(cmd, "LINES=%i COLUMNS=%i %s",
            rt->rows, rt->cols, command);
    int pid = rote_vt_forkpty(rt, cmd);
    lua_pushinteger(L, pid);
    return 1;
}

static int lua_RoteTerm_forsakeChild(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    rote_vt_forsake_child(rt);
    return 0;
}

static int lua_RoteTerm_update(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    rote_vt_update(rt);
    return 0;
}

// arguments:
// 1. RowTerm
// 2. string data
static int lua_RoteTerm_write(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    size_t length;
    const char* data = luaL_checklstring(L, 2, &length);
    rote_vt_write(rt, data, length);
    return 0;
}

// arguments:
// 1. RowTerm
// 2. string data
static int lua_RoteTerm_inject(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    size_t length;
    const char* data = luaL_checklstring(L, 2, &length);
    rote_vt_inject(rt, data, length);
    return 0;
}

// arguments:
// 1. RowTerm
// 2. WINDOW
// 3. int start_row
// 3. int start_col
static int lua_RoteTerm_draw(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    WINDOW* win = lua_getWindow(L, 2);
    int start_row = luaL_checkinteger(L, 3);
    int start_col = luaL_checkinteger(L, 4);
    rote_vt_draw(rt, win, start_row, start_col, NULL);
    return 0;
}

// arguments:
// 1. RowTerm
// 2. int keycode
static int lua_RoteTerm_keyPress(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int keycode = luaL_checkinteger(L, 2);
    rote_vt_keypress(rt, keycode);
    return 0;
}

static void* lua_RoteSnapshot_self(
        lua_State* L, int index) {
    void** rs = luaL_checkudata(L,
            index, "rote_RoteSnapshot");
    return *rs;
}

static int lua_RoteSnapshot_gc(lua_State* L) {
    void* rs = lua_RoteSnapshot_self(L, 1);
    free(rs);
    return 0;
}

static int lua_RoteTerm_takeSnapshot(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    void** rs = lua_newuserdata(L, sizeof(void*));
    luaL_getmetatable(L, "rote_RoteSnapshot");
    assert(lua_type(L, -1) == LUA_TTABLE);
    lua_setmetatable(L, -2);
    (*rs) = rote_vt_take_snapshot(rt);
    return 1;
}

static int lua_RoteTerm_restoreSnapshot(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    void* rs = lua_RoteSnapshot_self(L, 2);
    rote_vt_restore_snapshot(rt, rs);
    return 0;
}

static int lua_RoteTerm_getPtyFd(lua_State* L) {
    RoteTerm* rt = lua_RoteTerm_self(L, 1);
    int fd = rote_vt_get_pty_fd(rt);
    lua_pushinteger(L, fd);
    return 1;
}

//

static const luaL_Reg RoteTerm_mt[] = {
    {"__gc", lua_RoteTerm_gc},
    {"__tostring", lua_RoteTerm_tostring},
    {"rows", lua_RoteTerm_rows},
    {"cols", lua_RoteTerm_cols},
    {"row", lua_RoteTerm_row},
    {"col", lua_RoteTerm_col},
    {"cellChar", lua_RoteTerm_cellChar},
    {"setCellChar", lua_RoteTerm_setCellChar},
    {"cellAttr", lua_RoteTerm_cellAttr},
    {"setCellAttr", lua_RoteTerm_setCellAttr},
    {"attr", lua_RoteTerm_attr},
    {"setAttr", lua_RoteTerm_setAttr},
    {"rowText", lua_RoteTerm_rowText},
    {"termText", lua_RoteTerm_termText},
    {"childPid", lua_RoteTerm_childPid},
    {"forkPty", lua_RoteTerm_forkPty},
    {"forsakeChild", lua_RoteTerm_forsakeChild},
    {"update", lua_RoteTerm_update},
    {"write", lua_RoteTerm_write},
    {"inject", lua_RoteTerm_inject},
    {"draw", lua_RoteTerm_draw},
    {"keyPress", lua_RoteTerm_keyPress},
    {"takeSnapshot", lua_RoteTerm_takeSnapshot},
    {"restoreSnapshot", lua_RoteTerm_restoreSnapshot},
    {"getPtyFd", lua_RoteTerm_getPtyFd},
    {NULL, NULL}
};

static const luaL_Reg RoteSnapshot_mt[] = {
    {"__gc", lua_RoteSnapshot_gc},
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
    // metatable of RoteSnapshot
    luaL_newmetatable(L, "rote_RoteSnapshot");
    my_setfuncs(L, RoteSnapshot_mt);
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
    luaL_argcheck(L, rows > 0, 1, "rows > 0");
    luaL_argcheck(L, cols > 0, 2, "cols > 0");
    RoteTerm** rt = lua_newuserdata(L, sizeof(RoteTerm*));
    luaL_getmetatable(L, "rote_RoteTerm");
    assert(lua_type(L, -1) == LUA_TTABLE);
    lua_setmetatable(L, -2);
    (*rt) = rote_vt_create(rows, cols);
    return 1;
}
