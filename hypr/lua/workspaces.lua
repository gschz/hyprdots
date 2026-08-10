-- ~/.config/hypr/lua/workspaces.lua
-- Workspace navigation / movement loops and special workspace (migrated from keybindings.conf)

local MOD = hyde.config.modifiers.main

-- Workspaces | Navigation
for i = 1, 10 do
	local key = (i == 10) and 0 or i
	hl.bind(
		MOD .. " + " .. key,
		hl.dsp.focus({ workspace = i }),
		{ description = "[Workspaces|Navigation] navigate to workspace " .. i }
	)
end

hl.bind(
	MOD .. " + CONTROL + RIGHT",
	hl.dsp.focus({ workspace = "r+1" }),
	{ description = "[Workspaces|Navigation|Relative workspace] change active workspace forwards" }
)
hl.bind(
	MOD .. " + CONTROL + LEFT",
	hl.dsp.focus({ workspace = "r-1" }),
	{ description = "[Workspaces|Navigation|Relative workspace] change active workspace backwards" }
)
hl.bind(
	MOD .. " + CONTROL + UP",
	hl.dsp.focus({ workspace = "previous" }),
	{ description = "[Workspaces|Navigation] navigate to the previous window" }
)
hl.bind(
	MOD .. " + CONTROL + DOWN",
	hl.dsp.focus({ workspace = "empty" }),
	{ description = "[Workspaces|Navigation] navigate to the nearest empty workspace" }
)

-- Workspaces | Move window to workspace
for i = 1, 10 do
	local key = (i == 10) and 0 or i
	hl.bind(
		MOD .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i }),
		{ description = "[Workspaces|Move window to workspace] move focused window to workspace " .. i }
	)
end

hl.bind(
	MOD .. " + CONTROL + ALT + RIGHT",
	hl.dsp.window.move({ workspace = "r+1" }),
	{ description = "[Workspaces|Move window to workspace|Relative workspace] move focused window to next workspace" }
)
hl.bind(MOD .. " + CONTROL + ALT + LEFT", hl.dsp.window.move({ workspace = "r-1" }), {
	description = "[Workspaces|Move window to workspace|Relative workspace] move focused window to previous workspace",
})

-- Workspaces | Mouse
hl.bind(
	MOD .. " + mouse_down",
	hl.dsp.focus({ workspace = "e+1" }),
	{ description = "[Workspaces|Navigation|Mouse] next workspace" }
)
hl.bind(
	MOD .. " + mouse_up",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "[Workspaces|Navigation|Mouse] previous workspace" }
)

-- Special workspace (scratchpad)
hl.bind(
	MOD .. " + S",
	hl.dsp.workspace.toggle_special(),
	{ description = "[Workspaces|Navigation|Special workspace] toggle scratchpad" }
)
hl.bind(
	MOD .. " + SHIFT + S",
	hl.dsp.window.move({ workspace = "special" }),
	{ description = "[Workspaces|Navigation|Special workspace] move focused window to scratchpad" }
)
hl.bind(
	MOD .. " + ALT + S",
	hl.dsp.window.move({ workspace = "special", follow = false }),
	{ description = "[Workspaces|Navigation|Special workspace] move focused window silently to scratchpad" }
)

-- Move silent
for i = 1, 10 do
	local key = (i == 10) and 0 or i
	hl.bind(
		MOD .. " + ALT + " .. key,
		hl.dsp.window.move({ workspace = i, follow = false }),
		{ description = "[Workspaces|Move window (Don't follow)] move focused window to workspace " .. i }
	)
end
