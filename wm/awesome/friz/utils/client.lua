local awful = require("awful")

local function raise(c, move)
    if c == nil then
        return
    end
    local s = awful.screen.focused()
    if move and s ~= nil then
        c:move_to_screen(s.index)
    end
    client.focus = c
end

local function directional(dir)
    awful.client.focus.global_bydirection(dir)
    local c = client.focus
    local screen = awful.screen.focused()
    if c ~= nil and c.screen ~= screen then
        awful.screen.focus_bydirection(dir)
    end
end

function toggle_maximize(c)
    local tags = c.tags(c)
    local clients = tags[1].clients(tags[1])

    local max = not c.fullscreen
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
    for _, sibling in pairs(clients) do
        if c ~= sibling then
            if max then
                sibling.fullscreen = false
            end
        end
    end

    c.fullscreen = max
end


return {
    raise = raise,
    directional = directional,
    toggle_maximize = toggle_maximize
}
