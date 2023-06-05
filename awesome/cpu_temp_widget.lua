-- Load required libraries
local io = require("io")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

beautiful.init("/home/tobias/.config/awesome/default/theme.lua")
-- Define the widget
local cpu_temp_widget = {}

-- Command to read CPU temperature
local temp_command = "sensors | grep 'Core 0:' | awk '{print $3}' | cut -c2-"

-- Update function to read CPU temperature
function cpu_temp_widget:update()
    awful.spawn.easy_async_with_shell(temp_command, function(stdout)
        -- Remove trailing newline character
        local cpu_temp = stdout:gsub("\n", "")
        -- Update the widget text
        self.widget:set_markup("<span font='Font Awesome 12'> </span><span font='Fira Code Nerd Font 8' rise='2000'>" .. cpu_temp .. "</span>")
    end)
end

-- Initialize the widget
function cpu_temp_widget:init()
    -- Create the widget
    self.widget = wibox.widget.textbox()

    -- Set the update interval (in seconds)
    local update_interval = 5

    -- Create a timer to update the widget periodically
    self.timer = gears.timer {
        timeout = update_interval,
        autostart = true,
        callback = function()
            self:update()
        end
    }

    self:update()
end



-- Initialize the widget
cpu_temp_widget:init()

local cpu_temp_widget_clr = wibox.widget.background()
cpu_temp_widget_clr:set_widget(cpu_temp_widget.widget)
cpu_temp_widget_clr:set_fg(beautiful.fg_focus)
cpu_temp_widget_clr:set_bg(beautiful.bg_focus)

return cpu_temp_widget_clr

