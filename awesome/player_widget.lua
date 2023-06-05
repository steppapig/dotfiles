local awful = require ("awful")
local wibox = require ("wibox")
local beautiful = require ("beautiful")

-- Create spotify widget
local myplayer_text = wibox.widget.textbox()

-- Function to update the widget with the current song metadata
local function updatePlayerText(line)
  myplayer_text:set_text(line:gsub('<Playing>', ''):gsub('<.+> ', ' ') .. (' '))
end

-- Fetch the current song metadata when the widget is created
awful.spawn.with_line_callback(
  "playerctl metadata --format ' {{artist}} <{{status}}> {{title}}'",
  {stdout = updatePlayerText}
)

-- Subscribe to changes in song metadata and update the widget accordingly
awful.spawn.with_line_callback(
  "playerctl --follow metadata --format ' {{artist}} <{{status}}> {{title}}'",
  {stdout = updatePlayerText}
)

local player_text_clr = wibox.widget.background()
player_text_clr:set_widget(myplayer_text)
player_text_clr:set_bg(beautiful.bg_focus)
player_text_clr:set_fg(beautiful.fg_focus)

return player_text_clr
