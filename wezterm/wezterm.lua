-- Pull in the wezterm API
local wezterm = require 'wezterm'
local muz = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Key bindings
config.disable_default_key_bindings = false

-- Visuals
config.window_decorations = "RESIZE"
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"
config.window_frame = {
  active_titlebar_bg = "#000000"
}
config.initial_cols = 350
config.initial_rows = 80
config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}
config.font = wezterm.font 'Iosevka Nerd Font'
config.font_size = 20.0
config.color_scheme = 'Gruvbox dark, medium (base16)'
config.enable_tab_bar = false
config.default_cursor_style = "BlinkingBar"

-- https://wezfurlong.org/wezterm/config/keyboard-concepts.html#macos-left-and-right-option-key
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

-- and finally, return the configuration to wezterm
return config
