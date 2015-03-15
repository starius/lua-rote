#!/usr/bin/env lua

-- Just a simple example program that creates a terminal
-- in a frame and lets the user interact with it.

-- based on demo/boxshell.c from ROTE

local curses = require 'posix.curses'
local signal = require 'posix.signal'
local rote = require 'rote'

local getout = false

signal.signal(signal.SIGCHLD, function(signo)
    getout = true
end)

local stdscr = curses.initscr()
curses.echo(false)
curses.start_color()
curses.raw(true)
stdscr:nodelay(true) -- prevents getch() from blocking
stdscr:keypad(true) -- necessary to use rt:keyPress()
local screen_h, screen_w = stdscr:getmaxyx()

-- initialize the color pairs the way rt:draw() expects it
for foreground = 0, 7 do
    for background = 0, 7 do
        if foreground ~= 7 or background ~= 0 then
            local pair = background * 8 + 7 - foreground
            curses.init_pair(pair, foreground, background)
        end
    end
end

-- paint the screen blue
stdscr:attrset(curses.color_pair(32))
for i = 0, screen_h - 1 do
    for j = 0, screen_w - 1 do
        stdscr:addch(string.byte(' '))
    end
end
stdscr:refresh()

-- create a window with a frame
local term_win = curses.newwin(22, 72, 1, 4)
-- black over white
term_win:attrset(curses.color_pair(7 * 8 + 7 - 0))
term_win:border(0, 0, 0, 0, 0, 0, 0, 0)
term_win:mvaddstr(0, 27, " Term In a Box ")
term_win:refresh()

local rt = rote.RoteTerm(20, 70)
rt:forkPty("/bin/bash --login")

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
