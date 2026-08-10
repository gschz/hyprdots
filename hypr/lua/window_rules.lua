-- ~/.config/hypr/lua/window_rules.lua
-- All window rules: opacity, float, idle inhibit, picture-in-picture, jetbrains (migrated from windowrules.conf)

-- Idle inhibit for media players and browsers
hl.window_rule({
	name = "idle_inhibit_media",
	match = {
		class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$|^(.*[Ss]potify.*)$|^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$",
	},
	idle_inhibit = "fullscreen",
})

-- Picture-in-Picture
hl.window_rule({
	name = "hyde_picture_in_picture",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	tag = "+hyde_picture_in_picture",
	float = true,
	keep_aspect_ratio = true,
	move = "(monitor_w*0.72) (monitor_h*0.72)",
	size = "(monitor_w*0.25) (monitor_h*0.25)",
	pin = true,
})

-- Opacity rules: all apps share the global OPACITY_DEFAULT value except Blender (fully opaque)
local opacity_classes = {
	"^(firefox)$",
	"^(zen)$",
	"^(brave-browser)$",
	"^(com.github.rafostar.Clapper)$",
	"^(code-oss)$",
	"^([Cc]ode)$",
	"^(code-url-handler)$",
	"^(code-insiders-url-handler)$",

	"^(org.kde.dolphin)$",
	"^(org.kde.ark)$",
	"^(nwg-look)$",
	"^(qt5ct)$",
	"^(qt6ct)$",
	"^(kvantummanager)$",
	"^(com.github.tchx84.Flatseal)$",
	"^(hu.kramo.Cartridges)$",
	"^(com.obsproject.Studio)$",
	"^(gnome-boxes)$",
	"^(vesktop)$",
	"^(discord)$",
	"^(WebCord)$",
	"^(ArmCord)$",
	"^(app.drey.Warp)$",
	"^(net.davidotek.pupgui2)$",
	"^(yad)$",
	"^(Signal)$",
	"^(io.github.alainm23.planify)$",
	"^(io.gitlab.theevilskeleton.Upscaler)$",
	"^(com.github.unrud.VideoDownloader)$",
	"^(io.gitlab.adhami3310.Impression)$",
	"^(io.missioncenter.MissionCenter)$",
	"^(io.github.flattool.Warehouse)$",
	"^(org.pulseaudio.pavucontrol)$",
	"^(blueman-manager)$",
	"^(nm-applet)$",
	"^(nm-connection-editor)$",
	"^(hyprpolkitagent)$",
	"^(org.freedesktop.impl.portal.desktop.gtk)$",
	"^(org.freedesktop.impl.portal.desktop.hyprland)$",
	"^([Ss]team)$",
	"^(steamwebhelper)$",
}

local opacity_value = string.format("%.2f %.2f 1", OPACITY_DEFAULT, OPACITY_DEFAULT)

for _, class in ipairs(opacity_classes) do
	hl.window_rule({
		name = "opacity_" .. class:gsub("[%^%$%(%)%%.]", "_"),
		match = { class = class },
		opacity = opacity_value,
	})
end

hl.window_rule({
	name = "opacity_spotify_free",
	match = { initial_title = "^(Spotify Free)$" },
	opacity = opacity_value,
})

hl.window_rule({
	name = "opacity_spotify_premium",
	match = { initial_title = "^(Spotify Premium)$" },
	opacity = opacity_value,
})

hl.window_rule({
	name = "opacity_blender",
	match = { class = "^(blender)$" },
	opacity = "1.00 1.00 1",
})

-- Float rules
local float_classes = {
	"^(Signal)$",
	"^(com.github.rafostar.Clapper)$",
	"^(app.drey.Warp)$",
	"^(net.davidotek.pupgui2)$",
	"^(yad)$",
	"^(eog)$",
	"^(io.github.alainm23.planify)$",
	"^(io.gitlab.theevilskeleton.Upscaler)$",
	"^(com.github.unrud.VideoDownloader)$",
	"^(io.gitlab.adhami3310.Impression)$",
	"^(io.missioncenter.MissionCenter)$",
	"^(io.github.flattool.Warehouse)$",
}

for _, class in ipairs(float_classes) do
	hl.window_rule({
		name = "float_" .. class:gsub("[%^%$%(%)%%.]", "_"),
		match = { class = class },
		float = true,
	})
end

hl.window_rule({
	name = "float_steam_friends",
	match = { title = "^(Friends List)$" },
	float = true,
})

hl.window_rule({
	name = "float_steam_settings",
	match = { title = "^(Steam Settings)$" },
	float = true,
})

hl.window_rule({
	name = "float_blender_image_editor",
	match = { initial_title = "^(Image Editor)$", class = "^(blender)$" },
	float = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

-- JetBrains IDE workaround
hl.window_rule({
	name = "jetbrains_no_initial_focus",
	match = { class = "^(.*jetbrains.*)$", title = "^(win[0-9]+)$" },
	no_initial_focus = true,
})

-- Special opacity rules for specific applications
hl.window_rule({
	name = "custom_opacity_spotify",
	match = { class = "^([Ss]potify)$" },
	opacity = "0.75 0.75 1",
})

hl.window_rule({
	name = "custom_opacity_kitty",
	match = { class = "^(kitty)$" },
	opacity = "0.70 0.70 1",
	blur = true,
})
