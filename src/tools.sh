if command_present "rg"; then
  alias grep="rg"
  export FZF_DEFAULT_COMMAND='rg --files'
else
  add_package_mise "rg" "ripgrep"
fi

if command_present "zoxide"; then
  eval "$(zoxide init "$SHELL_ENV")"
else
  add_package_mise "zoxide" "zoxide"
fi

if command_present "fd"; then
  export FZF_ALT_C_COMMAND='fd --type directory'
elif command_present "fdfind"; then
  alias fd="fdfind"
  export FZF_ALT_C_COMMAND='fdfind --type directory'
else
  add_package_mise "fd" "fd-find" "fd" "fd"
fi

if command_present "eza"; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -l --icons --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lla="eza -la --icons --group-directories-first"
  alias tree="eza --tree --icons"
  alias exa="eza"
else
  add_package_mise "eza" "eza"
fi

if command_present "fzf"; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 75% --border --info=inline --bind "ctrl-/:toggle-preview"'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons --level=2 {} | head -100'"

  source "$DOTFILES_PATH/src/vendor/fzf-bindings.$SHELL_ENV"
else
  add_package_mise "fzf" "fzf"
fi

if command_present "bat"; then
  alias less="bat"
  export BAT_THEME="Nord"
elif command_present "batcat"; then
  alias bat="batcat"
  alias less="batcat"
  export BAT_THEME="Nord"
else
  add_package_mise "bat" "bat"
fi

if command_present "age"; then
  echo -n ""
else
  add_package_mise "age" "age"
fi

if command_present "lazygit"; then
  alias lg=lazygit
else
  add_package_mise "lazygit" "" "lazygit" "lazygit"
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
  require_apply_tool "grc"
fi

# Tools added by newer dotfiles are reconciled by apply.
require_apply_tool "herdr"
require_apply_tool "starship"
require_apply_tool "try"

# Defer try's Ruby-powered shell integration until its first use.
if command -v try >/dev/null 2>&1; then
  try() {
    unset -f try
    eval "$(command try init "$HOME/src/tries")"
    try "$@"
  }
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init "$SHELL_ENV")"
fi

# Linux clipboard aliases (macOS compatibility)
if [[ "$SHELL_ENV" == "zsh" || "$SHELL_ENV" == "bash" ]] && command_present "wl-copy"; then
  alias pbcopy="wl-copy"
  alias pbpaste="wl-paste"
fi
