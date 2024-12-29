local wezterm = require 'wezterm'
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Configs for Windows only
  -- font_dirs = {
  --     'C:\\Users\\whoami\\.dotfiles\\.fonts'
  -- }
  default_prog = {'wsl.exe', '~', '-d', 'Ubuntu-20.04'}
end


-- config.set_environment_variables = {
--   PATH = '/opt/homebrew/bin:' .. os.getenv('PATH')
-- }

config.font = wezterm.font({ family = 'Berkeley Mono'})
config.font_size = 12
config.color_scheme = 'Catppuccin Macchiato'
config.window_background_opacity = 1
config.macos_window_background_blur = 30
config.exit_behavior = 'Close'
config.window_close_confirmation = 'NeverPrompt'

-- Removes the title bar, leaving only the tab bar.
config.window_decorations = 'INTEGRATED_BUTTONS'

-- Sets the font for the window frame (tab bar)
-- config.window_frame = {
--   -- Berkeley Mono for me again, though an idea could be to try a
--   -- serif font here instead of monospace for a nicer look?
--   font = wezterm.font({ family = 'Berkeley Mono', weight = 'Bold' }),
--   font_size = 11,
-- }

-- Table mapping keypresses to actions
config.keys = {
  -- Sends ESC + b and ESC + f sequence, which is used
  -- for telling your shell to jump back/forward.
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bb',
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },

  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { 'nvim', wezterm.config_file },
    },
  },
  {
    key = 'd',
    mods = 'SHIFT|CMD',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
}

local function segments_for_right_status(window)
  return {
    os.getenv('USER') .. '@' .. wezterm.hostname(),
  }
end

wezterm.on('update-status', function(window, _)
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  local gradient_to, gradient_from = bg
  gradient_from = gradient_to:lighten(0.2)

  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = utf8.char(0xe0b2)  }) -- solid left arrow

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make python stack traces clickable
-- table.insert(config.hyperlink_rules, {
--   regex = 'File \"/Users/tobi/([^"]+)\", line (\\d+)',
--   format = 'cursor://file$1:$2',
--   highlight = 0,
-- })

table.insert(config.hyperlink_rules, {
  regex = [[\b(\/[\w\.\_\-\/]+\.\w{1,5}\:\d+)]],
  format = 'cursor://file$0',
  highlight = 0,
})

table.insert(config.hyperlink_rules, {
  regex = [[\b(\w[\w\.\_\-]+\.\w{1,5}\:\d+)]],
  format = 'cursor://file/./$0',
  highlight = 0,
})

-- make prompt paths clickable to open finder (sadly, doesn't work with ~)
-- table.insert(config.hyperlink_rules, {
--   regex = [[^tobi ([\S]+) ❯]],
--   format = 'file://$1',
--   highlight = 1,
-- })

-- and finally, return the configuration to wezterm
return config