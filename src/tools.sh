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
fi

if command_present "eza"; then
  alias ls="eza --group-directories-first"
  alias ll="eza -l --group-directories-first"
  alias la="eza -a --group-directories-first"
  alias lla="eza -la --group-directories-first"
  alias tree="eza --tree"
  alias exa="eza"
else
  add_package "eza"
fi

if command_present "fzf"; then
  export FZF_DEFAULT_OPTS='--reverse --border --exact --height=75% -m'
  export FZF_CTRL_T_OPTS="--bind 'ctrl-/:change-preview-window(down|hidden|)'"

  source $DOTFILES_PATH/src/vendor/fzf-bindings.$SHELL_ENV
else
  add_package "fzf"
fi

if command_present "bat"; then
  cmd="$(which bat)"
  [[ ! $! -eq 0 ]] && cmd="$(which batcat)"

  alias bat="$cmd"
  alias less="$cmd"

  # improve fzf preview
  export FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS --preview '$cmd -n --color=always {}'"
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
