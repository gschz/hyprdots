-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

-- ~/.config/hypr/hyprland.lua
-- Personal configuration migrated from hyprlang (.conf) to Lua.
-- HyDE never overwrites this file.
-- Loaded AFTER HyDE's defaults, so settings here take precedence.
-- Press SUPER + / to see active keybinds.

-- Global opacity setting for window rules.
OPACITY_DEFAULT = 0.90

-- Load local modules from ./lua/
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/lua/?.lua"

require("monitors")
require("input")
require("env")
require("window_rules")
require("layer_rules")
require("keybinds")
require("workspaces")

-- HyprGlass disabled: plugin incompatible with Hyprland 0.56.2 (SEGV).
-- Track: https://github.com/hyprnux/hyprglass/issues/60
-- Re-enable when v0.7.1+ is released with 0.56.2 support.
