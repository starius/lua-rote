-- This file is part of lua-rote, Lua binding to ROTE
-- Terminal Emulation library
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("rote.attr", function()
    it("packs and unpacks attributes (example)", function()
        local rote = assert(require "rote")
        local n2c = rote.name2color
        local fg = n2c.green
        local bg = n2c.red
        local bold = true
        local blink = false
        local attr = rote.toAttr(fg, bg, bold, blink)
        assert.truthy(attr >= 0)
        assert.truthy(attr < 256)
        local fg1, bg1, bold1, blink1 = rote.fromAttr(attr)
        assert.equal(fg, fg1)
        assert.equal(bg, bg1)
        assert.equal(bold, bold1)
        assert.equal(blink, blink1)
    end)

    it("can be applied to all possible values of attribute",
    function()
        local rote = assert(require "rote")
        for attr = 0, 255 do
            local fg, bg, bold, blink = rote.fromAttr(attr)
            local attr1 = rote.toAttr(fg, bg, bold, blink)
            assert.equal(attr, attr1)
        end
    end)

    it("defaults to bold=false and blink=false", function()
        local rote = assert(require "rote")
        assert.equal(rote.toAttr(1, 2, false, false),
                     rote.toAttr(1, 2))
    end)

    it("throws on bad attr", function()
        local rote = assert(require "rote")
        assert.has_error(function()
            local fg, bg, bold, blink = rote.fromAttr(-1)
        end)
        assert.has_error(function()
            local fg, bg, bold, blink = rote.fromAttr(256)
        end)
    end)

    it("throws on bad color", function()
        local rote = assert(require "rote")
        assert.has_error(function()
            local attr = rote.toAttr(-1, 1)
        end)
        assert.has_error(function()
            local attr = rote.toAttr(8, 1)
        end)
        assert.has_error(function()
            local attr = rote.toAttr(1, -1)
        end)
        assert.has_error(function()
            local attr = rote.toAttr(1, 8)
        end)
    end)
end)
