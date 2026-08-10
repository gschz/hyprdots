-- ~/.config/hypr/lua/keybinds.lua
-- All keybindings (migrated from keybindings.conf)
--
-- NOTE: HyDE already provides most of these defaults in
-- ~/.local/share/hypr/lua/key_binds.lua. The binds below
-- reproduce your personal configuration so they take precedence.
-- If a key combo is duplicated with different flags, both binds
-- will stay active. Use SUPER + / to inspect loaded binds.

local MOD = hyde.config.modifiers.main

-- Window Management
hl.bind(MOD .. " + Q", hl.dsp.window.kill(), { description = "[Window Management] close focused window" })
hl.bind("ALT + F4", hl.dsp.window.kill(), { description = "[Window Management] close focused window" })
hl.bind(
	MOD .. " + Delete",
	hl.dsp.exec_cmd("hyde-shell logout"),
	{ description = "[Window Management] kill hyprland session" }
)
hl.bind(
	MOD .. " + W",
	hl.dsp.window.float({ action = "toggle" }),
	{ description = "[Window Management] Toggle floating" }
)
hl.bind(MOD .. " + G", hl.dsp.group.toggle(), { description = "[Window Management] toggle group" })
hl.bind(
	"SHIFT + F11",
	hl.dsp.window.fullscreen_state({ internal = 1, client = 1 }),
	{ description = "[Window Management] toggle fullscreen" }
)
hl.bind(MOD .. " + L", hl.dsp.exec_cmd(hyde.sh.session.lock()), { description = "[Window Management] lock screen" })
hl.bind(
	MOD .. " + SHIFT + F",
	hl.dsp.exec_cmd(hyde.sh.window.pin()),
	{ description = "[Window Management] toggle pin on focused window" }
)
hl.bind(
	"CONTROL + ALT + DELETE",
	hl.dsp.exec_cmd(hyde.sh.session.logout.launcher()),
	{ description = "[Window Management] logout menu" }
)

-- WARNING: This binding behaves differently in the Lua config.
-- "ALT_R + CONTROL_R" resolves to a bare right Control key in Hyprland's Lua binder.
-- HyDE moved this action to SUPER + CTRL + B. Migrate if it acts weird.
hl.bind(
	"ALT_R + CONTROL_R",
	hl.dsp.exec_cmd(hyde.sh.waybar("--hide")),
	{ description = "[Window Management] toggle waybar and reload config" }
)

-- Group Navigation
hl.bind(
	MOD .. " + CONTROL + H",
	hl.dsp.group.prev(),
	{ description = "[Window Management|Group Navigation] change active group backwards" }
)
hl.bind(
	MOD .. " + CONTROL + L",
	hl.dsp.group.next(),
	{ description = "[Window Management|Group Navigation] change active group forwards" }
)

-- Change focus
hl.bind(
	MOD .. " + Left",
	hl.dsp.focus({ direction = "left" }),
	{ description = "[Window Management|Change focus] focus left" }
)
hl.bind(
	MOD .. " + Right",
	hl.dsp.focus({ direction = "right" }),
	{ description = "[Window Management|Change focus] focus right" }
)
hl.bind(
	MOD .. " + Up",
	hl.dsp.focus({ direction = "up" }),
	{ description = "[Window Management|Change focus] focus up" }
)
hl.bind(
	MOD .. " + Down",
	hl.dsp.focus({ direction = "down" }),
	{ description = "[Window Management|Change focus] focus down" }
)
hl.bind(
	"ALT + TAB",
	hl.dsp.exec_cmd('hyprctl --batch "dispatch cyclenext ; dispatch alterzorder top"'),
	{ description = "[Window Management|Change focus] Cycle focus" }
)

-- Resize Active Window
hl.bind(
	MOD .. " + SHIFT + RIGHT",
	hl.dsp.window.resize({ x = 30, y = 0, relative = true }),
	{ description = "[Window Management|Resize Active Window] resize window right", repeating = true }
)
hl.bind(
	MOD .. " + SHIFT + LEFT",
	hl.dsp.window.resize({ x = -30, y = 0, relative = true }),
	{ description = "[Window Management|Resize Active Window] resize window left", repeating = true }
)
hl.bind(
	MOD .. " + SHIFT + UP",
	hl.dsp.window.resize({ x = 0, y = -30, relative = true }),
	{ description = "[Window Management|Resize Active Window] resize window up", repeating = true }
)
hl.bind(
	MOD .. " + SHIFT + DOWN",
	hl.dsp.window.resize({ x = 0, y = 30, relative = true }),
	{ description = "[Window Management|Resize Active Window] resize window down", repeating = true }
)

-- Move active window across workspace (same logic as HyDE default)
local function move_active_window(dir, pix)
	local lut = { l = { -1, 0 }, r = { 1, 0 }, u = { 0, -1 }, d = { 0, 1 } }
	lut.left, lut.right, lut.up, lut.down = lut.l, lut.r, lut.u, lut.d
	local m = lut[dir]
	return function()
		local args = hl.get_active_window().floating and { x = m[1] * pix, y = m[2] * pix, relative = true }
			or { direction = dir }
		hl.dispatch(hl.dsp.window.move(args))
	end
end

hl.bind(
	MOD .. " + SHIFT + CONTROL + LEFT",
	move_active_window("l", 30),
	{ description = "[Window Management|Move active window] left", repeating = true }
)
hl.bind(
	MOD .. " + SHIFT + CONTROL + RIGHT",
	move_active_window("r", 30),
	{ description = "[Window Management|Move active window] right", repeating = true }
)
hl.bind(
	MOD .. " + SHIFT + CONTROL + UP",
	move_active_window("u", 30),
	{ description = "[Window Management|Move active window] up", repeating = true }
)
hl.bind(
	MOD .. " + SHIFT + CONTROL + DOWN",
	move_active_window("d", 30),
	{ description = "[Window Management|Move active window] down", repeating = true }
)

-- Move/Resize with mouse
hl.bind(
	MOD .. " + mouse:272",
	hl.dsp.window.drag(),
	{ description = "[Window Management|Move & Resize with mouse] hold to move window", mouse = true }
)
hl.bind(
	MOD .. " + mouse:273",
	hl.dsp.window.resize(),
	{ description = "[Window Management|Move & Resize with mouse] hold to resize window", mouse = true }
)
hl.bind(
	MOD .. " + Z",
	hl.dsp.window.drag(),
	{ description = "[Window Management|Move & Resize with mouse] hold to move window", mouse = true }
)
hl.bind(
	MOD .. " + X",
	hl.dsp.window.resize(),
	{ description = "[Window Management|Move & Resize with mouse] hold to resize window", mouse = true }
)

-- Toggle focused window split
hl.bind(MOD .. " + J", hl.dsp.layout("togglesplit"), { description = "[Window Management] toggle split" })

-- Launcher | Apps
hl.bind(MOD .. " + T", hl.dsp.exec_cmd(hyde.config.app.terminal), { description = "[Launcher|Apps] terminal emulator" })
hl.bind(
	MOD .. " + ALT + T",
	hl.dsp.exec_cmd("hyde-shell pypr toggle console"),
	{ description = "[Launcher|Apps] dropdown terminal" }
)
hl.bind(MOD .. " + E", hl.dsp.exec_cmd(hyde.config.app.explorer), { description = "[Launcher|Apps] file explorer" })
hl.bind(MOD .. " + C", hl.dsp.exec_cmd(hyde.config.app.editor), { description = "[Launcher|Apps] text editor" })
hl.bind(MOD .. " + B", hl.dsp.exec_cmd(hyde.config.app.browser), { description = "[Launcher|Apps] web browser" })
hl.bind(
	"CONTROL + SHIFT + ESCAPE",
	hl.dsp.exec_cmd("hyde-shell system.monitor"),
	{ description = "[Launcher|Apps] system monitor" }
)

-- Launcher | Rofi menus
hl.bind(
	MOD .. " + A",
	hl.dsp.exec_cmd(hyde.sh.menu.apps()),
	{ description = "[Launcher|Rofi menus] application finder" }
)
hl.bind(
	MOD .. " + TAB",
	hl.dsp.exec_cmd(hyde.sh.menu.windows()),
	{ description = "[Launcher|Rofi menus] window switcher" }
)
hl.bind(
	MOD .. " + SHIFT + E",
	hl.dsp.exec_cmd(hyde.sh.menu.files()),
	{ description = "[Launcher|Rofi menus] file finder" }
)
hl.bind(
	MOD .. " + slash",
	hl.dsp.exec_cmd(hyde.sh.menu.binds()),
	{ description = "[Launcher|Rofi menus] keybindings hint" }
)
hl.bind(
	MOD .. " + comma",
	hl.dsp.exec_cmd(hyde.sh.menu.emoji()),
	{ description = "[Launcher|Rofi menus] emoji picker" }
)
hl.bind(
	MOD .. " + period",
	hl.dsp.exec_cmd(hyde.sh.menu.glyph()),
	{ description = "[Launcher|Rofi menus] glyph picker" }
)
hl.bind(MOD .. " + V", hl.dsp.exec_cmd(hyde.sh.menu.clipboard()), { description = "[Launcher|Rofi menus] clipboard" })
hl.bind(
	MOD .. " + SHIFT + V",
	hl.dsp.exec_cmd(hyde.sh.menu.cliphist()),
	{ description = "[Launcher|Rofi menus] clipboard manager" }
)
hl.bind(
	MOD .. " + SHIFT + A",
	hl.dsp.exec_cmd(hyde.sh.menu.launcher()),
	{ description = "[Launcher|Rofi menus] select rofi launcher" }
)

-- Hardware Controls | Audio
hl.bind(
	"F10",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "m")),
	{ description = "[Hardware Controls|Audio] toggle mute output", locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "m")),
	{ description = "[Hardware Controls|Audio] toggle mute output", locked = true }
)
hl.bind(
	"F11",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "d")),
	{ description = "[Hardware Controls|Audio] decrease volume", locked = true, repeating = true }
)
hl.bind(
	"F12",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "i")),
	{ description = "[Hardware Controls|Audio] increase volume", locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "d")),
	{ description = "[Hardware Controls|Audio] decrease volume", locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "i")),
	{ description = "[Hardware Controls|Audio] increase volume", locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(hyde.sh.volumecontrol("-i", "m")),
	{ description = "[Hardware Controls|Audio] un/mute microphone", locked = true }
)

-- Hardware Controls | Media
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd("playerctl play-pause"),
	{ description = "[Hardware Controls|Media] play media", locked = true }
)
hl.bind(
	"XF86AudioPause",
	hl.dsp.exec_cmd("playerctl play-pause"),
	{ description = "[Hardware Controls|Media] pause media", locked = true }
)
hl.bind(
	"XF86AudioNext",
	hl.dsp.exec_cmd("playerctl next"),
	{ description = "[Hardware Controls|Media] next media", locked = true }
)
hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd("playerctl previous"),
	{ description = "[Hardware Controls|Media] previous media", locked = true }
)
hl.bind(
	MOD .. " + CONTROL + M",
	hl.dsp.exec_cmd(hyde.sh.window.mute()),
	{ description = "[Hardware Controls|Media] toggle mute/unmute for active-window" }
)

-- Hardware Controls | Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(hyde.sh.brightnesscontrol("-i")),
	{ description = "[Hardware Controls|Brightness] increase brightness", locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(hyde.sh.brightnesscontrol("-d")),
	{ description = "[Hardware Controls|Brightness] decrease brightness", locked = true, repeating = true }
)

-- Utilities
hl.bind(
	MOD .. " + K",
	hl.dsp.exec_cmd(hyde.sh.kb.switch()),
	{ description = "[Utilities] toggle keyboard layout", locked = true }
)
hl.bind(MOD .. " + ALT + G", hl.dsp.exec_cmd(hyde.sh.gamemode()), { description = "[Utilities] game mode" })
hl.bind(
	MOD .. " + SHIFT + G",
	hl.dsp.exec_cmd("hyde-shell gamelauncher"),
	{ description = "[Utilities] open game launcher" }
)

-- Utilities | Screen Capture
hl.bind(
	MOD .. " + SHIFT + P",
	hl.dsp.exec_cmd("hyprpicker -an"),
	{ description = "[Utilities|Screen Capture] color picker", locked = true }
)
hl.bind(
	MOD .. " + P",
	hl.dsp.exec_cmd(hyde.sh.screenshot.snip()),
	{ description = "[Utilities|Screen Capture] snip screen", locked = true }
)
hl.bind(
	MOD .. " + CONTROL + P",
	hl.dsp.exec_cmd(hyde.sh.screenshot.freeze()),
	{ description = "[Utilities|Screen Capture] freeze and snip screen", locked = true }
)
hl.bind(
	MOD .. " + ALT + P",
	hl.dsp.exec_cmd(hyde.sh.screenshot.monitor()),
	{ description = "[Utilities|Screen Capture] print monitor", locked = true }
)
hl.bind(
	"Print",
	hl.dsp.exec_cmd(hyde.sh.screenshot.full()),
	{ description = "[Utilities|Screen Capture] print all monitors", locked = true }
)

-- Theming and Wallpaper
hl.bind(
	MOD .. " + ALT + Right",
	hl.dsp.exec_cmd(hyde.sh.wallpaper("--next")),
	{ description = "[Theming and Wallpaper] next global wallpaper" }
)
hl.bind(
	MOD .. " + ALT + Left",
	hl.dsp.exec_cmd(hyde.sh.wallpaper("--prev")),
	{ description = "[Theming and Wallpaper] previous global wallpaper" }
)
hl.bind(
	MOD .. " + ALT + Up",
	hl.dsp.exec_cmd("hyde-shell waybar --next"),
	{ description = "[Theming and Wallpaper] next Waybar layout" }
)
hl.bind(
	MOD .. " + ALT + Down",
	hl.dsp.exec_cmd("hyde-shell waybar --prev"),
	{ description = "[Theming and Wallpaper] previous Waybar layout" }
)
hl.bind(
	MOD .. " + SHIFT + W",
	hl.dsp.exec_cmd(hyde.sh.menu.wallpapers()),
	{ description = "[Theming and Wallpaper] select a global wallpaper" }
)
hl.bind(
	MOD .. " + SHIFT + R",
	hl.dsp.exec_cmd(hyde.sh.menu.wallbash()),
	{ description = "[Theming and Wallpaper] wallbash mode selector" }
)
hl.bind(
	MOD .. " + SHIFT + T",
	hl.dsp.exec_cmd(hyde.sh.menu.themes()),
	{ description = "[Theming and Wallpaper] select a theme" }
)
hl.bind(
	MOD .. " + SHIFT + Y",
	hl.dsp.exec_cmd("hyde-shell animations --select"),
	{ description = "[Theming and Wallpaper] select animations" }
)
hl.bind(
	MOD .. " + SHIFT + U",
	hl.dsp.exec_cmd("hyde-shell hyprlock --select"),
	{ description = "[Theming and Wallpaper] select Hyprlock layout" }
)
