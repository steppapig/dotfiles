local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

-- Create Mullvad widget
local mullvad_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = "FontAwesome 12",
    unlockedGlyph = "  ", -- Unlocked/disconnected glyph
    lockedGlyph = "  " -- Locked/connected glyph
}


local mullvad_widgetBg = wibox.widget.background()
mullvad_widgetBg:set_widget(mullvad_widget)

local status = "disconnected"

-- Function to execute the command and retrieve Mullvad's status
local function getMullvadStatus()
    local cmd = "mullvad status"
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    -- Parse the output to get the status
    local status = "disconnected"
    if string.match(result, "Connected to") then
        status = "connected"
    end

    -- Update the status and widget glyph if it has changed
    if status == "connected" then
        mullvad_widget.text = mullvad_widget.lockedGlyph -- Update to locked glyph
        mullvad_widgetBg:set_bg(beautiful.bg_focus) -- Invert background color when connected
        mullvad_widgetBg:set_fg(beautiful.fg_focus) -- Invert text color when connected
    elseif status == "disconnected" then
        mullvad_widget.text = mullvad_widget.unlockedGlyph -- Update to unlocked glyph
        mullvad_widgetBg:set_bg(beautiful.fg_focus) -- Reset background color when disconnected
        mullvad_widgetBg:set_fg(beautiful.bg_focus) -- Reset text color when disconnected
    end

    awesome.emit_signal("mullvad::update")
end



-- Handle click event
mullvad_widgetBg:connect_signal("button::release", function(_, _, _, button)
    if button == 1 then
        -- Left mouse button clicked, toggle the connection status
        if status == "connected" then
            -- Disconnect from Mullvad
            awful.spawn("mullvad disconnect", false) -- Example: Disconnect from Mullvad
            status = "disconnected"
            mullvad_widget.text = mullvad_widget.unlockedGlyph -- Update to unlocked glyph
            mullvad_widgetBg:set_bg(beautiful.fg_focus) -- Reset background color when disconnected
            mullvad_widgetBg:set_fg(beautiful.bg_focus) -- Reset text color when disconnected
        elseif status == "disconnected" then
            -- Connect to Mullvad
            awful.spawn("mullvad connect", false) -- Example: Connect to Mullvad
            status = "connected"
            mullvad_widget.text = mullvad_widget.lockedGlyph -- Update to locked glyph
            mullvad_widgetBg:set_bg(beautiful.bg_focus) -- Invert background
            mullvad_widgetBg:set_fg(beautiful.fg_focus) -- Invert text color when connected
        end
    end
end)

-- Initial update of the widget
getMullvadStatus()

awesome.connect_signal("mullvad_update", function()
	getMullvadStatus()
end)


return mullvad_widgetBg
