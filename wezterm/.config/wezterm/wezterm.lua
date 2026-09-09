-- WezTerm Keybindings
-- ===================
-- No leader key. All controls use Ctrl (Alt avoided for Hyprland).
-- Shift only kept where a plain Ctrl combo would clobber vim.
--
-- Tabs:
--   Ctrl+1..9            Activate tab 1..9
--   Ctrl+0               Activate tab 10
--   Ctrl+Tab             Next tab
--   Ctrl+Shift+Tab       Previous tab
--   Ctrl+T               New tab
--   Ctrl+Shift+B         Toggle tab bar
--   Ctrl+Shift+W         Close pane (Ctrl+W reserved for vim window prefix)
--   Ctrl+Backspace       Delete previous word (sends \x17)
--
-- Panes:
--   Ctrl+\               Split horizontal (side by side)
--   Ctrl+-               Split vertical (stacked)
--   Ctrl+Shift+H/J/K/L   Navigate pane (Ctrl+L is vim redraw)
--   Ctrl+Shift+Arrow     Resize pane (Ctrl+Arrow is vim word-jump)
--
-- Workspaces:
--   Ctrl+Shift+S         smart_workspace_switcher (zoxide-merged picker)
--   Ctrl+Shift+T         Pick an open workspace, or create one (prompts for name)
--   Ctrl+Shift+[ / ]     Previous / next workspace
--   Ctrl+Shift+N         New workspace (prompts for name)
--   Ctrl+Shift+R         Rename current workspace
--   Ctrl+Shift+C         Kill current workspace (closes all its panes)
--
-- Clipboard:
--   Ctrl+C               Copy if a selection exists, otherwise send SIGINT
--   Ctrl+V               Paste (forwarded to full-screen apps like vim)

local wezterm = require("wezterm")
local font = require("fonts.iosevka")

-- smart_workspace_switcher: zoxide-merged workspace picker.
-- Cloned to ~/.local/share/wezterm/plugins on first run.
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
workspace_switcher.zoxide_path = "/usr/sbin/zoxide"

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end
config.enable_kitty_graphics = true
-- WebGpu samples/scales images cleanly; OpenGL produced pattern/moiré artifacts
-- on kitty-protocol images. HighPerformance picks the discrete GPU.
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
-- Cap to monitor refresh rate (75 Hz)
config.max_fps = 75
config.animation_fps = 75

-- Disabling IME removes a per-keypress round-trip
config.use_ime = false

-- Drop top/bottom window padding, keep the side padding.
config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = 0,
	bottom = 0,
}

--[[
============================
Font
============================
]]
--

config.freetype_render_target = font.freetype_render_target
config.freetype_load_target = font.freetype_load_target
config.cell_width = font.cell_width
config.font = font.font
config.font_rules = font.font_rules
config.font_size = font.font_size
config.harfbuzz_features = font.harfbuzz_features
config.default_cursor_style = "SteadyBlock"

--[[
============================
Colors
============================
]]
--

config.color_scheme = "Gruber (base16)"

-- Gruber (base16) palette
local gruber = {
	base = "#181818",
	mantle = "#453d41",
	overlay = "#665c7f",
	muted = "#9dae93",
	subtle = "#e4e4ef",
	text = "#f4f4ff",
	red = "#f43841",
	orange = "#cc8c3c",
	yellow = "#ffdd33",
	green = "#73c936",
	teal = "#95a99f",
	blue = "#96a6c8",
	purple = "#9e95c7",
}

config.colors = {
	cursor_bg = gruber.text,
	cursor_fg = gruber.base,
	cursor_border = gruber.text,

	selection_bg = gruber.overlay,
	selection_fg = gruber.text,

	tab_bar = {
		background = gruber.base,

		active_tab = {
			bg_color = gruber.mantle,
			fg_color = gruber.yellow,
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = gruber.base,
			fg_color = gruber.muted,
		},

		inactive_tab_hover = {
			bg_color = gruber.mantle,
			fg_color = gruber.subtle,
			italic = false,
		},

		new_tab = {
			bg_color = gruber.base,
			fg_color = gruber.muted,
		},

		new_tab_hover = {
			bg_color = gruber.mantle,
			fg_color = gruber.green,
		},
	},
}

--[[
============================
Shortcuts
============================
]]
--

-- Ctrl+Shift+C: kill the active workspace by switching away then killing
-- every pane that was in it. Refuses if it's the only workspace.
local kill_active_workspace = wezterm.action_callback(function(window, pane)
	local target = wezterm.mux.get_active_workspace()
	local fallback
	for _, n in ipairs(wezterm.mux.get_workspace_names()) do
		if n ~= target then
			fallback = n
			break
		end
	end
	if not fallback then
		wezterm.log_info("refusing to kill the only workspace: " .. target)
		return
	end

	window:perform_action(wezterm.action.SwitchToWorkspace({ name = fallback }), pane)

	for _, w in ipairs(wezterm.mux.all_windows()) do
		if w:get_workspace() == target then
			for _, t in ipairs(w:tabs()) do
				for _, p in ipairs(t:panes()) do
					wezterm.run_child_process({
						"wezterm",
						"cli",
						"kill-pane",
						"--pane-id",
						tostring(p:pane_id()),
					})
				end
			end
		end
	end
end)

-- Ctrl+Shift+T: pick an existing workspace, or "Create new" to be prompted for a name.
-- Built-in ShowLauncher's create option auto-generates the name; this swaps in a prompt.
local pick_or_create_workspace = wezterm.action_callback(function(window, pane)
	local choices = {}
	for _, name in ipairs(wezterm.mux.get_workspace_names()) do
		table.insert(choices, { id = name, label = name })
	end
	table.insert(choices, { id = "__new__", label = "(Create new workspace…)" })

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Workspaces",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
				if not id then
					return
				end
				if id == "__new__" then
					inner_window:perform_action(
						wezterm.action.PromptInputLine({
							description = "New workspace name:",
							action = wezterm.action_callback(function(w, p, line)
								if line and #line > 0 then
									w:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), p)
								end
							end),
						}),
						inner_pane
					)
				else
					inner_window:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), inner_pane)
				end
			end),
		}),
		pane
	)
end)

-- Ctrl+C: copy selection if any, else forward SIGINT (Ctrl+C) to the shell.
local copy_or_interrupt = wezterm.action_callback(function(window, pane)
	local selection = window:get_selection_text_for_pane(pane)
	if selection and #selection > 0 then
		window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
		window:perform_action(wezterm.action.ClearSelection, pane)
	else
		window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
	end
end)

-- Ctrl+V: paste at the shell, but forward Ctrl+V to full-screen apps (vim block
-- select / literal insert). TUIs run on the alternate screen, so use that as the
-- signal for "an app wants the keystroke."
local paste_or_passthrough = wezterm.action_callback(function(window, pane)
	if pane:is_alt_screen_active() then
		window:perform_action(wezterm.action.SendKey({ key = "v", mods = "CTRL" }), pane)
	else
		window:perform_action(wezterm.action.PasteFrom("Clipboard"), pane)
	end
end)

config.keys = {
	-- Word delete (Ctrl+Backspace → send \x17, same signal as Ctrl+W)
	{ mods = "CTRL", key = "Backspace", action = wezterm.action.SendString("\x17") },
	-- Disable Ctrl+W passthrough (muscle memory guard)
	{ mods = "CTRL", key = "w", action = wezterm.action.Nop },
	-- Forward Ctrl+Space through to the terminal app (blink completion in nvim)
	{ mods = "CTRL", key = " ", action = wezterm.action.SendKey({ key = " ", mods = "CTRL" }) },

	-- Clipboard
	{ mods = "CTRL", key = "c", action = copy_or_interrupt },
	{ mods = "CTRL", key = "v", action = paste_or_passthrough },

	-- Tabs
	{ mods = "CTRL", key = "t", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ mods = "CTRL", key = "Tab", action = wezterm.action.ActivateTabRelative(1) },
	{ mods = "CTRL|SHIFT", key = "Tab", action = wezterm.action.ActivateTabRelative(-1) },

	-- Pane lifecycle
	{ mods = "CTRL|SHIFT", key = "w", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{ mods = "CTRL", key = "\\", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = "CTRL", key = "-", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Pane navigation (Shift kept: Ctrl+L is vim redraw, etc.)
	{ mods = "CTRL|SHIFT", key = "h", action = wezterm.action.ActivatePaneDirection("Left") },
	{ mods = "CTRL|SHIFT", key = "j", action = wezterm.action.ActivatePaneDirection("Down") },
	{ mods = "CTRL|SHIFT", key = "k", action = wezterm.action.ActivatePaneDirection("Up") },
	{ mods = "CTRL|SHIFT", key = "l", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Pane resize (Shift kept: Ctrl+Arrow is vim word-jump in insert mode)
	{ mods = "CTRL|SHIFT", key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ mods = "CTRL|SHIFT", key = "RightArrow", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ mods = "CTRL|SHIFT", key = "DownArrow", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{ mods = "CTRL|SHIFT", key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },

	-- Scrollback: vim-style half-page (Shift kept so vim still gets Ctrl+u/Ctrl+d)
	-- (font zoom takes over Ctrl+Shift+U/D — scrollback moved to mouse wheel)
	{ mods = "CTRL|SHIFT", key = "u", action = wezterm.action.IncreaseFontSize },
	{ mods = "CTRL|SHIFT", key = "d", action = wezterm.action.DecreaseFontSize },
	{ mods = "CTRL|SHIFT", key = "r", action = wezterm.action.ResetFontSize },

	-- Workspaces
	{ mods = "CTRL|SHIFT", key = "s", action = workspace_switcher.switch_workspace() },
	{ mods = "CTRL|SHIFT", key = "c", action = kill_active_workspace },
	{ mods = "CTRL|SHIFT", key = "t", action = pick_or_create_workspace },
	{ mods = "CTRL|SHIFT", key = "[", action = wezterm.action.SwitchWorkspaceRelative(-1) },
	{ mods = "CTRL|SHIFT", key = "]", action = wezterm.action.SwitchWorkspaceRelative(1) },
	{
		mods = "CTRL|SHIFT",
		key = "n",
		action = wezterm.action.PromptInputLine({
			description = "New workspace name:",
			action = wezterm.action_callback(function(window, pane, line)
				if line and #line > 0 then
					window:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
	-- {
	-- 	mods = "CTRL|SHIFT",
	-- 	key = "r",
	-- 	action = wezterm.action.PromptInputLine({
	-- 		description = "Rename workspace to:",
	-- 		action = wezterm.action_callback(function(_, _, line)
	-- 			if line and #line > 0 then
	-- 				wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
	-- 			end
	-- 		end),
	-- 	}),
	-- },
}

-- Ctrl+1..9 to activate tab 1..9 (displayed), Ctrl+0 for tab 10
for i = 1, 9 do
	table.insert(config.keys, {
		mods = "CTRL",
		key = tostring(i),
		action = wezterm.action.ActivateTab(i - 1),
	})
end
table.insert(config.keys, {
	mods = "CTRL",
	key = "0",
	action = wezterm.action.ActivateTab(9),
})

--[[
============================
Mouse
============================
]]
--

-- 5 lines per wheel tick.
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		action = wezterm.action.ScrollByLine(-5),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		action = wezterm.action.ScrollByLine(5),
	},
}

--[[
============================
Status
============================
]]
--

-- Show the active workspace name in the right status bar.
wezterm.on("update-right-status", function(window, _)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = gruber.yellow } },
		{ Text = "● " },
		{ Foreground = { Color = gruber.muted } },
		{ Text = window:active_workspace() .. "  " },
	}))
end)

--[[
============================
Tab Bar
============================
]]
--

-- Disabled: Claude Code's CSI-u decoder reads the base keycode and ignores the
-- shifted-key field, so shifted punctuation arrives wrong (! -> 1, ? -> /, _ -> -,
-- : -> ;). Turning the protocol off makes WezTerm send legacy encodings instead.
-- Trade-off: nvim loses <S-CR> (snacks picker pick_win), <S-Enter> (noice cmdline
-- redirect) and <C-S-y> (picker yank_del). Re-enable once upstream fixes it.
config.enable_kitty_keyboard = false

config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_and_split_indices_are_zero_based = false
config.tab_max_width = 32
-- The retro tab bar draws in the terminal cell grid, so it inherits the 16pt
-- body font and eats a huge strip of the window. The fancy bar has its own
-- font config, which is the only way to shrink the bar independently.
config.use_fancy_tab_bar = true
config.window_frame = {
	font = wezterm.font("Iosevka Nerd Font", { weight = "Regular" }),
	font_size = 11.0,
	active_titlebar_bg = gruber.base,
	inactive_titlebar_bg = gruber.base,
}
-- Keyboard-driven workflow (Ctrl+Shift+W closes); the per-tab ✕ is just noise.
config.show_close_tab_button_in_tabs = false

-- Ctrl+Shift+B: toggle tab bar visibility
wezterm.on("toggle-tab-bar", function(window)
	local overrides = window:get_config_overrides() or {}
	overrides.enable_tab_bar = overrides.enable_tab_bar == false
	window:set_config_overrides(overrides)
end)
table.insert(config.keys, {
	mods = "CTRL|SHIFT",
	key = "b",
	action = wezterm.action.EmitEvent("toggle-tab-bar"),
})

-- Show tab index + a compact title.
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
	local title = tab.tab_title
	if not title or #title == 0 then
		title = tab.active_pane.title
	end
	-- Trim whitespace/control chars and collapse inner runs of whitespace
	title = title:match("^[%s%c]*(.-)[%s%c]*$") or title
	title = title:gsub("%s+", " ")
	-- Shells report the cwd as the title; keep only the last path component.
	-- Anything with a space (e.g. Claude Code's "✳ session name") is a real
	-- title, not a path, so leave it intact.
	if not title:find(" ") then
		title = title:match("([^/\\]+)$") or title
	end
	-- Fall back to the process name if nothing is left
	if #title == 0 then
		local proc = tab.active_pane.foreground_process_name or ""
		title = proc:match("([^/\\]+)$") or proc
	end
	-- Truncate on display columns, not bytes: emoji are wide and multi-byte,
	-- and string.sub would slice mid-codepoint.
	local budget = math.max(8, (max_width or 24) - 4)
	if wezterm.column_width(title) > budget then
		title = wezterm.truncate_right(title, budget - 1) .. "…"
	end
	local idx = tab.tab_index + 1
	return wezterm.format({
		{ Text = " " },
		{ Foreground = { Color = tab.is_active and gruber.orange or gruber.overlay } },
		{ Text = tostring(idx) },
		{ Foreground = { Color = tab.is_active and gruber.yellow or gruber.muted } },
		{ Text = " " .. title .. " " },
	})
end)

return config
