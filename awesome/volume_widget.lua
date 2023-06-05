local awful = require ("awful")
local wibox = require ("wibox")
local beautiful = require ("beautiful")

-- Create a widget to display the volume
local volume_widget = wibox.widget {
    {
        widget = wibox.widget.textbox,
        font = "FontAwesome 12", -- Font Awesome font with size 12
        id = "icon",
        align = "center",
	forced_width = 30
    },
    {
        widget = wibox.widget.textbox,
        id = "text",
        align = "right",
        font = "FiraCode Nerd Font 8" -- Fira Code Nerd Font with size 8
    },
    layout = wibox.layout.fixed.horizontal,
    forced_width = 70
}

-- Function to update the volume widget
local function update_volume()
    awful.spawn.easy_async_with_shell("amixer -D pulse sget Master", function(stdout)
        local volume_str = stdout:match("%[(%d+)%%%]")
        local mute_str = stdout:match("%[(o[nf]+)%]")
        local volume = tonumber(volume_str) or 0
        local mute = mute_str == "off"

        -- Update the volume icon and percentage based on the volume level and mute status
        local icon = volume_widget:get_children_by_id("icon")[1]
        local text = volume_widget:get_children_by_id("text")[1]

        if mute then
            icon.text = ""
	    text.text = "mute "
        elseif volume == 0 then
            icon.text = ""
            text.text = "0% "
        elseif volume <= 50 then
            icon.text = ""
            text.text = volume .. "% "
        else
            icon.text = ""
            text.text = volume .. "% "
        end
    end)
end

-- Update the volume widget initially
update_volume()


awesome.emit_signal("volume::update")

-- Register a signal handler for volume change events
awesome.connect_signal("volume::update", function()
    update_volume()
end)




local volume_widget_clr = wibox.widget.background()
volume_widget_clr:set_widget(volume_widget)
volume_widget_clr:set_fg(beautiful.fg_focus)
volume_widget_clr:set_bg(beautiful.bg_focus)

return volume_widget_clr
