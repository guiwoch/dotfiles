local wezterm = require("wezterm")

return {
	font = wezterm.font("Noto Sans Mono", { weight = "Medium" }),
	font_rules = {
		{
			intensity = "Normal",
			italic = true,
			font = wezterm.font("Noto Sans Mono", { weight = "Medium", style = "Normal" }),
		},
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font("Noto Sans Mono", { weight = "Bold", style = "Normal" }),
		},
	},
	font_size = 14.0,
	cell_width = 0.95,
	freetype_render_target = "HorizontalLcd",
	freetype_load_target = "Mono",
}
