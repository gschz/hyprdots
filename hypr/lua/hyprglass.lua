-- HyprGlass (Liquid Glass) - conservative test config
-- Delete this file + its require() from hyprland.lua to roll back completely.

-- Load plugin after Hyprland is fully initialized, then reload config
-- so the guard below fires with the plugin available.
if not hl.plugin.hyprglass then
	hl.on("hyprland.start", function()
		hl.exec_cmd("/usr/bin/hyprpm reload && /usr/bin/hyprctl reload")
	end)
end

-- DEBUG: check what hl.plugin contains
hl.print("[hyprglass] hl.plugin type=" .. type(hl.plugin))
if type(hl.plugin) == "table" then
	for k, v in pairs(hl.plugin) do
		hl.print("[hyprglass] hl.plugin." .. k .. " = " .. type(v))
	end
end
-- Configure only when the plugin is actually loaded into Hyprland.
if hl.plugin.hyprglass then

	hg.config({
		default_theme = "dark",
		default_preset = "subtle",
		-- let the plugin manage noblur: without it, Hyprland's
		-- blur:new_optimizations hides the glass on static windows
		manage_window_blur = true,
		-- layers (waybar/swaync) stay OFF: keeps current layer blur untouched
		layers = { enabled = false },
	})

	-- Per-window overrides: heaviest windows stay glass-free
	hl.window_rule({ match = { class = "^(firefox|librewolf|zen|brave|chromium)$" }, tag = "+hyprglass_disabled" })
	hl.window_rule({ match = { fullscreen = true }, tag = "+hyprglass_disabled" })
end