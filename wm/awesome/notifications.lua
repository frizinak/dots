local beautiful = require("beautiful")
local naughtyconf = require("naughty").config

naughtyconf.mapping = {
    {{urgency = "\0", icon_size = 40}, naughtyconf.presets.low},
    {{urgency = "\1", icon_size = 40}, naughtyconf.presets.normal},
    {{urgency = "\2", icon_size = 40}, naughtyconf.presets.critical}
}

for _, preset in pairs(naughtyconf.presets) do
    preset.font = beautiful.font
    preset.border_width = beautiful.border_width
    preset.fg = beautiful.border_focus
    preset.margin = "20"
    preset.width = 900
    preset.height = 64 + 40 + beautiful.border_width
    preset.bg = beautiful.taglist_bg_normal
    preset.border_color = beautiful.border_focus
end

naughtyconf.presets.critical.border_color = beautiful.fg_urgent
naughtyconf.presets.critical.fg = beautiful.fg_urgent
naughtyconf.presets.critical.width = 1800
