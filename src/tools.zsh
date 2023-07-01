



if apt_cmd "zoxide"; then
  eval "$(zoxide init zsh)"
fi

if apt_cmd "rg" "ripgrep"; then
  alias grep="rg"
  export FZF_DEFAULT_COMMAND='rg --files'
fi

if apt_cmd "fdfind" "fd-find"; then
  alias fd="fdfind"
  export FZF_ALT_C_COMMAND='fd --type directory'
fi

if apt_cmd "exa"; then
  alias ls="exa --group-directories-first"
  alias ll="exa -l --group-directories-first"
  alias la="exa -a --group-directories-first"
  alias lla="exa -la --group-directories-first"
fi

if apt_cmd "fzf"; then
  export FZF_DEFAULT_OPTS='--reverse --border --exact --height=75% -m'

  export FZF_CTRL_T_OPTS="--bind 'ctrl-/:change-preview-window(down|hidden|)'"

  # fzf config (hook: alt-c, ctrl-t, ctrl-r)
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if apt_cmd "batcat" "bat"; then

  local cmd="$(which bat)"
  [[ ! $! -eq 0 ]] && cmd="$(which batcat)"

  alias bat="$cmd"
  alias less="$cmd"

  # improve fzf preview
  export FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS --preview '$cmd -n --color=always {}'"
fi

# if sh_cmd "2starship" 'curl -sS https://starship.rs/install.sh | sh'; then
#   mkdir -p $HOME/.config
#   ln -nfs $DOTFILES_PATH/src/starship.toml $HOME/.config/starship.toml
#   eval $(starship init zsh)
# fi

if apt_cmd "age"; then
fi
