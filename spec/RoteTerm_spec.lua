describe("rote.RoteTerm", function()
    it("creates RoteTerm", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
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

    it("changes cell char", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:setCellChar(0, 0, 'A')
        assert.equal('A', rt:cellChar(0, 0))
    end)

    it("changes cell attribute", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:setCellAttr(0, 0, 42)
        assert.equal(42, rt:cellAttr(0, 0))
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

    it("gets updates from child", function()
        local rote = assert(require "rote")
        local rt = rote.RoteTerm(24, 80)
        rt:forkPty('ls -a')
        os.execute('sleep 1')
        rt:update()
        rt:forsakeChild()
        assert.not_equal(' ', rt:cellChar(0, 0))
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

    -- TODO write, inject, keypress, getPtyFd
end)
