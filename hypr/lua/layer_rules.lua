-- ~/.config/hypr/lua/layer_rules.lua
-- Layer rules for rofi / notifications / logout dialog (migrated from windowrules.conf)

hl.layer_rule({
	name = "rofi_blur",
	match = { namespace = "^rofi$" },
	blur = true,
	ignore_alpha = true,
})

hl.layer_rule({
	name = "notifications_blur",
	match = { namespace = "^notifications$" },
	blur = true,
	ignore_alpha = true,
})

hl.layer_rule({
	name = "swaync_notification_blur",
	match = { namespace = "^swaync-notification-window$" },
	blur = true,
	ignore_alpha = true,
})

hl.layer_rule({
	name = "swaync_control_blur",
	match = { namespace = "^swaync-control-center$" },
	blur = true,
	ignore_alpha = true,
})

hl.layer_rule({
	name = "logout_dialog_blur",
	match = { namespace = "^logout_dialog$" },
	blur = true,
})
