-- ~/.config/hypr/lua/env.lua
-- Environment variables + exec_once commands (migrated from userprefs.conf + hyprland.conf)

hl.env("WLOGOUT_STYLE", "2")

hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
