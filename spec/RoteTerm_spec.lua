-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("rote.RoteTerm", function()
    it("creates RoteTerm", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
    end)

    it("can be converted to a string", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        local text = tostring(rt)
        assert.falsy(text:match("userdata"))
    end)

    it("throws if size is invalid", function()
        local rote = assert(require "rote")
        assert.has_error(function()
            local rt = rote.RoteTerm(0, 80)
        end)
        assert.has_error(function()
            local rt = rote.RoteTerm(24, 0)
        end)
    end)

    it("gets size of RoteTerm", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        assert.equal(24, rt:rows())
        assert.equal(80, rt:cols())
    end)

    it("sets cursor to (0, 0) initially", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        assert.equal(0, rt:row())
        assert.equal(0, rt:col())
    end)

    it("sets all chars to space initially", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        for row = 0, 23 do
            for col = 0, 79 do
                assert.equal(' ', rt:cellChar(row, col))
            end
        end
    end)

    it("gets one row", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:forkPty('echo 1234567890')
        os.execute('sleep 1')
        rt:update()
        rt:forsakeChild()
        assert.truthy(rt:rowText(0):match("1234567890"))
    end)

    it("throws if row number if wrong", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        assert.has_error(function()
            rt:rowText(-1)
        end)
        assert.has_error(function()
            rt:rowText(24)
        end)
    end)

    it("gets whole #screen", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        local fname = os.tmpname()
        local f = io.open(fname, 'w')
        f:write("hello\nworld\ntest\n")
        f:close()
        local pid = rt:forkPty('less ' .. fname)
        os.execute('sleep 1')
        rt:update()
        local text = rt:termText()
        assert.equal(24 * (80 + 1), #text)
        local breaks = 0
        for _ in string.gmatch(text, "\n") do
            breaks = breaks + 1
        end
        assert.equal(24, breaks)
        assert.truthy(text:match("hello"))
        assert.truthy(text:match("world"))
        assert.truthy(text:match("test"))
        os.execute('kill -9 ' .. pid)
        rt:forsakeChild()
        os.remove(fname)
    end)

    it("changes cell char", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:setCellChar(0, 0, 'A')
        assert.equal('A', rt:cellChar(0, 0))
    end)

    it("throws if length(ch) != 1", function()
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellChar(0, 0, 'aa')
        end)
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellChar(0, 0, '')
        end)
    end)

    it("throws if ch is a control character", function()
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellChar(0, 0, '\0')
        end)
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellChar(0, 0, '\n')
        end)
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellChar(0, 0, string.char(31))
        end)
    end)

    it("changes cell attribute", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:setCellAttr(0, 0, 42)
        assert.equal(42, rt:cellAttr(0, 0))
    end)

    it("throws if cell attribute is invalid", function()
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellAttr(0, 0, -1)
        end)
        assert.has_error(function()
            local rote = assert(require "rote")
            local rt = rote.RoteTerm(24, 80)
            rt:setCellAttr(0, 0, 256)
        end)
    end)

    it("changes current attribute", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:setAttr(30)
        assert.equal(30, rt:attr())
    end)

    it("has child_pid = 0 by default", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        assert.equal(0, rt:childPid())
    end)

    it("forks pty", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        local pid = rt:forkPty('ls')
        assert.equal(pid, rt:childPid())
        -- TODO fix zombie
    end)

    it("forsakes child", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:forkPty('ls')
        os.execute('sleep 1')
        rt:forsakeChild()
        -- TODO fix zombie
    end)

    it("does not #leak screen size to child", function()
        local sizes_lua = [[
curses = require 'posix.curses'
stdscr = curses.initscr()
win_rows, win_cols = stdscr:getmaxyx()
curses.endwin()
f = io.open(%q, 'w')
f:write('win_rows=' .. win_rows ..
        ' win_cols=' .. win_cols .. '\n')
f:close()
]]
        local out_fname = os.tmpname()
        sizes_lua = sizes_lua:format(out_fname)
        --
        local sizes_lua_fname = os.tmpname()
        local f = io.open(sizes_lua_fname, 'w')
        f:write(sizes_lua)
        f:close()
        --
        local rote_lua = [[
rote = require 'rote'
rows = %i
cols = %i
rt = rote.RoteTerm(rows, cols)
rt:forkPty('lua %s')
os.execute('sleep 1')
rt:update()
rt:write('q')
rt:update()
rt:forsakeChild()
]]
        local rows = 4
        local cols = 5
        rote_lua = rote_lua:format(rows, cols,
            sizes_lua_fname)
        local rote_lua_fname = os.tmpname()
        local f = io.open(rote_lua_fname, 'w')
        f:write(rote_lua)
        f:close()
        --
        local expected = 'win_rows=' .. rows ..
            ' win_cols=' .. cols
        --
        os.execute('lua ' .. rote_lua_fname)
        local f = io.open(out_fname, 'r')
        local out = f:read('*a')
        f:close()
        assert.truthy(out:match(expected))
        --
        os.remove(out_fname)
        os.execute('cat ' .. rote_lua_fname .. ' | lua -i > /dev/null 2>&1')
        local f = io.open(out_fname, 'r')
        local out = f:read('*a')
        f:close()
        assert.truthy(out:match(expected))
        --
        os.remove(out_fname)
        os.remove(sizes_lua_fname)
        os.remove(rote_lua_fname)
    end)

    it("gets updates from child", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:forkPty('ls -a')
        os.execute('sleep 1')
        rt:update()
        rt:forsakeChild()
        assert.not_equal(' ', rt:cellChar(0, 0))
    end)

    local print_AB_then_CD = [[
curses = require 'posix.curses'
stdscr = curses.initscr()
curses.echo(false)
curses.start_color()
curses.raw(true)
curses.curs_set(0)
stdscr:nodelay(false)
stdscr:keypad(true)
--
stdscr:move(0, 0)
stdscr:addch(string.byte('A'))
stdscr:move(0, 1)
stdscr:addch(string.byte('B'))
stdscr:refresh()
--
stdscr:getch()
--
stdscr:move(0, 0)
stdscr:addch(string.byte('C'))
stdscr:move(0, 1)
stdscr:addch(string.byte('D'))
stdscr:refresh()
--
stdscr:getch()
--
curses.endwin()
]]

    pending("reads output from #1x2 window",
    function()
        --
        local app_lua_fname = os.tmpname()
        local f = io.open(app_lua_fname, 'w')
        f:write(print_AB_then_CD)
        f:close()
        --
        local rote = require 'rote'
        rt = rote.RoteTerm(1, 2)
        local cmd = 'lua %s'
        cmd = cmd:format(app_lua_fname)
        rt:forkPty(cmd)
        --
        os.execute('sleep 1')
        rt:update()
        assert.equal('AB', rt:rowText(0))
        --
        rt:write(' ')
        os.execute('sleep 1')
        rt:update()
        -- This assert fails VVVV (rowText = 'D ')
        assert.equal('CD', rt:rowText(0))
        --
        rt:write(' ')
        rt:update()
        rt:forsakeChild()
        --
        os.remove(app_lua_fname)
    end)

    it("reads well from large window",
    function()
        --
        local app_lua_fname = os.tmpname()
        local f = io.open(app_lua_fname, 'w')
        f:write(print_AB_then_CD)
        f:close()
        --
        local rote = require 'rote'
        rt = rote.RoteTerm(24, 80)
        local cmd = 'lua %s'
        cmd = cmd:format(app_lua_fname)
        rt:forkPty(cmd)
        --
        os.execute('sleep 1')
        rt:update()
        assert.truthy(rt:rowText(0):match('AB'))
        --
        rt:write(' ')
        os.execute('sleep 1')
        rt:update()
        assert.truthy(rt:rowText(0):match('CD'))
        --
        rt:write(' ')
        rt:update()
        rt:forsakeChild()
        --
        os.remove(app_lua_fname)
    end)

    it("restores from snapshot", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        local snapshot = rt:takeSnapshot()
        assert.equal(' ', rt:cellChar(0, 0))
        rt:setCellChar(0, 0, 'A')
        assert.equal('A', rt:cellChar(0, 0))
        rt:restoreSnapshot(snapshot)
        assert.equal(' ', rt:cellChar(0, 0))
    end)

    it("returns pseudo tty descriptor", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        assert.equal(-1, rt:getPtyFd())
        local pid = rt:forkPty('vi')
        assert.not_equal(-1, rt:getPtyFd())
        rt:update()
        os.execute('kill -9 ' .. pid)
        rt:forsakeChild()
        assert.equal(-1, rt:getPtyFd())
    end)

    it("edits text file with #vi", function()
        local text = 'secret'
        local filename = os.tmpname()
        local esc = '\27'
        local enter = '\n'
        --
        local rote = assert(require "rote")
        local wait = assert(require "posix.sys.wait")
        local rt = rote.RoteTerm(3, 20)
        local pid = rt:forkPty('vi ' .. filename)
        os.execute('sleep 1')
        rt:update()
        rt:write('i' .. text .. esc .. ':wq')
        rt:keyPress(string.byte(enter)) -- test keyPress()
        wait.wait(pid)
        rt:update()
        rt:forsakeChild()
        --
        local f = io.open(filename, 'r')
        local text_in_file = f:read('*a'):gsub('%s', '')
        f:close()
        os.remove(filename)
        assert.equal(text, text_in_file)
    end)

    it("moves UP and DOWN in #less", function()
        local text = '1\n2\n3\n4\n5\n6\n7\n8\n'
        local filename = os.tmpname()
        local f = io.open(filename, 'w')
        f:write(text)
        f:close()
        local esc = '\27'
        local up = esc .. '[A'
        local down = esc .. '[B'
        local right = esc .. '[C'
        local left = esc .. '[D'
        --
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(3, 20)
        rt:forkPty('less ' .. filename)
        os.execute('sleep 1')
        rt:update()
        assert.truthy(rt:termText():match('1'))
        assert.truthy(rt:termText():match('2'))
        --
        rt:write(down)
        os.execute('sleep 1')
        rt:update()
        assert.falsy(rt:termText():match('1'))
        assert.truthy(rt:termText():match('2'))
        assert.truthy(rt:termText():match('3'))
        --
        rt:write(down .. down)
        os.execute('sleep 1')
        rt:update()
        assert.falsy(rt:termText():match('1'))
        assert.falsy(rt:termText():match('2'))
        assert.falsy(rt:termText():match('3'))
        assert.truthy(rt:termText():match('4'))
        assert.truthy(rt:termText():match('5'))
        --
        rt:write(right .. right)
        os.execute('sleep 1')
        rt:update()
        assert.falsy(rt:termText():match('1'))
        assert.falsy(rt:termText():match('2'))
        assert.falsy(rt:termText():match('3'))
        assert.falsy(rt:termText():match('4'))
        assert.falsy(rt:termText():match('5'))
        --
        rt:write(up .. up .. up .. left .. left)
        os.execute('sleep 1')
        rt:update()
        assert.truthy(rt:termText():match('1'))
        assert.truthy(rt:termText():match('2'))
        --
        rt:write('q')
        rt:update()
        rt:forsakeChild()
        --
        os.remove(filename)
    end)

    it("#injects characters into terminal", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:inject('secret')
        assert.truthy(rt:rowText(0):match('secret'))
    end)
end)
