-- HyprGlass (Liquid Glass) - conservative config.
-- Uses the prebuilt v1.2.0 .so (built for Hyprland 0.57.2, links libaquamarine.so.15).
-- hyprpm is gone from this system (its package was removed by an update), so we
-- load the plugin binary directly instead of going through hyprpm.
-- Delete this file + its require() from hyprland.lua to roll back completely.

-- The plugin loads after Hyprland starts, so it is not available when this
-- config first runs. Load it and reload the config once it is in.
if not hl.plugin.hyprglass then
	hl.on("hyprland.start", function()
		hl.exec_cmd("/usr/bin/hyprctl plugin load " .. os.getenv("HOME") .. "/.local/share/hyprglass/hyprglass.so")
		hl.exec_cmd("/usr/bin/hyprctl reload")
	end)
end

-- Configure only when the plugin is actually loaded into Hyprland.
if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass

	-- Custom preset: inherits the built-in "glass" and cranks every dial up.
	-- Edit these numbers to taste — each has its range in the comment.
	hg.preset("boost", {
		inherits = "glass",
		glass_opacity = 0.9,             -- 0.0-1.0 overall glass opacity (1.0 = max)
		blur_strength = 1.0,             -- blur radius scale (x12 px)
		blur_iterations = 5,             -- 1-5 gaussian passes
		refraction_strength = 1.0,       -- 0.0-1.0 edge refraction
		chromatic_aberration = 0.9,      -- 0.0-1.0 spectral dispersion
		fresnel_strength = 0.9,          -- 0.0-1.0 edge glow
		specular_strength = 1.0,         -- 0.0-1.0 highlight
		edge_thickness = 0.08,           -- 0.0-0.15 bezel width
		lens_distortion = 0.6,           -- 0.0-1.0 center dome
		tint_color = 0x8899aa40,         -- RRGGBBAA, alpha = tint strength
		-- Tone mapping: keep color across wallpaper types (low sat washes out color).
		saturation = 0.85,               -- 0=grayscale, 1=full color
		vibrancy = 0.25,                 -- selective saturation boost
		contrast = 0.95,                 -- around midpoint
		-- Per-theme overrides so the glass keeps its color on dark/light wallpapers.
		dark = { saturation = 0.85, vibrancy = 0.25, contrast = 0.92, brightness = 0.85 },
		light = { saturation = 0.85, vibrancy = 0.15, contrast = 0.92, brightness = 1.10 },
	})

	hg.preset("intense", {
		inherits = "glass",
		glass_opacity = 2.0,             -- ranges are typical values, not limits
		blur_strength = 4.0,
		blur_iterations = 4,
		refraction_strength = 6.0,       -- "glass" itself uses 8.0
		dark  = { brightness = 1.0, saturation = 0.6, contrast = 1.4, adaptive_dim = 0.2 },
		light = { brightness = 1.0, saturation = 0.3, contrast = 1.0, adaptive_dim = 0.0 },
	})

	hg.config({
		default_theme = "dark",
		default_preset = "intense",
		-- let the plugin manage noblur: without it, Hyprland's
		-- blur:new_optimizations hides the glass on static windows
		manage_window_blur = true,
		-- layers (waybar/swaync) stay OFF: keeps current layer blur untouched
		layers = { enabled = false },
	})

	-- Per-window overrides: heaviest windows stay glass-free.
	-- NOTE: no fullscreen rule here. Hyprland's fullscreen match tagged every
	-- maximized window as disabled, killing the glass in daily use.
	hl.window_rule({ match = { class = "^(firefox|librewolf|zen|brave-browser|chromium)$" }, tag = "+hyprglass_disabled" })
end
