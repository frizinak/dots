local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local mywibox = {}
local mypromptbox = {}
local mytaglist = {}

local w = require("widgets")

for s = 1, screen.count() do
    local scrgeo = screen[s].geometry
    mypromptbox[s] = awful.widget.prompt()

    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.noempty)

    local h = beautiful.border_y0
    if h > 15 then
        h = 15
    end
    mywibox[s] = wibox({ type = 'desktop', opacity = 1, position = "top", screen = s, height = h })
    mywibox[s].width = scrgeo.width
    mywibox[s].x = scrgeo.x
    mywibox[s].y = 0
    mywibox[s].border_width = 0

    mywibox[s].visible = true

    local pad = wibox.widget{forced_width = 10}
    local pad_large = wibox.widget{forced_width = scrgeo.width / 4}
    local spacer = wibox.widget{}

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(pad)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(pad_large)

    local center_layout = wibox.layout.flex.horizontal()
    center_layout:add(w.cputextwidget)
    center_layout:add(w.memtextwidget)
    center_layout:add(w.networkwidget)
    center_layout:add(w.voltextwidget)
    center_layout:add(w.windowsiconwidget)

    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(pad_large)

    if s == 1 then right_layout:add(wibox.widget.systray()) end

    right_layout:add(w.clockwidget)
    right_layout:add(pad)

    local layout = wibox.layout.align.horizontal(
        left_layout,
        center_layout,
        right_layout
    )

    mywibox[s]:set_widget(layout)
end

return {
    wibox = mywibox,
    promptbox = mypromptbox,
    taglist = mytaglist
}
