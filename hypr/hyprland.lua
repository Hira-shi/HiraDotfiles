--##########################################################
--
--                      Hirashi Config
--                Manual Lua migration for Hyprland
--
--##########################################################

local home = os.getenv("HOME") or "~"
local config_dir = home .. "/.config/hypr"
package.path = package.path .. ";" .. config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua"

-- Main config
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        background_color = "rgb(1e1e2e)",
    },
})

-- Monitors
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = "1",
})

-- Split configuration files
require("hyprconf.autostart")
require("hyprconf.envvariable")
require("hyprconf.permissions")
require("hyprconf.lookandfeel")
require("hyprconf.input")
require("hyprconf.keybindings")
require("hyprconf.workspaces")
