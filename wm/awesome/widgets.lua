local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local widgets = require("friz.widgets")
local load = {"0.0GHz", "0", "0", "0", "", "0.00", "0.00B"}
local windowsUp = ""
local gpuInUse = ""
local soundcard = require("vars").soundcard

function split(input)
    local t={}
    for str in string.gmatch(input, "([^%s]+)") do
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
            local cpu = tonumber(load[2])
            local temp = tonumber(load[3])
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
                    load[1],
                    tempColor,
                    load[3],
                    loadColor,
                    load[2]
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
            local pct = tonumber(load[4])
            local color = beautiful.widget.color_bad
            if pct < 70 then
                color = beautiful.widget.color_ok
            elseif pct < 80 then
                color = beautiful.widget.color_warn
            end

            widget:set_markup(
                string.format(
                    "%s <span color=\"%s\">%s%%</span>",
                    load[5],
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
            widget:set_markup(
                string.format(
                    "%s %s",
                    load[6],
                    load[7]
                )
            )
        end
    }
)


local windowsiconwidget = widgets.base(
    {
        cmd = "noop",
        always = true,
        timeout = 0.5,
        settings = function()
            widget:set_markup(
                string.format(
                    "%s %s",
                    windowsUp,
                    gpuInUse
                )
            )
        end
    }
)

widgets.base(
    {
        cmd = "cat /tmp/vm-win10-status",
        timeout = 1,
        settings = function()
            local color = beautiful.widget.color_ok
            if string.sub(output, 1, 4) == "pong" then
                color = beautiful.widget.color_bad
            elseif string.sub(output, 1, 2) == "Up" then
                color = beautiful.widget.color_warn
            end

            windowsUp = string.format(
                "<span color=\"%s\" size=\"x-small\"><b>💻</b></span>",
                color
            )
        end
    }
)

widgets.base(
    {
        cmd = "lsmod | grep -e nvidia_uvm -e nvida_drm | awk '{print $3}'",
        timeout = 1,
        settings = function()
            local s = split(output)
            local inUse = false
            for _, n in pairs(s) do
                if tonumber(n) > 4 then
                    inUse = true
                    break
                end
            end

            local color = beautiful.widget.color_ok
            if inUse then
                color = beautiful.widget.color_bad
            end

            gpuInUse = string.format(
                "<span color=\"%s\" size=\"x-small\"><b>⏿</b></span>",
                color
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
    windowsiconwidget = windowsiconwidget,
}
