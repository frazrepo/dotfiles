--
-- wezterm lua
-- wezterm configuration
-- Work in progress
--

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

-- Multiplexe layer
local mux = wezterm.mux

-- Action binder
local act = wezterm.action

-- Some empty tables for later use
local keys = {}
local mouse_bindings = {}
local launch_menu = {}

if is_windows then
    -- Launch Menu
      table.insert(launch_menu, {
        label = 'PowerShell',
        args = { 'powershell.exe', '-NoLogo' },
      })
      table.insert(launch_menu, {
        label = 'Pwsh',
        args = { 'pwsh.exe', '-NoLogo' },
      })
end


table.insert(launch_menu, {
  label = 'Pwsh',
  args = { '/usr/local/bin/pwsh', '-NoLogo' },
})

-- Settings
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", scale = 1.3, },
  { family = "Iosevka Nerd Font",       scale = 1.2, weight = "Medium", },
  { family = "FantasqueSansM Nerd Font", scale = 1.3, },
})
-- config.font_size = 16
-- config.color_scheme = 'Tokyo Night'
config.color_scheme = 'Catppuccin Mocha'
config.launch_menu = launch_menu
-- config.default_cursor_style = 'BlinkingBar'
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.24,
  brightness = 0.5
}

-- Tab bar
-- config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

-- config.disable_default_key_bindings = true
-- config.keys = keys
config.mouse_bindings = mouse_bindings

-- Bar status
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
    { Text = " |" },
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

-- and finally, return the configuration to wezterm
return config
