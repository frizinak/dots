require("awful.autofocus")
local awful = require("awful")
local beautiful = require("beautiful")
local friz = require("friz")
beautiful.init(require("theme"))

modkey = "Mod4"
altkey = "Mod1"
terminal = "st -e /usr/bin/nvim +T"
homeMode = "normal"

awful.client.property.persist("machi_loc", "string")
awesome.connect_signal("exit", function ()
        local dims
        for i, c in ipairs(client.get()) do
            dims = tostring(c.width).."x"..tostring(c.height).."+"..tostring(c.x).."+"..tostring(c.y)
            awful.client.property.set(c, "machi_loc", dims)
        end
end)

local machi = require("layout-machi")
screen.connect_signal("arrange", function(scr)
    for i, c in ipairs(client.get()) do
        if not c:isvisible() then goto continue end
        if c.machi_loc_checked then goto continue end
        c.machi_loc_checked = true
        local p = awful.client.property.get(c, "machi_loc")
        if not p then goto continue end
        local t = {}
        for i in string.gmatch(p, "%d+") do;
            table.insert(t, tonumber(i));
        end;
        if #t == 4 then
            c.x, c.y, c.width, c.height = t[3], t[4], t[1], t[2]
            machi.switcher.start(c).snap_client()
        end
        ::continue::
    end
end)

require("notifications")
local wi = require("mywibox")

awful.tag.attached_connect_signal(nil, "property::selected", function (t, a)
        if t.selected then
            wi.wibox[t.screen.index].visible = t.index ~= 11
        end
end)


local machi = require("layout-machi")
machi_layout = machi.layout.create(
    {
        persistent = true,
        -- default_cmd = "v281h1111h141h1221",
        -- default_cmd = "v281h1111h141h1221",
        default_cmd = "v1,4t3h1,4,1-h1,1cct3h1,4,1-v7,1c.",
        new_placement_cb = machi.layout.placement.empty,
    }
)

for s = 1, screen.count() do
    local tags = awful.tag({"1", "2", "3" , "4", "5", "6", "7", "8", "9", "0", "home"},  s, machi_layout)
    tags[11].layout = friz.layout.fairside
    for a, t in pairs(tags) do
        t.master_count = 1
    end
end

function defRule(c)
    if beautiful.titlebar_size == 0 then
        return
    end

    awful.titlebar(c, {
        position = beautiful.titlebar_position or "top",
        size = beautiful.titlebar_size or 5,
        bg_normal = beautiful.titlebar_bg_normal,
        bg_focus = beautiful.titlebar_bg_focus
    })
end

function paintHome()
    local clients = screen[1].tags[11]:clients()
    for _, c in pairs(clients) do
        awful.rules.apply(c)
    end
end

function toggleHomeMode()
    if homeMode == "music" then
        homeMode = "normal"
        paintHome()
        return
    end

    homeMode = "music"
    paintHome()
end

function setMachiLayout(cmd)
    local screen = awful.screen.focused()
    local tag = screen.selected_tags[1]
    machi_layout.machi_set_cmd(cmd, tag, true)
end

local machi_layouts = {
    "v1,4t3h1,4,1-h1,1cct3h1,4,1-t3v2.",
    "v13h1221h1331.",
}
local machi_layout_n = 0
function nextMachiLayout()
    machi_layout_n = machi_layout_n + 1
    if machi_layout_n > #machi_layouts then
        machi_layout_n = 1
    end
    local l = machi_layouts[machi_layout_n]
    setMachiLayout(l)
end

homeWidth = -300

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
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                c.hidden = homeMode == "music"
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = (1400 + homeWidth) * wf
                local height = 600 * hf
                local x = 150 * wf
                local y = s.height - (780*hf)
                c:geometry({x = x, y = y, width = width, height = height})
                c.border_width = 30 * wf
                defRule(c)
            end,
        }
    },
    {
        rule = { class = "home-wiki" },
        properties = {
            floating = true,
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                c.hidden = homeMode == "music"
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = 670 * wf
                local height = 600 * hf
                local x = (1640 + homeWidth) * wf
                local y = s.height - (780*hf)
                c:geometry({x = x, y = y, width = width, height = height})
                c.border_width = 30 * wf
                defRule(c)
            end,
        }
    },
    {
        rule = { class = "home-daily-img-worker" },
        properties = {
            below = true,
            minimized = true,
            floating = true,
            hidden = true,
            focusable = false,
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                local width = 441
                local height = 300
                local x = 520
                local y = 1300
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { instance = "home-daily-img" },
        properties = {
            floating = true,
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = 441 * wf
                local height = 292 * hf
                local x = 520 * wf
                local y = s.height - (1300 * hf)
                c.border_width = 30 * wf
                if homeMode == "music" then
                    width = 800 * wf
                    height = width / 1.77777 * hf
                    x = s.width / 2 - width / 2 - c.border_width
                    y = s.height - (600 + 150 + 90 + 300) * wf

                    -- width = 1300 * wf
                    -- y = (600 + 150 + 90) * hf
                    -- x = s.width / 2 - width / 2 - c.border_width
                end
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-ph" },
        properties = {
            floating = true,
            no_border_focus = true,
            tag = screen[1].tags[11],
            focusable = false,
            callback = function(c)
                c.hidden = homeMode == "music"
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = 280 * wf
                local height = 306 * hf
                local x = 150 * wf
                local y = s.height - (1176 * hf)
                c:geometry({x = x, y = y, width = width, height = height})
                c.border_width = 30 * wf
            end
        }
    },
    {
        rule = { class = "home-bitstamp" },
        properties = {
            floating = true,
            no_border_focus = true,
            tag = screen[1].tags[11],
            focusable = false,
            callback = function(c)
                c.hidden = homeMode == "music"
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = 280 * wf 
                local height = 34 * hf
                local x = 150 * wf
                local y = s.height - (1300 * hf)
                c:geometry({x = x, y = y, width = width, height = height})
                c.border_width = 30 * wf
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-music" },
        properties = {
            floating = true,
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = (1260 + homeWidth) * wf
                local height = 295 * hf
                local x = 1050 * wf
                local y = s.height - (1300 * hf)
                c.border_width = 30 * wf
                if homeMode == "music" then
                    y = 90 * hf
                    height = 600 * hf
                    width = 1300 * wf
                    x = s.width / 2 - width / 2 - c.border_width
                end
                c:geometry({x = x, y = y, width = width, height = height})
            end
        }
    },
    {
        rule = { class = "home-music-info" },
        properties = {
            floating = true,
            no_border_focus = true,
            focusable = false,
            tag = screen[1].tags[11],
            callback = function(c)
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = (1790 + homeWidth) * wf
                local height = 46 * hf
                local x = 520 * wf
                local y = s.height - (918 * hf)
                c.border_width = 30 * wf
                if homeMode == "music" then
                    width = 1300 * wf
                    y = (600 + 90 + 90) * hf
                    x = s.width / 2 - width / 2 - c.border_width
                end
                c:geometry({x = x, y = y, width = width, height = height})
                defRule(c)
            end
        }
    },
    {
        rule = { class = "home-lawnsh" },
        properties = {
            floating = true,
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                c.hidden = homeMode == "music"
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = (2160 + homeWidth) * wf
                local height = 300 * hf
                local x = 150 * wf --1640 + 760 + homeWidth
                local y = s.height - (1580 * hf) - height
                c:geometry({x = x, y = y, width = width, height = height})
                c.border_width = 30 * wf
            end
        }
    },
    {
        rule = { class = "home-empty" },
        properties = {
            floating = true,
            below = true,
            focusable = false,
            no_border_focus = true,
            tag = screen[1].tags[11],
            border_width = 0,
            callback = function(c)
                c.hidden = homeMode ~= "music"
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = s.width
                local height = 2 * s.height / 3
                local x = 0
                local y = 0
                c:geometry({x = x, y = y, width = width, height = height})
            end
        }
    },
    {
        rule = { class = "home-cava" },
        properties = {
            floating = true,
            below = true,
            focusable = false,
            no_border_focus = true,
            tag = screen[1].tags[11],
            callback = function(c)
                local s = screen[c.screen].geometry
                local wf = s.width / 3840
                local hf = s.height / 2160
                local width = (2160 + homeWidth) * wf
                local height = 100 * hf
                local x = 150 * wf
                local y = s.height - (1490 * hf)
                c.border_width = 30 * wf
                if homeMode == "music" then
                    width = s.width
                    height = s.height / 3
                    x = 0
                    y = 2 * s.height / 3
                    c.border_width = 0
                end
                c:geometry({x = x, y = y, width = width, height = height})
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
    },
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
