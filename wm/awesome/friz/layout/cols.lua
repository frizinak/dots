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
    num_x = math.max(1, num_x + 3)
    if #cls == 0 then
        return
    end

    local minRows = 1
    local spots = #cls
    if spots < minRows*num_x then
        spots = minRows*num_x
    end

    wa.x = wa.x + border_x0
    wa.y = wa.y + border_y0
    wa.width = wa.width - border_x0 - border_x1 + gap
    wa.height = wa.height - border_y0 - border_y1 + gap

    local width = wa.width / math.min(num_x + 1, spots + 1)
    if spots == 1 then
        width = wa.width
    end

    local topHeight = wa.height / 4
    local bottomHeight = wa.height
    local geom = {x = wa.x, y = wa.y, width = 0, height = 0}
    local _perCol = spots / num_x
    local columns = (spots - 1) % num_x
    for i = 1,spots,1 do
        local c = cls[i]
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
            if spots > num_x then
                geom.y = geom.y 
            end
        end

        if i % num_x == 2 then
            geom.width = geom.width + width
        end


        geom.height = geom.height - gap
        geom.width = geom.width - gap
        if c ~= nil then
            geom.height = geom.height + 2 * c.border_width
            geom.width = geom.width + 2 * c.border_width
            c:geometry(geom)
        end

        -- swap master
        if i == 2 then
            if c ~= nil then
                c:geometry(cls[1]:geometry())
            end
            cls[1]:geometry(geom)
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
