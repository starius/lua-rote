#!/usr/bin/env lua

-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- ROTE is a simple C library for VT102 terminal emulation.
-- See http://rote.sourceforge.net/

-- Just a simple example program that creates a terminal
-- in a frame and lets the user interact with it.

-- based on demo/boxshell.c from ROTE

local curses = require 'curses'
local signal = require 'posix.signal'
local rote = require 'rote'
local name2color = rote.name2color

local getout = false

signal.signal(signal.SIGCHLD, function(--[[signo]])
    getout = true
end)

local stdscr = curses.initscr()
curses.echo(false)
curses.start_color()
curses.raw(true)
local tenths_of_second = 1
curses.halfdelay(tenths_of_second) -- halfdelay mode
stdscr:keypad(true) -- necessary to use rt:keyPress()
local screen_h, screen_w = stdscr:getmaxyx()

local function makePair(foreground, background)
    return background * 8 + 7 - foreground
end

-- initialize the color pairs the way rt:draw() expects it
for foreground = 0, 7 do
    for background = 0, 7 do
        if foreground ~= 7 or background ~= 0 then
            local pair = makePair(foreground, background)
            curses.init_pair(pair, foreground, background)
        end
    end
end

-- paint the screen blue
local background = name2color.blue
local foreground = name2color.white
local pair = makePair(foreground, background)
stdscr:attrset(curses.color_pair(pair))
for _ = 0, screen_h - 1 do
    for _ = 0, screen_w - 1 do
        stdscr:addch(string.byte(' '))
    end
end
stdscr:refresh()

-- create a window with a frame
local term_win = curses.newwin(22, 72, 1, 4)
-- black over white
local pair2 = makePair(name2color.black, name2color.white)
term_win:attrset(curses.color_pair(pair2))
term_win:border(0, 0, 0, 0, 0, 0, 0, 0)
term_win:mvaddstr(0, 27, " Term In a Box ")
term_win:refresh()

local rt = rote.RoteTerm(20, 70)
local command = arg[1] or "/bin/bash --login"
rt:forkPty(command)

while not getout do
    rt:draw(term_win, 1, 1)
    term_win:refresh()
    local ch = stdscr:getch()
    local ERR = 255
    if type(ch) == 'number' and ch ~= ERR then
        rt:keyPress(ch)
    end
end

curses.endwin()
