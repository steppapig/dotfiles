local awful = require("awful")
local wibox = require("wibox")

local spotify_widget = {}

-- Spotify D-Bus service and object paths
spotify_widget.service = "org.mpris.MediaPlayer2.spotify"
spotify_widget.object = "/org/mpris/MediaPlayer2"
spotify_widget.interface = "org.freedesktop.DBus.Properties"

function spotify_widget.create()
    local widget = wibox.widget.textbox()

    local function update_widget()
        awful.spawn.easy_async_with_shell(
            "dbus-send --print-reply --dest=" .. spotify_widget.service ..
            " " .. spotify_widget.object .. " " .. spotify_widget.interface ..
            ".Get org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'",
            function(stdout)
                local artist = string.match(stdout, "xesam:artist \"([^\"]+)\"")
                local title = string.match(stdout, "xesam:title \"([^\"]+)\"")

                if artist and title then
                    widget:set_text("♪ " .. artist .. " - " .. title)
                else
                    widget:set_text("")
                end
            end
        )
    end

    update_widget()

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            awful.spawn("playerctl play-pause")
        elseif button == 2 then
            awful.spawn("playerctl next")
        elseif button == 3 then
            awful.spawn("playerctl previous")
        end

        update_widget()
    end)

    return widget
end

return spotify_widget

