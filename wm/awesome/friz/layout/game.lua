
local beautiful = require("beautiful")
local ipairs = ipairs
local math = math

local game = {name = "game"}
game.arrange = function(p, q)
    local gap = tonumber(beautiful.useless_gap_width) or 0
    if gap < 0 then gap = 0 end

    local border_x0 = beautiful.border_x0 or 0
    local border_x1 = beautiful.border_x1 or 0
    local border_y0 = beautiful.border_y0 or 0
    local border_y1 = beautiful.border_y1 or 0

    local wa = p.workarea
    local cls = p.clients
    local num_x = screen[p.screen].selected_tag.master_count-1
    local wah = wa.height - border_y0 - border_y1
    local rh = wah / (#cls - 1)

    local minh = wah / 4
    if rh > minh then
        rh = minh
    end

    local inc = 8
    if num_x >= inc then
        num_x = inc-1
    elseif num_x < 0 then
        num_x = 0
    end

    local mw = wa.width * (inc-num_x) / inc
    local rw = wa.width - mw
    if rw <= 0 then
        rw = wa.width / inc
    end

    for k, c in ipairs(cls) do
        local g = {}
        g.x = wa.x + wa.width - rw + gap
        g.y = (k - 2) * rh + border_y0
        g.width = rw - gap - border_x1
        g.height = rh - gap
        if k == 1 then
            g.x = wa.x
            g.y = wa.y
            g.width = mw
            g.height = wa.height
        end
        -- c.ontop = false -- k ~= 1
        c:geometry(g)
        if k ~= 1 then
            c:raise()
        end
    end
end

return game
