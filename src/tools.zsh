


if apt_cmd "batcat" "bat"; then
  alias ccat="/usr/bin/cat"
  alias cat="batcat"
fi

if apt_cmd "zoxide"; then
  eval "$(zoxide init zsh)"
fi

if apt_cmd "rg" "ripgrep"; then
  alias grep="rg"
fi

if apt_cmd "fdfind" "fd-find"; then
  alias fd="fdfind"
fi

if apt_cmd "exa"; then
  alias ls="exa --group-directories-first"
  alias ll="exa -l --group-directories-first"
  alias la="exa -a --group-directories-first"
  alias lla="exa -la --group-directories-first"
fi

if apt_cmd "fzf"; then
  # fzf config (hook: alt-c, ctrl-t, ctrl-r)
  export FZF_DEFAULT_OPTS='--reverse --border --exact --height=60% -m'

  # use best tools to accelerate
  [[ $commands[fd] ]] && export FZF_ALT_C_COMMAND='fd --type directory'
  [[ $commands[rg] ]] && export FZF_DEFAULT_COMMAND='rg --files'
  [[ $commands[mdfind] ]] && export FZF_CTRL_T_COMMAND="mdfind -onlyin . -name ."
fi

if sh_cmd "starship" 'curl -sS https://starship.rs/install.sh | sh'; then
  mkdir -p $HOME/.config
  ln -nfs $DOTFILES_PATH/src/starship.toml $HOME/.config/starship.toml
  eval $(starship init zsh)
fi
