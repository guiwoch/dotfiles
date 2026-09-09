local wezterm = require("wezterm")

return {
	font = wezterm.font("Iosevka Nerd Font Mono", { weight = "Regular" }),
	font_rules = {},
	font_size = 16.0,
	cell_width = 1.0,
	freetype_render_target = "Normal",
	freetype_load_target = "Normal",
	harfbuzz_features = { "calt=0" },
}
