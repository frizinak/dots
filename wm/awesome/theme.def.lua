local prim = colorBg
local acc = color6
local fg = colorFg
local warn = color3
local urgent = color2

local bg = prim
local gap = 10

local titlebar_size = 3
local border_width = 0
if gap == 0 then
    titlebar_size = 0
    border_width = 2
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

    font = font .. "-ttf 20px",
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
