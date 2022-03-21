local awful = require("awful")
local utils = require("friz.utils")
local layout = require("friz.layout")
local wi = require("mywibox")
local w = require("widgets")
local soundcard = require("vars").soundcard
local machi = require("layout-machi")
local layouts = {machi_layout} --, layout.fair, layout.game}

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

function runDefaultPrompt()
    runPrompt(
        "> ",
        "",
        function(...) awful.spawn(...) end,
        true
    )
end

function updateVolume(value)
    return function ()
        awful.spawn.easy_async_with_shell(
            "pactl set-sink-volume '" .. soundcard .. "' " .. value,
            w.voltextwidget.update
        )
    end
end

function browser() utils.drop("qutebrowser", "center", "center", 0.9, 0.9, true) end
function chat() utils.drop("st -c homechat -e tmux new-session \\; new-window homechat \\; attach", "center", "center", 0.35, 0.6, true) end
function music() switchToHome("home-music") end
function wiki() switchToHome("home-wiki") end
function mail() switchToHome("home-mutt") end

local lastScreen = 1
local lastTag = 1

local homeStarted = false
function switchToHome(focusClass)
    if not homeStarted then
        awful.spawn(os.getenv("HOME") .. "/.bin/macro/home")
        homeStarted = true
    end
    utils.drop()
    local currentScreen = awful.screen.focused()
    local currentTag = currentScreen.selected_tags[1]
    local clients = screen[1].tags[11]:clients()
    local goback = false

    awful.screen.focus(screen[1])
    screen[1].tags[11]:view_only()

    for _, c in pairs(clients) do
        if c.class == focusClass then
            if client.focus == c then
                goback = true
                break
            end

            if not c.hidden then
                client.focus = c
            end
        end
    end

    if goback then
        awful.screen.focus(screen[lastScreen])
        screen[lastScreen].tags[lastTag]:view_only()
        return
    end

    if currentTag.index ~= 11 or currentScreen.index ~= 1 then
        lastTag = currentTag.index
        lastScreen = currentScreen.index
    end
end

function swap(dir)
    local cltbl = awful.client.visible(client.focus.screen, true)
    local grect = require("gears.geometry").rectangle
    local geomtbl = {}

    for i,cl in ipairs(cltbl) do
        geomtbl[i] = cl:geometry()
    end

    local target = grect.get_in_direction(dir, geomtbl, client.focus:geometry())

    tobe = cltbl[target]:geometry()
    is = client.focus:geometry()

    client.focus:geometry(tobe)
    cltbl[target]:geometry(is)
end

function focus(dir)
    if machi.switcher.start(client.focus).focus(dir) then
        return
    end
    utils.client.directional(dir)
end

local globalkeys = awful.util.table.join(
    awful.key({ modkey }, ".", function () machi.default_editor.start_interactive() end),
    awful.key({ modkey }, "/", function () machi.switcher.start(client.focus).ui() end),
    awful.key({ modkey }, "Tab", function () machi.switcher.start(client.focus).tab() end),
    awful.key({ modkey }, "Left", function () utils.tags.prev() end),
    awful.key({ modkey }, "Right", function () utils.tags.next() end),

    awful.key({ modkey }, "k", function() focus("up") end),
    awful.key({ modkey }, "l", function() focus("right") end),
    awful.key({ modkey }, "h", function() focus("left") end),
    awful.key({ modkey }, "j", function() focus("down") end),

    --awful.key({ modkey, "Shift" }, "h", function() swap("left") end),
    --awful.key({ modkey, "Shift" }, "j", function() swap("down") end),
    --awful.key({ modkey, "Shift" }, "k", function() swap("up") end),
    --awful.key({ modkey, "Shift" }, "l", function() swap("right") end),
    awful.key({ modkey, "Shift" }, "h", function() machi.switcher.start(client.focus).move("left") end),
    awful.key({ modkey, "Shift" }, "j", function() machi.switcher.start(client.focus).move("down") end),
    awful.key({ modkey, "Shift" }, "k", function() machi.switcher.start(client.focus).move("up") end),
    awful.key({ modkey, "Shift" }, "l", function() machi.switcher.start(client.focus).move("right") end),
    -- awful.key({ modkey, "Shift" }, "h", function() awful.client.swap.bydirection("left") end),
    -- awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.bydirection("down") end),
    -- awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.bydirection("up") end),
    -- awful.key({ modkey, "Shift" }, "l", function() awful.client.swap.bydirection("right") end),

    awful.key({ modkey, "Control" }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Control" }, "j", function() awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Control" }, "k", function() awful.tag.incnmaster(1) end),

    awful.key({ modkey, }, "z", function() nextMachiLayout() end),
    -- awful.key({ modkey, "Control" }, "Return", function() awful.client.setmaster(client.focus) end),
    awful.key({ modkey, "Control" }, "Return", function() machi.switcher.start(client.focus).master_swap(true) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey, }, "c", function() utils.drop("st -c bitstamp -e bitstamp", "center", "center", 0.8, 0.7, true) end),
    -- awful.key({ modkey, }, "m", function() utils.drop("st -c ym -e tmux new-session \\; new-window homechat music remote \\; attach", "center", "center", 0.5, 0.6, true) end),
    awful.key({ modkey, }, "m", music),
    awful.key({ modkey, }, "w", wiki),
    awful.key({ modkey, }, "x", mail),

    awful.key({ modkey, }, ";", chat),
    awful.key({ modkey, }, "space", browser),
    -- awful.key({ modkey, }, "w", function() utils.drop("st -c wiki -e bash -c \"cd ~/vimwiki && nvim +'syntax on' +VimwikiIndex\"", "center", "center", 0.2, 0.8, true) end),
    -- awful.key({ modkey, }, "b", function() utils.drop("st -c ebooks -e ebooks", "center", "center", 0.5, 0.7, true) end),
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),

    awful.key({ altkey }, "l", updateVolume("+20%")),
    awful.key({ altkey }, "k", updateVolume("+2%")),
    awful.key({ altkey }, "j", updateVolume("-2%")),
    awful.key({ altkey }, "h", updateVolume("-20%")),
    awful.key({ modkey }, "r", function() utils.drop("launcher", "center", "center", 0.5, 0.5, true) end),
    awful.key({ modkey, "Shift" }, "r", runDefaultPrompt),

    --awful.key({ modkey }, ".", function()
    --    if not homeStarted then
    --        awful.spawn(os.getenv("HOME") .. "/.bin/macro/home")
    --        homeStarted = true
    --    end
    --    switchToHome("home-music")
    --end),
    awful.key({ modkey, "Shift"}, ".", toggleHomeMode)
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
    awful.button({}, 1,  utils.client.raise),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

root.keys(globalkeys)
return clientkeys
