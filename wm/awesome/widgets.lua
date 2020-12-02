local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local widgets = require("friz.widgets")
local load = {}
local soundcard = require("vars").soundcard

function split(input)
    local t={}
    for str in string.gmatch(input, "([^\n]+)") do
        table.insert(t, str)
    end
    return t
end

local clockwidget = wibox.widget.textclock("%d-%m %H:%M:%S", 0.5)
local voltextwidget = widgets.base(
    {
        cmd = "pactl list sinks | grep -A20 \"Name: " .. soundcard .. "$\" | " ..
                "tr '\\n' ' ' | grep -v 'Mute: yes.*' | " ..
                "grep -Eo 'Volume:.*:' | grep -Eo '[0-9\\.]+%' | " ..
                "head -n1 | cut -d% -f1",
        timeout = 5,
        settings = function()
            if output == "" then
                output = 0
            end
            output = math.floor(output)
            if output > 100 then
                awful.spawn.with_shell("pactl set-sink-volume '" .. soundcard .. "' 100%")
                output = 100
            end
            widget:set_markup(string.format("%s%% ", output))
        end
    }
)

widgets.base(
    {
        cmd = "cat /tmp/load.log",
        timeout = 0.5,
        settings = function ()
            local cur = split(output)
            if #cur >= 7 then
                load = cur
            end
        end
    }
)

local cputextwidget = widgets.base(
    {
        cmd = "noop",
        timeout = 0.5,
        settings = function ()
            if load[3] == nil then
                return
            end
            local cpu = tonumber(load[2]:sub(7))
            local temp = tonumber(load[3]:sub(7))
            local loadColor = beautiful.widget.color_bad
            if cpu < 30 then
                loadColor = beautiful.widget.color_ok
            elseif cpu < 50 then
                loadColor = beautiful.widget.color_warn
            end

            local tempColor = beautiful.widget.color_bad
            if temp < 60 then
                tempColor = beautiful.widget.color_ok
            elseif temp < 75 then
                tempColor = beautiful.widget.color_warn
            end

            widget:set_markup(
                string.format(
                    "%s <span color=\"%s\">%s°</span> <span color=\"%s\">%s%%</span>",
                    load[1]:sub(8),
                    tempColor,
                    temp,
                    loadColor,
                    cpu
                )
            )
        end
    }
)


local memtextwidget = widgets.base(
    {
        cmd = "noop",
        timeout = 1,
        settings = function()
            if load[4] == nil then
                return
            end
            local pct = tonumber(load[4]:sub(10))
            local color = beautiful.widget.color_bad
            if pct < 70 then
                color = beautiful.widget.color_ok
            elseif pct < 80 then
                color = beautiful.widget.color_warn
            end

            widget:set_markup(
                string.format(
                    "%s <span color=\"%s\">%s%%</span>",
                    load[5]:sub(6),
                    color,
                    pct
                )
            )
        end
    }
)

local networkwidget = widgets.base(
    {
        cmd = "noop",
        timeout = 1,
        settings = function()
            if load[7] == nil then
                return
            end
            widget:set_markup(
                string.format(
                    "%s %s",
                    load[6]:sub(8),
                    load[7]:sub(10)
                )
            )
        end
    }
)

return {
    clockwidget  = clockwidget,
    voltextwidget = voltextwidget,
    cputextwidget = cputextwidget,
    memtextwidget = memtextwidget,
    networkwidget = networkwidget,
}
