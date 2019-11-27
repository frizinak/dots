local awful = require("awful")
local setmetatable = setmetatable
local drop = {}
local dropdown = {}
local busy = false
local attach_signal = client.connect_signal or client.add_signal
local detach_signal = client.disconnect_signal or client.remove_signal

awful.client.property.persist("scratchdrop", "string")
awful.client.property.persist("scratchdrop:vert", "string")
awful.client.property.persist("scratchdrop:horiz", "string")
awful.client.property.persist("scratchdrop:width", "string")
awful.client.property.persist("scratchdrop:height", "string")

attach_signal(
    "manage",
    function (c)
        local p = awful.client.property.get(c, "scratchdrop")
        if p ~= "" and p ~= nil then
            dropdown[p] = c
            _toggle(
                c,
                awful.client.property.get(c, "scratchdrop:vert"),
                awful.client.property.get(c, "scratchdrop:horiz"),
                awful.client.property.get(c, "scratchdrop:width"),
                awful.client.property.get(c, "scratchdrop:height")
            )
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

function toggle(prog, vert, horiz, width, height, sticky)
    if busy then
        return
    end

    if dropdown[prog] then
        _toggle(dropdown[prog], vert, horiz, width, height)
        return
    end

    local spawnw
    spawnw = function (c)
        detach_signal("manage", spawnw)
        busy = false
        dropdown[prog] = c
        awful.client.property.set(c, "scratchdrop", prog)
        awful.client.property.set(c, "scratchdrop:vert", vert)
        awful.client.property.set(c, "scratchdrop:horiz", horiz)
        awful.client.property.set(c, "scratchdrop:width", width)
        awful.client.property.set(c, "scratchdrop:height", height)

        c.floating = true
        resize(c, vert, horiz, width, height)
        if sticky then c.sticky = true end
        if c.titlebar then awful.titlebar.remove(c) end
        client.focus = c
        c:raise()
    end
    attach_signal("manage", spawnw)
    busy = true
    awful.spawn.with_shell(prog, false)
end

function resize(c, vert, horiz, width, height)
    vert = vert or "top"
    horiz= horiz or "center"
    width= width or 1
    height = height or 0.25
    local scr = mouse.screen
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

function _toggle(c, vert, horiz, width, height)
    local scr = mouse.screen
    if c == nil then
        return
    end

    if c:isvisible() == false then
        c.hidden = true
        resize(c, vert, horiz, width, height, scr)
        c:move_to_screen(scr)
        c:move_to_tag(scr.selected_tag)
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

    if c.hidden then
        c.hidden = false
        client.focus = c
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
