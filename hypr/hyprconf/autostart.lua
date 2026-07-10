--#################
--### AUTOSTART ###
--#################

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar & hyprpaper")
    hl.exec_cmd("jetbrain-toolbox")
    hl.exec_cmd("hyprpaper")
end)
