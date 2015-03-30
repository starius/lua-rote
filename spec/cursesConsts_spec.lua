-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("rote.cursesConsts", function()
    it("gets values of curses constants", function()
        local cursesConsts = require 'rote.cursesConsts'
        assert.truthy(cursesConsts.KEY_UP)
        assert.truthy(cursesConsts.KEY_DOWN)
        assert.truthy(cursesConsts.KEY_LEFT)
        assert.truthy(cursesConsts.KEY_RIGHT)
    end)
end)
