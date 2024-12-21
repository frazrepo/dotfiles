--
-- wezterm lua
-- wezterm configuration file
--

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Helpers
local function is_found(str, pattern)
    return string.find(str, pattern) ~= nil
end

-- This will hold the configuration.
local config = wezterm.config_builder()
local is_win = is_found(wezterm.target_triple, 'windows')
local is_linux = is_found(wezterm.target_triple, 'linux')
local is_mac = is_found(wezterm.target_triple, 'apple')

-- Action binder
local act = wezterm.action

-- Some empty tables for later use
local launch_menu = {}

-- Menu items for Windows
if is_win then
    -- Launch Menu
    table.insert(launch_menu, {
        label = 'PowerShell 5',
        args = {'powershell.exe', '-NoLogo'}
    })
    table.insert(launch_menu, {
        label = 'Powershell 7',
        args = {'pwsh.exe', '-NoLogo'}
    })
    -- Enumerate any WSL distributions that are installed and add those to the menu
    local success, wsl_list, wsl_err = wezterm.run_child_process({"wsl.exe", "-l"})
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
                    args = {"wsl.exe", "--distribution", distro, "--exec", "/bin/zsh", "-l"}
                })
            end
        end
    end
end

-- Menu items for linux
if is_linux then
    table.insert(launch_menu, {
        label = 'Powershell',
        args = {'/usr/local/bin/pwsh', '-NoLogo'}
    })
end

-- Settings
config.default_prog = {is_win and "pwsh" or "zsh"}
config.font = wezterm.font_with_fallback(
  {
    { family = "JetBrains Mono"},
    { family = "Iosevka Nerd Font", weight = "Medium"}
  }
)
config.font_size = 12
if is_mac then
    config.font_size = 18 
end
-- config.color_scheme = 'Tokyo Night'
config.color_scheme = "Catppuccin Macchiato"
config.launch_menu = launch_menu
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"
config.initial_cols = 128
config.initial_rows = 32

-- Dim inactive panes
config.inactive_pane_hsb = {
    saturation = 0.24,
    brightness = 0.5
}

-- Tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true

-- Keybinds for splitting panes
config.keys = {
  {
    key = "-",
    mods = "CTRL",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "=",
    mods = "CTRL",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "w",
    mods = "CTRL",
    action = act.CloseCurrentPane({ confirm = true }),
  },
  {
    key = "h",
    mods = "CTRL",
    action = act.ActivatePaneDirection("Left"),
  },
  {
    key = "l",
    mods = "CTRL",
    action = act.ActivatePaneDirection("Right"),
  },
  {
    key = "k",
    mods = "CTRL",
    action = act.ActivatePaneDirection("Up"),
  },
  {
    key = "j",
    mods = "CTRL",
    action = act.ActivatePaneDirection("Down"),
  },
  -- activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
  { key = "8", mods = "CTRL", action = act.PaneSelect },
  -- activate pane selection mode with numeric labels
  {
    key = "9",
    mods = "CTRL",
    action = act.PaneSelect({
      alphabet = "1234567890",
    }),
  },
  -- show the pane selection mode, but have it swap the active and selected panes
  {
    key = "0",
    mods = "CTRL",
    action = act.PaneSelect({
      mode = "SwapWithActive",
    }),
  },
  -- Ctrl + Enter = Toggle Zoom
  {
    key = "\r",
    mods = "CTRL",
    action = act.TogglePaneZoomState,
  },
}

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
