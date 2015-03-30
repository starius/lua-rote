-- lua-rote, Lua binding to ROTE, Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- ROTE is a simple C library for VT102 terminal emulation.
-- See http://rote.sourceforge.net/

-- returns table of curses numeric consts
-- module posix.curses requires starting curses,
-- otherwise these consts are not initialized.
-- Starting curses if often not desirable.
-- This module spawns child process, which
-- prints values of consts.

local rote = require 'rote'
local wait = assert(require "posix.sys.wait")

local function printConsts()
    local curses = require 'posix.curses'
    local stdscr = curses.initscr()
    curses.endwin()
    local out_fname = assert(arg[1])
    local out = io.open(out_fname, 'w')
    out:write('return {')
    for name, value in pairs(curses) do
        if type(value) == "number" then
            local t = "[%q] = %i,"
            out:write(t:format(name, value))
        end
    end
    out:write('}')
    out:close()
end

local fname = os.tmpname()
local f = io.open(fname, 'w')
f:write(string.dump(printConsts))
f:close()

local fname2 = os.tmpname()

local lluacov = os.getenv('LOAD_LUACOV') or ''

local cmd = 'lua %s %s %s'
cmd = cmd:format(lluacov, fname, fname2)

local rt = rote.RoteTerm(24, 80)
local pid = rt:forkPty(cmd)
wait.wait(pid)
rt:forsakeChild()

local consts = dofile(fname2)

os.remove(fname)
os.remove(fname2)

return consts
