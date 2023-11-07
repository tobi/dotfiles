if check_cmd_or_install "zoxide"; then
  eval "$(zoxide init $SHELL_ENV)"
fi

# if command_present "zoxide"; then
#   eval "$(zoxide init $SHELL_ENV)"
# else
#   add_package "zoxide"
# fi

if check_cmd_or_install "rg" "ripgrep"; then
  alias grep="rg"
  export FZF_DEFAULT_COMMAND='rg --files'
fi

if check_cmd_or_install "fdfind" "fd-find"; then
  alias fd="fdfind"
  export FZF_ALT_C_COMMAND='fd --type directory'
fi

if check_cmd_or_install "exa"; then
  alias ls="exa --group-directories-first"
  alias ll="exa -l --group-directories-first"
  alias la="exa -a --group-directories-first"
  alias lla="exa -la --group-directories-first"
fi

if check_cmd_or_install "fzf"; then
  export FZF_DEFAULT_OPTS='--reverse --border --exact --height=75% -m'
  export FZF_CTRL_T_OPTS="--bind 'ctrl-/:change-preview-window(down|hidden|)'"

  # fzf config (hook: alt-c, ctrl-t, ctrl-r)
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if check_cmd_or_install "batcat" "bat"; then
  local cmd="$(which bat)"
  [[ ! $! -eq 0 ]] && cmd="$(which batcat)"

  alias bat="$cmd"
  alias less="$cmd"

  # improve fzf preview
  export FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS --preview '$cmd -n --color=always {}'"
fi

if check_cmd_or_install "age"; then
  echo -n ""
fi
