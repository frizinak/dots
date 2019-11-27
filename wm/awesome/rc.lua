require("awful.autofocus")
local awful = require("awful")
local beautiful = require("beautiful")
local friz = require("friz")
beautiful.init(require("theme"))
modkey = "Mod4"
altkey = "Mod1"
terminal = "st -e tm"

require("vars")
require("notifications")
require("mywibox")

for s = 1, screen.count() do
    local tags = awful.tag({"1", "2", "3" , "4", "5", "6", "7", "8", "9", "0"},  s, friz.layout.cols)
    for a, t in pairs(tags) do
        t.master_count = 0
        awful.tag.incmwfact(0.20, t)
    end
end

awful.rules.rules = {
    {
        rule = {},
        properties = {
            -- titlebars_enabled = true,
            -- titlebar = top_titlebar,
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            keys = require("keys"),
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            size_hints_honor = false,
            callback = function(c)
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
    end
    )

client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
    )
