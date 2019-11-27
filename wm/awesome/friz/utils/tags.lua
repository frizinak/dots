local awful = require("awful")

function seltag(dir)
    local s = mouse.screen or 1
    local scr = screen[mouse.screen or 1]
    local n = scr.selected_tag.index
    local i = n
    while true do
        i = i + dir
        if i < 1 then
            i = #scr.tags
        elseif i > #scr.tags then
            i = 1
        end
        if i == n then
            break
        end

        for _, c in pairs(scr.tags[i].clients(scr.tags[i])) do
            if c.minimized == false then
                scr.tags[i]:view_only()
                return
            end
        end
    end
end

return {
    prev = function () seltag(-1) end,
    next = function () seltag(1) end
}
