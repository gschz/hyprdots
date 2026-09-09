-- ~/.config/hypr/lua/input.lua
-- Input + decoration configuration (migrated from userprefs.conf + hyprland.conf)

hl.config({
	general = {
		border_size = 0,
		col = {
			active_border = "rgba(e0e0ff80)",
			inactive_border = "rgba(40406040)",
		},
	},
	input = {
		kb_layout = "us",
		kb_variant = "intl",
		follow_mouse = 1,
		numlock_by_default = true,
		sensitivity = 0.5,
		force_no_accel = false,
		touchpad = {
			natural_scroll = true,
		},
	},
	decoration = {
		rounding = 14,
		active_opacity = 0.90,
		inactive_opacity = 0.90,
		-- hyprglass requires the shadow decoration in the render pipeline
		-- (range 0 keeps it invisible): without it the glass effect does not render.
		shadow = { enabled = 1, range = 0, },

		blur = {
			enabled = 1,
			size = 6,
			passes = 4,
			noise = 0.2,
			contrast = 1.0,
			new_optimizations = 0,
		},
	},
})
