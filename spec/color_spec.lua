-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("rote.color", function()
    it("converts colors to/from integers", function()
        local rote = assert(require "rote")
        local c2n = rote.color2name
        local n2c = rote.name2color
        assert.equal("green", c2n[n2c.green])
        assert.equal(2, n2c[c2n[2]])
    end)
end)
