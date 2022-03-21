local awful = require("awful")
local setmetatable = setmetatable
local drop = {}
local dropdown = {}
local busy = false
local attach_signal = client.connect_signal or client.add_signal
local detach_signal = client.disconnect_signal or client.remove_signal
local machi = require("layout-machi")
local gtimer = require("gears.timer")
local once = require("friz.utils.signal").connect_once

awful.client.property.persist("scratchdrop", "string")
attach_signal(
    "manage",
    function (c)
        local p = awful.client.property.get(c, "scratchdrop")
        if p ~= "" and p ~= nil then
            dropdown[p] = c
            _toggle(c, false)
        end
    end
)

attach_signal(
    "unmanage",
    function (c)
        local p = awful.client.property.get(c, "scratchdrop")
        if dropdown[p] == c then
            dropdown[p] = nil
        end
    end
)

function toggle(prog)
    if busy then
        return
    end

    if prog == "" or prog == nil then
        _toggle(nil, 0, 0, 0, 0, false)
        return
    end

    if dropdown[prog] then
        _toggle(dropdown[prog])
        return
    end

    toggle()

    local spawnw
    spawnw = function (c)
        busy = false
        dropdown[prog] = c
        awful.client.property.set(c, "scratchdrop", prog)

        client.focus = c
        c:raise()
        once(screen, "arrange", function()
            machi.switcher.start(c).master_add()
        end)
    end
    once(client, "manage", spawnw)
    busy = true
    awful.spawn.with_shell(prog, false)
end

function resize(c, vert, horiz, width, height)
    vert = vert or "top"
    horiz= horiz or "center"
    width= width or 1
    height = height or 0.25
    local scr = c and c.screen or awful.screen.focused()
    local screengeom = screen[scr].workarea

    if width <= 1 then width = screengeom.width * width end
    if height <= 1 then height = screengeom.height * height end

    if horiz == "left" then x = screengeom.x
    elseif horiz == "right" then x = screengeom.width - width
    else x = screengeom.x+(screengeom.width-width)/2 end

    if vert == "bottom" then y = screengeom.height + screengeom.y - height
    elseif vert == "center" then y = screengeom.y+(screengeom.height-height)/2
    else y = screengeom.y - screengeom.y end

    c:geometry({ x = x, y = y, width = width - 2, height = height })
    c.above = true
end

function _toggle(c, state)
    local scr = c and c.screen or awful.screen.focused()
    if c ~= nil and not c:isvisible() then
        c.hidden = true
        c:move_to_screen(scr)
    end

    for _prog, other in pairs(dropdown) do
        if other ~= c then
            other.hidden = true
            local ctags = other:tags()
            for i, t in pairs(ctags) do
                ctags[i] = nil
            end
            other:tags(ctags)
        end
    end

    if c == nil then
        return
    end

    local hidden = (c.hidden and state ~= false) or state == true

    if hidden then
        once(screen, "arrange", function()
            machi.switcher.start(c).master_add()
        end)
        c.hidden = false
        c:move_to_tag(scr.selected_tag)
        client.focus = c
        c:raise()
    elseif client.focus ~= c and state ~= false then
        once(screen, "arrange", function()
            machi.switcher.start(c).master_add()
        end)
        c:move_to_tag(scr.selected_tag)
        client.focus = c
        c:raise()
    else
        c.hidden = true
        local ctags = c:tags()
        for i, t in pairs(ctags) do
            ctags[i] = nil
        end
        c:tags(ctags)
    end
end

return setmetatable(drop, { __call = function(_, ...) return toggle(...) end })
