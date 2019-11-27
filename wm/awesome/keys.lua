local awful = require("awful")
local utils = require("friz.utils")
local wi = require("mywibox")

function runPrompt(prompt, prefill, exec, isShell)
    local compl = nil
    local history = prompt
    if isShell == true then
        compl = awful.completion.shell
    end

    awful.prompt.run(
        {
            prompt = prompt,
            text = prefill ,
            textbox = wi.promptbox[mouse.screen.index].widget,
            exe_callback = exec,
            completion_callback = compl,
            history_path = awful.util.getdir("cache") .. "/" .. history
        }
    )
end

local globalkeys = awful.util.table.join(
    awful.key({ modkey }, "Left", function () utils.tags.prev() end),
    awful.key({ modkey }, "Right", function () utils.tags.next() end),

    awful.key({ modkey }, "k", function() utils.client.directional("up") end),
    awful.key({ modkey }, "l", function() utils.client.directional("right") end),
    awful.key({ modkey }, "h", function() utils.client.directional("left") end),
    awful.key({ modkey }, "j", function() utils.client.directional("down") end),

    awful.key({ modkey, "Shift" }, "h", function() awful.client.swap.bydirection("left") end),
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.bydirection("down") end),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.bydirection("up") end),
    awful.key({ modkey, "Shift" }, "l", function() awful.client.swap.bydirection("right") end),

    awful.key({ modkey, "Control" }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Control" }, "j", function() awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Control" }, "k", function() awful.tag.incnmaster(1) end),

    awful.key({ modkey, }, "z", function() awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Control" }, "Return", function() awful.client.setmaster(client.focus) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey, }, "m", function() utils.drop("st -c ym -e ym", "center", "center", 0.7, 0.6, true) end),
    awful.key({ modkey, }, "space", function() utils.drop("qutebrowser", "center", "center", 0.9, 0.9, true) end),
    awful.key({ modkey, }, "w", function() utils.drop("st -c wiki -e bash -c \"cd ~/vimwiki && nvim +'syntax on' +VimwikiIndex\"", "center", "center", 0.4, 0.4, true) end),
    awful.key({ modkey, }, "b", function() utils.drop("st -c ebooks -e ebooks", "center", "center", 0.5, 0.7, true) end),
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),

    awful.key(
        { altkey },
        "l",
        function()
            awful.spawn.easy_async_with_shell(
                "pactl set-sink-volume '" .. soundcard .. "' +20%",
                function ()
                    voltextwidget.update()
                end
            )
        end
    ),
    awful.key(
        { altkey },
        "k",
        function()
            awful.spawn.easy_async_with_shell(
                "pactl set-sink-volume '" .. soundcard .. "' +2%",
                function ()
                    voltextwidget.update()
                end
            )
        end
    ),
    awful.key(
        { altkey },
        "j",
        function()
            awful.spawn.easy_async_with_shell(
                "pactl set-sink-volume '" .. soundcard .. "' -2%",
                function ()
                    voltextwidget.update()
                end
            )
        end
    ),
    awful.key(
        { altkey },
        "h",
        function()
            awful.spawn.easy_async_with_shell(
                "pactl set-sink-volume '" .. soundcard .. "' -20%",
                function ()
                    voltextwidget.update()
                end
            )
        end
    ),
    awful.key(
        { altkey },
        "m",
        function()
            awful.spawn.easy_async_with_shell(
                "pactl set-sink-mute '" .. soundcard .. "' toggle",
                function ()
                    voltextwidget.update()
                end
            )
        end
    ),

    awful.key(
        { modkey },
        "r",
        function()
            runPrompt(
                "> ",
                "",
                function (...)
                    local result = awful.spawn(...)
                end,
                true
            )
        end
    )
)

local clientkeys = awful.util.table.join(
    awful.key({ modkey, }, "f", function(c) utils.client.toggle_maximize(c) end),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
    awful.key({ modkey, }, "n", function(c) c.minimized = true end)
)

for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(
            { modkey },
            "#" .. i + 9,
            function()
                local tag = mouse.screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end
        ),
        awful.key(
            { modkey, "Shift" },
            "#" .. i + 9,
            function()
                if not client.focus then
                    return
                end
                local tag = screen[client.focus.screen].tags[i]
                if client.focus and tag then
                    client.focus:move_to_tag(tag)
                end
            end
        )
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

root.keys(globalkeys)
return clientkeys
