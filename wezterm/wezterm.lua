--
-- wezterm lua
-- wezterm configuration file
--

-- Pull in the wezterm API
local wezterm = require("wezterm")

------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------
local function is_found(str, pattern)
	return string.find(str, pattern) ~= nil
end

-- This will hold the configuration.
local config = wezterm.config_builder()
local is_win = is_found(wezterm.target_triple, "windows")
local is_linux = is_found(wezterm.target_triple, "linux")
local is_mac = is_found(wezterm.target_triple, "apple")

-- Action binder
local act = wezterm.action

-- Some empty tables for later use
local launch_menu = {}

-- Menu items for Windows
if is_win then
	-- Launch Menu
	table.insert(launch_menu, {
		label = "PowerShell 5",
		args = { "powershell.exe", "-NoLogo" },
	})
	table.insert(launch_menu, {
		label = "Powershell 7",
		args = { "pwsh.exe", "-NoLogo" },
	})
	table.insert(launch_menu, {
		label = "CMD",
		args = { "cmd.exe", "-NoLogo" },
	})

	-- Enumerate any WSL distributions that are installed and add those to the menu
	local success, wsl_list, wsl_err = wezterm.run_child_process({ "wsl.exe", "-l" })
	if success then
		-- `wsl.exe -l` has a bug where it always outputs utf16:
		-- https://github.com/microsoft/WSL/issues/4607
		-- So we get to convert it
		wsl_list = wezterm.utf16_to_utf8(wsl_list)

		for idx, line in ipairs(wezterm.split_by_newlines(wsl_list)) do
			-- Skip the first line of output; it's just a header
			if idx > 1 then
				-- Remove the "(Default)" marker from the default line to arrive
				-- at the distribution name on its own
				local distro = line:gsub(" %(Default%)", "")

				-- Here's how to jump directly into some other program; in this example
				-- its a shell that probably isn't the default, but it could also be
				-- any other program that you want to run in that environment
				table.insert(launch_menu, {
					label = distro .. " (WSL zsh login shell)",
					args = { "wsl.exe", "--distribution", distro, "--exec", "/bin/zsh", "-l" },
				})
			end
		end
	end
end

-- Menu items for linux
if is_linux then
	table.insert(launch_menu, {
		label = "Powershell",
		args = { "/usr/local/bin/pwsh", "-NoLogo" },
	})
end

------------------------------------------------------------------
-- Settings
------------------------------------------------------------------
config.enable_wayland = true
config.webgpu_power_preference = "HighPerformance"

------------------------------------------------------------------
-- Font
------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono" },
	{ family = "Iosevka Nerd Font", weight = "Medium" },
})
config.font_size = 14
if is_mac then
	config.font_size = 18
end

------------------------------------------------------------------
-- Color
------------------------------------------------------------------
-- config.color_scheme = 'Tokyo Night'
config.color_scheme = "Catppuccin Macchiato"
-- config.color_scheme = 'Catppuccin Latte'
config.colors = {
	indexed = { [241] = "#65bcff" },
}

------------------------------------------------------------------
-- Menu and Windows
------------------------------------------------------------------
config.launch_menu = launch_menu
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"

if is_win then
	config.default_prog = { "pwsh" }
	config.window_decorations = "RESIZE|TITLE"
	wezterm.on("gui-startup", function(cmd)
		local screen = wezterm.gui.screens().active
		local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
		local gui = window:gui_window()
		local width = 0.7 * screen.width
		local height = 0.7 * screen.height
		gui:set_inner_size(width, height)
		gui:set_position((screen.width - width) / 2, (screen.height - height) / 2)
	end)
else
	config.window_decorations = "NONE"
end

config.initial_cols = 128
config.initial_rows = 32

------------------------------------------------------------------
-- Cursor
------------------------------------------------------------------
config.default_cursor_style = "BlinkingBar"
config.force_reverse_video_cursor = true
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_thickness = 4

------------------------------------------------------------------
-- Tab Bar
------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
-- config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.unzoom_on_switch_pane = true

------------------------------------------------------------------
-- Command Palette
------------------------------------------------------------------
config.command_palette_font_size = 13
config.command_palette_bg_color = "#00246B"
config.command_palette_fg_color = "#CADCFC"

------------------------------------------------------------------
-- Keybindings
------------------------------------------------------------------
mod = is_win and "SHIFT|CTRL" or "SHIFT|CTRL"

smart_split = wezterm.action_callback(function(window, pane)
	local dim = pane:get_dimensions()
	if dim.pixel_height > dim.pixel_width then
		window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
	else
		window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
	end
end)

---@param resize_or_move "resize" | "move"
---@param mods string
---@param key string
---@param dir "Right" | "Left" | "Up" | "Down"
function split_nav(resize_or_move, mods, key, dir)
	local event = "SplitNav_" .. resize_or_move .. "_" .. dir
	wezterm.on(event, function(win, pane)
		if is_nvim(pane) then
			-- pass the keys through to vim/nvim
			win:perform_action({ SendKey = { key = key, mods = mods } }, pane)
		else
			if resize_or_move == "resize" then
				win:perform_action({ AdjustPaneSize = { dir, 3 } }, pane)
			else
				local panes = pane:tab():panes_with_info()
				local is_zoomed = false
				for _, p in ipairs(panes) do
					if p.is_zoomed then
						is_zoomed = true
					end
				end
				wezterm.log_info("is_zoomed: " .. tostring(is_zoomed))
				if is_zoomed then
					dir = dir == "Up" or dir == "Right" and "Next" or "Prev"
					wezterm.log_info("dir: " .. dir)
				end
				win:perform_action({ ActivatePaneDirection = dir }, pane)
				win:perform_action({ SetPaneZoomState = is_zoomed }, pane)
			end
		end
	end)
	return {
		key = key,
		mods = mods,
		action = wezterm.action.EmitEvent(event),
	}
end

function is_nvim(pane)
	return pane:get_user_vars().IS_NVIM == "true" or pane:get_foreground_process_name():find("n?vim")
end

config.disable_default_key_bindings = true
config.keys = {
	-- Clear screen and preserve scrollback (Send ctrl-l)
	{
		mods = mod,
		key = "K",
		action = wezterm.action_callback(function(window, pane)
			local pos = pane:get_cursor_position()
			local move_viewport_to_scrollback = string.rep("\r\n", pos.y)
			pane:inject_output(move_viewport_to_scrollback)
			pane:send_text("\x0c") -- CTRL-L
		end),
	},
	-- New Tab
	{ mods = mod, key = "t", action = act.SpawnTab("CurrentPaneDomain") },
	-- Splits
	{ mods = mod, key = "Enter", action = smart_split },
	-- Resize Fonts
	{ mods = "CTRL", key = "(", action = act.DecreaseFontSize },
	{ mods = "CTRL", key = ")", action = act.IncreaseFontSize },
	-- Acivate Tabs
	{ mods = mod, key = "l", action = act({ ActivateTabRelative = 1 }) },
	{ mods = mod, key = "h", action = act({ ActivateTabRelative = -1 }) },
	{ mods = mod, key = "R", action = wezterm.action.RotatePanes("Clockwise") },
	-- show the pane selection mode, but have it swap the active and selected panes
	{ mods = mod, key = "S", action = wezterm.action.PaneSelect({}) },
	-- Clipboard
	{ mods = mod, key = "c", action = act.CopyTo("Clipboard") },
	{ mods = mod, key = "Space", action = act.QuickSelect },
	{ mods = mod, key = "X", action = act.ActivateCopyMode },
	{ mods = mod, key = "f", action = act.Search("CurrentSelectionOrEmptyString") },
	{ mods = mod, key = "v", action = act.PasteFrom("Clipboard") },
	{
		mods = mod,
		key = "u",
		action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
	},
	-- Command Palette
	{ mods = mod, key = "p", action = act.ActivateCommandPalette },
	{ mods = mod, key = "d", action = act.ShowDebugOverlay },
	-- Resize or Move and handle nvim keys
	split_nav("resize", "CTRL", "LeftArrow", "Right"),
	split_nav("resize", "CTRL", "RightArrow", "Left"),
	split_nav("resize", "CTRL", "UpArrow", "Up"),
	split_nav("resize", "CTRL", "DownArrow", "Down"),
	split_nav("move", "CTRL", "h", "Left"),
	split_nav("move", "CTRL", "j", "Down"),
	split_nav("move", "CTRL", "k", "Up"),
	split_nav("move", "CTRL", "l", "Right"),
	{ mods = "CTRL", key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ mods = "CTRL", key = "=", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = mod, key = "w", action = act.CloseCurrentPane({ confirm = true }) },
	-- activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
	{ mods = "CTRL", key = "8", action = act.PaneSelect },
	-- activate pane selection mode with numeric labels
	{ mods = "CTRL", key = "9", action = act.PaneSelect({ alphabet = "1234567890" }) },
	-- show the pane selection mode, but have it swap the active and selected panes
	{ mods = "CTRL", key = "0", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	-- Ctrl + Enter = Toggle Zoom
	{ mods = "CTRL", key = "\r", action = act.TogglePaneZoomState },
    -- Set tab title
    {
        key = 'E', mods = 'CTRL|SHIFT',
        action = act.PromptInputLine {
            description = 'Enter new name for tab',
            -- initial_value = 'My Tab Name',
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },
    -- Set workspace title
    {
        key = 'N',
        mods = 'CTRL|SHIFT',
        action = act.PromptInputLine {
            description = wezterm.format {
                { Attribute = { Intensity = 'Bold' } },
                { Foreground = { AnsiColor = 'Fuchsia' } },
                { Text = 'Enter name for new workspace' },
            },
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace {
                            name = line,
                        },
                        pane
                    )
                end
            end),
        },
    },
}

------------------------------------------------------------------
-- Bar Status
------------------------------------------------------------------
wezterm.on("update-status", function(window, pane)
	-- Workspace name
	local stat = window:active_workspace()
	local stat_color = "#f7768e"
	-- It's a little silly to have workspace name all the time
	-- Utilize this to display LDR or current key table name
	if window:active_key_table() then
		stat = window:active_key_table()
		stat_color = "#7dcfff"
	end
	if window:leader_is_active() then
		stat = "LDR"
		stat_color = "#bb9af7"
	end

	local basename = function(s)
		-- Nothing a little regex can't fix
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	-- Current working directory
	local cwd = pane:get_current_working_dir()
	if cwd then
		if type(cwd) == "userdata" then
			-- Wezterm introduced the URL object in 20240127-113634-bbcac864
			cwd = basename(cwd.file_path)
		else
			-- 20230712-072601-f4abf8fd or earlier version
			cwd = basename(cwd)
		end
	else
		cwd = ""
	end

	-- Current command
	local cmd = pane:get_foreground_process_name()
	-- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
	cmd = cmd and basename(cmd) or ""

	-- Time
	local time = wezterm.strftime("%H:%M")

	-- Left status (left of the tab line)
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = stat_color } },
		{ Text = "  " },
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
		-- { Text = " |" },
		{ Text = " " },
	}))

	-- Right status
	window:set_right_status(wezterm.format({
		-- Wezterm has a built-in nerd fonts
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
		{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
		{ Text = " | " },
		{ Foreground = { Color = "#e0af68" } },
		{ Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
		"ResetAttributes",
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.md_clock .. "  " .. time },
		{ Text = "  " },
	}))
end)

------------------------------------------------------------------
-- Links
------------------------------------------------------------------
config.hyperlink_rules = {
	-- Linkify things that look like URLs and the host has a TLD name.
	--
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
		format = "$0",
	},

	-- linkify email addresses
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
		format = "mailto:$0",
	},

	-- file:// URI
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = [[\bfile://\S*\b]],
		format = "$0",
	},

	-- Linkify things that look like URLs with numeric addresses as hosts.
	-- E.g. http://127.0.0.1:8000 for a local development server,
	-- or http://192.168.1.1 for the web interface of many routers.
	{
		regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
		format = "$0",
	},

	-- Make username/project paths clickable. This implies paths like the following are for GitHub.
	-- As long as a full URL hyperlink regex exists above this it should not match a full URL to
	-- GitHub or GitLab / BitBucket (i.e. https://gitlab.com/user/project.git is still a whole clickable URL)
	{
		regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
		format = "https://www.github.com/$1/$3",
	},
}

------------------------------------------------------------------
-- Mouse
------------------------------------------------------------------
config.alternate_buffer_wheel_scroll_speed = 1
config.bypass_mouse_reporting_modifiers = mod
config.mouse_bindings = {
	-- Don't open links without modifier
	{
		event = { Up = { streak = 1, button = "Left" } },
		action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = mod,
		action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
	},
}

-- and finally, return the configuration to wezterm
return config
