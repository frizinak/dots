require("awful.autofocus")
local awful = require("awful")
local beautiful = require("beautiful")
local friz = require("friz")
beautiful.init(require("theme"))
modkey = "Mod4"
altkey = "Mod1"
terminal = "st -e tm"

require("notifications")
local wi = require("mywibox")

awful.tag.attached_connect_signal(nil, "property::selected", function (t, a)
        if t.selected then
            wi.wibox[t.screen.index].visible = t.index ~= 1
        end
end)

for s = 1, screen.count() do
    local tags = awful.tag({"1", "2", "3" , "4", "5", "6", "7", "8", "9", "0"},  s, friz.layout.cols)
    tags[1].layout = friz.layout.fairside
    for a, t in pairs(tags) do
        t.master_count = 1
    end
end

function defRule(c)
    if beautiful.titlebar_size == 0 then
        return
    end

    local top_titlebar = awful.titlebar(c, {
        position = beautiful.titlebar_position or "top",
        size = beautiful.titlebar_size or 5,
        bg_normal = beautiful.titlebar_bg_normal,
        bg_focus = beautiful.titlebar_bg_focus
    })
end

awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            keys = require("keys"),
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            size_hints_honor = false,
            callback = defRule,
        }
    },
    {
        rule = { class = "home-mutt" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 1400
                local height = 600
                local x = 150
                local y = screen[c.screen].geometry.height - 780
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end,
        }
    },
    {
        rule = { class = "home-wiki" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 670
                local height = 600
                local x = 1640
                local y = screen[c.screen].geometry.height - 780
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end,
        }
    },
    {
        rule = { class = "home-daily-img" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 441
                local height = 300
                local x = 150
                local y = screen[c.screen].geometry.height - 1300
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-clock" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 280
                local height = 38
                local x = 681
                local y = screen[c.screen].geometry.height - 1300
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-ph" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 280
                local height = 58
                local x = 681
                local y = screen[c.screen].geometry.height - 1172
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-bitstamp" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 280
                local height = 24
                local x = 681
                local y = screen[c.screen].geometry.height - 1024
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-music" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 1260
                local height = 300
                local x = 1050
                local y = screen[c.screen].geometry.height - 1300
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-music-info" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 2160
                local height = 40
                local x = 150
                local y = screen[c.screen].geometry.height - 910
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-cava" },
        properties = {
            floating = true,
            border_width = 30,
            no_border_focus = true,
            tag = screen[1].tags[1],
            callback = function(c)
                local width = 2160
                local height = 100
                local x = 150
                local y = screen[c.screen].geometry.height - 1490
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "qute-edit" },
        properties = {
            floating = true,
            ontop = true,
            above = true,
            focus = true,
            callback = function(c)
                local width = 1400
                local height = 900
                local x = screen[c.screen].geometry.width / 2 - width / 2
                local y = screen[c.screen].geometry.height / 2 - height / 2
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "clipmenu" },
        properties = {
            floating = true,
            ontop = true,
            above = true,
            focus = true,
            callback = function(c)
                local width = 1200
                local height = 800
                local x = screen[c.screen].geometry.width / 2 - width / 2
                local y = screen[c.screen].geometry.height / 2 - height / 2
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    }
}

client.connect_signal(
    "manage",
    function(c, startup)
        if not startup and not c.size_hints.user_position
            and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
        if startup then
            return
        end
        awful.client.setslave(c)
        friz.utils.client.raise(c, true)
    end
    )

client.connect_signal(
    "focus",
    function(c)
        c:raise()
        c.border_color = beautiful.border_focus
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        end
        if c.no_border_focus then
            c.border_color = beautiful.border_normal
        end
    end
    )

client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
    )
