local wezterm = require("wezterm")
local config = {}

config.default_prog = { "nu" }

config.hide_tab_bar_if_only_one_tab = true

config.font_size = 10.0

config.keys = {
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncher },
	{
		key = "h",
		mods = "ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

local copy_mode = nil
if wezterm.gui then
	copy_mode = wezterm.gui.default_key_tables().copy_mode
	table.insert(copy_mode, {
		key = "u",
		mods = "NONE",
		action = wezterm.action.CopyMode("MoveLeft"),
	})
	table.insert(copy_mode, {
		key = "i",
		mods = "NONE",
		action = wezterm.action.CopyMode("MoveDown"),
	})
	table.insert(copy_mode, {
		key = "p",
		mods = "NONE",
		action = wezterm.action.CopyMode("MoveUp"),
	})
	table.insert(copy_mode, {
		key = "e",
		mods = "NONE",
		action = wezterm.action.CopyMode("MoveRight"),
	})
	table.insert(copy_mode, {
		key = "E",
		mods = "NONE",
		action = wezterm.action.CopyMode("MoveForwardWordEnd"),
	})
end

config.key_tables = {
	copy_mode = copy_mode,
}

return config
