local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.default_prog = { "nu" }

config.hide_tab_bar_if_only_one_tab = true

config.font_size = 10.0

config.keys = {
	{ key = "c", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	{ key = "l", mods = "ALT", action = act.ShowLauncher },
	{
		key = "h",
		mods = "ALT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "ALT",
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
	table.insert(copy_mode, {
		key = "E",
		mods = "NONE",
		action = act.CopyMode("MoveForwardWordEnd"),
	})
end

config.key_tables = {
	copy_mode = copy_mode,
}

return config
