local timer = require("gears").timer
local async = require("awful").spawn.easy_async_with_shell
local wibox = require("wibox")

local function worker(args)
    local base = {}
    local args = args or {}
    local timeout = args.timeout or 5
    local cmd = args.cmd or ""
    local always = args.always or false
    local settings = args.settings or function() end
    local running = false

    base.widget = wibox.widget.textbox('')
    function base.update()
        if cmd == "noop" then
            widget = base.widget
            settings()
            return
        end

        if running then
            return
        end
        running = true
        async(cmd, function (out)
            running = false
            output = out
            if output ~= base.prev or always then
                widget = base.widget
                settings()
                base.prev = output
            end
        end)
    end

    timer{
        timeout = timeout,
        call_now = true,
        autostart = true,
        callback = base.update
    }

    return setmetatable(base, { __index = base.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
