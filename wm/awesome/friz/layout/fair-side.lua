-- original author Josh Komoroske
-- @copyright 2012 Josh Komoroske
-- @release v3.5.2

local beautiful = require("beautiful")
local ipairs = ipairs
local math = math

local fair = {name = "fair-side"}
fair.arrange = function(p)
    -- local gap = tonumber(beautiful.useless_gap_width) or 0
    -- if gap < 0 then gap = 0 end
    local gap = 30

    local border_x0 = 30
    local border_x1 = 120
    local border_y0 = 120 + 550
    local border_y1 = 120

    local wa = p.workarea
    local width = 1400
    wa.x = wa.x + wa.width - width
    wa.width = width

    wa.x = wa.x + border_x0
    wa.y = wa.y + border_y0
    wa.width = wa.width - border_x0 - border_x1 + gap
    wa.height = wa.height - border_y0 - border_y1 + gap
    local cls = p.clients

    if #cls < 1 then
        return
    end

    local rows, cols = 1, 2
    if #cls ~= 2 then
        rows = math.ceil(math.sqrt(#cls))
        cols = math.ceil(#cls / rows)
    end

    for k, c in ipairs(cls) do
        k = k - 1
        local g = {}

        local row, col = 0, 0
        row = k % rows
        col = math.floor(k / rows)

        local lrows, lcols = rows, cols
        if k >= rows * cols - rows then
            lrows = #cls - (rows * cols - rows)
            lcols = cols
        end

        if wa.width < wa.height then
            t = row
            row = col
            col = t
            t = lrows
            lrows = lcols
            lcols = t
        end

        g.height = math.ceil(wa.height / lrows)
        g.y = g.height * row
        if row == lrows - 1 then
            g.height = wa.height - math.ceil(wa.height / lrows) * row
            g.y = wa.height - g.height
        end

        g.width = math.ceil(wa.width / lcols)
        g.x = g.width * col
        if col == lcols - 1 then
            g.width = wa.width - math.ceil(wa.width / lcols) * col
            g.x = wa.width - g.width
        end

        g.height = g.height - c.border_width * 2 - gap
        g.width = g.width - c.border_width * 2 - gap
        g.y = g.y + wa.y
        g.x = g.x + wa.x

        c:geometry(g)
    end
end

return fair
