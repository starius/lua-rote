-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("rote", function()
    it("loads rote module", function()
        local rote = assert(require "rote")
    end)
end)
