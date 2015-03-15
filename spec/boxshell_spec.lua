-- test RoteTerm:draw() and script demo/boxshell.lua

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
        rt:forkPty('lua demo/boxshell.lua vi')
        os.execute('sleep 10')
        rt:update()
        assert.truthy(rt:termText():match('Term In a Box'))
        -- cell (0, 0) must have blue background
        local attr = rt:cellAttr(0, 0)
        local fg, bg = rote.fromAttr(attr)
        assert.equal(rote.name2color.blue, bg)
        -- open file
        local cmd = ':e %s\n'
        rt:write(cmd:format(filename))
        os.execute('sleep 10')
        rt:update()
        print(rt:termText())
        assert.truthy(rt:termText():match(secret))
        -- quiz less
        rt:write(':q\n')
        os.execute('sleep 1')
        rt:update()
        rt:forsakeChild()
        -- cleanup
        os.remove(filename)
    end)
end)
