local beautiful = require("beautiful")
local cols = { name = "cols" }

function cols.arrange(p)
    local gap = tonumber(beautiful.useless_gap_width) or 0
    if gap < 0 then gap = 0 end

    local border_x0 = beautiful.border_x0 or 0
    local border_x1 = beautiful.border_x1 or 0
    local border_y0 = beautiful.border_y0 or 0
    local border_y1 = beautiful.border_y1 or 0

    local wa = p.workarea
    local cls = p.clients
    local num_x = screen[p.screen].selected_tag.master_count
    local mwf = screen[p.screen].selected_tag.master_width_factor
    local empty = 0
    num_x = math.max(1, num_x + 2)
    if num_x < 3 then
        num_x = 3
        empty = 2
    end
    if #cls == 0 then
        return
    end

    local minRows = 1
    local spots = #cls
    if spots < minRows*num_x then
        spots = minRows*num_x
    end

    spots = spots + empty
    rcls = {}
    for i = 1,empty,1 do
        rcls[i] = nil
    end
    for i=empty,spots,1 do
        rcls[i]=cls[i-empty]
    end

    wa.x = wa.x + border_x0
    wa.y = wa.y + border_y0
    wa.width = wa.width - border_x0 - border_x1 + gap
    wa.height = wa.height - border_y0 - border_y1 + gap

    local extra = math.floor((mwf * mwf * mwf) / 0.05)
    local width = wa.width / math.min(num_x + extra, spots + extra)
    if spots == 1 then
        width = wa.width
    end

    local topHeight = wa.height / 4
    local bottomHeight = wa.height
    local geom = {x = wa.x, y = wa.y, width = 0, height = 0}
    local _perCol = spots / num_x
    local columns = (spots - 1) % num_x
    for i = 1,spots,1 do
        local c = rcls[i]
        geom.y = wa.y
        geom.width = width
        geom.height = bottomHeight
        if i > num_x then
            local perCol = math.ceil(_perCol) - 1
            if (i - 1) % num_x > columns then
                perCol = math.floor(_perCol) - 1
            end

            geom.height = topHeight
            geom.y = wa.y
            if perCol > 0 then
                geom.height = topHeight / perCol
                geom.y = wa.y + (math.floor((i - 1) / num_x) - 1) * (topHeight / perCol)
            end
        elseif i + num_x <= spots then
            geom.height = bottomHeight - topHeight
            geom.y = wa.y + topHeight
        end

        if i % num_x == 2 then
            geom.width = geom.width + extra*width
        end

        if i == empty + 1 and empty ~= 0 then
            geom.width = wa.width
            geom.height = bottomHeight - topHeight
            geom.x = wa.x
            geom.y = wa.y + topHeight
        end

        geom.height = geom.height - gap
        geom.width = geom.width - gap
        if c ~= nil then
            geom.height = geom.height + 2 * c.border_width
            geom.width = geom.width + 2 * c.border_width
            c:geometry(geom)
        end

        -- swap master
        if empty == 0 and i== 2 then
            if c ~= nil then
                c:geometry(rcls[1]:geometry())
            end
            rcls[1]:geometry(geom)
        end

        geom.x = geom.x + geom.width + gap
        if c ~= nil then
            geom.x = geom.x + 2 * c.border_width
        end

        if i % num_x == 0 then
            geom.x = wa.x
        end

    end
end

return cols
