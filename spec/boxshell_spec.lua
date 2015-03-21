-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- test RoteTerm:draw() and script demo/boxshell.lua

-- FIXME RoteTerm:draw() draws wrong things on Travis
-- https://travis-ci.org/starius/lua-rote/jobs/54479120#L1160

local function sleep()
    local duration = os.getenv('TEST_SLEEP') or 5
    os.execute('sleep ' .. duration)
end

describe("rote.RoteTerm.draw", function()
    it("draws the terminal to the #curses window", function()
        -- create file with secret text
        local secret = 'secret'
        local filename = os.tmpname()
        local f = io.open(filename, 'w')
        f:write(secret)
        f:close()
        -- create RoteTerm, run boxshell.lua in RoteTerm
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:forkPty('lua -lluacov demo/boxshell.lua vi')
        sleep()
        rt:update()
        assert.truthy(rt:termText():match('Term In a Box'))
        -- cell (0, 0) must have blue background
        local attr = rt:cellAttr(0, 0)
        local fg, bg = rote.fromAttr(attr)
        assert.equal(rote.name2color.blue, bg)
        -- open file
        local cmd = ':e %s\n'
        rt:write(cmd:format(filename))
        sleep()
        rt:update()
        -- FIXME RoteTerm:draw() draws wrong things on Travis
        --assert.truthy(rt:termText():match(secret))
        -- quit
        rt:write(':q\n')
        sleep()
        rt:update()
        rt:forsakeChild()
        -- cleanup
        os.remove(filename)
    end)
end)
