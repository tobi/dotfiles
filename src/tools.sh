if command_present "rg"; then
  alias grep="rg"
  export FZF_DEFAULT_COMMAND='rg --files'
else
  add_package "ripgrep"
fi

if command_present "zoxide"; then
  eval "$(zoxide init $SHELL_ENV)"
else
  add_package "zoxide"
fi

if command_present "fdfind"; then
  alias fd="fdfind"
fi

if command_present "batcat"; then
  alias bat="batcat"
fi

if command_present "fd"; then
  export FZF_ALT_C_COMMAND='fd --type directory'
else
  add_apt_package "fd-find"
  add_brew_package "fd"
  add_pacman_package "fd"
fi

if command_present "eza"; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -l --icons --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lla="eza -la --icons --group-directories-first"
  alias tree="eza --tree --icons"
  alias exa="eza"
else
  add_package "eza"
fi

if command_present "fzf"; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 75% --border --info=inline --bind "ctrl-/:toggle-preview"'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons --level=2 {} | head -100'"

  source $DOTFILES_PATH/src/vendor/fzf-bindings.$SHELL_ENV
else
  add_package "fzf"
fi

if command_present "bat"; then
  cmd="$(which bat)"
  [[ ! $! -eq 0 ]] && cmd="$(which batcat)"

  alias bat="$cmd"
  alias less="$cmd"
  export BAT_THEME="Nord"
  unset cmd
else
  add_package "bat"
fi

if command_present "age"; then
  echo -n ""
else
  add_package "age"
fi

if command_present "lazygit"; then
  alias lg=lazygit
fi

# ── Additional integrations ported from dotnix home.nix ──────────────────────

if command_present "nvim"; then
  alias n="nvim"
fi

if command_present "claude"; then
  alias claude="claude --dangerously-skip-permissions"
fi

if command_present "grc"; then
  alias ping="grc --colour=auto ping"
  alias traceroute="grc --colour=auto traceroute"
  alias make="grc --colour=auto make"
  alias diff="grc --colour=auto diff"
  alias dig="grc --colour=auto dig"
  alias mount="grc --colour=auto mount"
  alias ps="grc --colour=auto ps"
  alias df="grc --colour=auto df"
  alias ifconfig="grc --colour=auto ifconfig"
  alias netstat="grc --colour=auto netstat"
else
  add_package "grc"
fi

if command_present "trash-put"; then
  alias rm="trash-put"
else
  add_package "trash-cli"
fi

if command_present "mise"; then
  eval "$(mise activate $SHELL_ENV)"
  add_brew_package "mise"
  add_pacman_package "mise"
fi

if command_present "direnv"; then
  eval "$(direnv hook $SHELL_ENV)"
else
  add_package "direnv"
fi

# try - fresh directories for every vibe (https://github.com/tobi/try-cli)
if command_present "try"; then
  eval "$(try init ~/src/tries)"
fi

# Linux clipboard aliases (macOS compatibility)
if [[ "$SHELL_ENV" == "zsh" || "$SHELL_ENV" == "bash" ]] && command_present "wl-copy"; then
  alias pbcopy="wl-copy"
  alias pbpaste="wl-paste"
fi
