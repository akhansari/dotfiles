local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.default_prog = { "/home/linuxbrew/.linuxbrew/bin/nu" }

config.color_scheme = "flexoki-dark"
config.colors = {
	background = "black",
}

config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- config.window_background_opacity = 0.8

config.font = wezterm.font_with_fallback({ "FiraCode Nerd Font" })
config.font_size = 10.5
config.hide_mouse_cursor_when_typing = true

config.keys = {
	{ key = "c", mods = "ALT", action = act.ActivateCommandPalette },
	{
		key = "h",
		mods = "CTRL|ALT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "CTRL|ALT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "u", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "e", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "i", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
}

local copy_mode = nil
if wezterm.gui then
	copy_mode = wezterm.gui.default_key_tables().copy_mode
	table.insert(copy_mode, {
		key = "u",
		mods = "NONE",
		action = act.CopyMode("MoveLeft"),
	})
	table.insert(copy_mode, {
		key = "i",
		mods = "NONE",
		action = act.CopyMode("MoveDown"),
	})
	table.insert(copy_mode, {
		key = "p",
		mods = "NONE",
		action = act.CopyMode("MoveUp"),
	})
	table.insert(copy_mode, {
		key = "e",
		mods = "NONE",
		action = act.CopyMode("MoveRight"),
	})
end

config.key_tables = {
	copy_mode = copy_mode,
}

return config
