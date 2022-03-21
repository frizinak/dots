local prim = colorBg
local acc = color5
local fg = colorFg
local warn = color3
local urgent = color2

local vars = require("vars")

local bg = prim
local gap = vars.gap

local titlebar_size = vars.titlebar
local border_width = vars.border
local font = font .. " " .. fontSize
if vars.fontOverride ~= "" then
    font = vars.fontOverride
end

local awful = require("awful")
local theme = {
    border_x0 = 0,
    border_x1 = 0,
    border_y0 = gap,
    border_y1 = gap / 2,

    border_width = border_width,
    border_normal = prim,
    border_focus  = acc,

    titlebar_size = titlebar_size,
    titlebar_position = "bottom",
    titlebar_bg_normal = prim,
    titlebar_bg_focus = fg,

    taglist_fg_focus = acc,
    taglist_bg_normal = bg,
    taglist_bg_focus = bg,

    useless_gap_width = gap,
    useless_gap = gap/2,

    font = font,
    bg_normal = bg,
    bg_urgent = bg,

    fg_normal = fg,
    fg_focus = fg,
    fg_warn = warn,
    fg_urgent = urgent,
    widget = {},

    machi_switcher_border_color = bg,
    machi_switcher_border_opacity = 0,

    machi_switcher_border_hl_color = color2,
    machi_switcher_border_hl_opacity = 1,

    machi_switcher_fill_color = bg,
    machi_switcher_fill_opacity = 0.3,

    machi_switcher_box_color = color2,
    machi_switcher_box_opacity = 1,
    machi_switcher_fill_hl_opacity = 1,

    machi_editor_active_color = "#ccc",
    machi_editor_active_opacity = 0.9,
    machi_editor_done_color = "#ccc",
    machi_editor_done_opacity = 0.2,
}

theme.machi_style_tabbed = function(c, tabbed)
    local t = {
        position = theme.titlebar_position or "top",
        size = theme.titlebar_size or 5,
        bg_normal = theme.titlebar_bg_normal,
        bg_focus = theme.titlebar_bg_focus,
    }
    if tabbed then
        local color = require("friz.color")
        local hsv = color.hex2hsv(color2)
        hsv.v = hsv.v - 0.5
        hsv.s = hsv.s - 0.2
        t.bg_normal = hsv.hex()
        t.bg_focus = color2
    end
    awful.titlebar(c, t)
end

theme.widget = {
    color_bad = theme.fg_urgent,
    color_warn = theme.fg_warn,
    color_ok = theme.fg_normal
}

return theme
