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

local theme = {
    border_x0 = 2 + gap,
    border_x1 = 2 + gap,
    border_y0 = 14 + gap,
    border_y1 = 2 + gap,

    border_width = border_width,
    border_normal = prim,
    border_focus  = acc,

    titlebar_size = titlebar_size,
    titlebar_position = "bottom",
    titlebar_bg_normal = prim,
    titlebar_bg_focus = acc,

    taglist_fg_focus = acc,
    taglist_bg_normal = bg,
    taglist_bg_focus = bg,

    useless_gap_width = gap,

    font = font,
    bg_normal = bg,
    bg_urgent = bg,

    fg_normal = fg,
    fg_warn = warn,
    fg_urgent = urgent,
    widget = {}
}

theme.widget = {
    color_bad = theme.fg_urgent,
    color_warn = theme.fg_warn,
    color_ok = theme.fg_normal
}

return theme
