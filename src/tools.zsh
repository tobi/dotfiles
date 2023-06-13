
if cmd_check "starship"; then
  mkdir -p $HOME/.config
  ln -nfs $DOTFILES_PATH/src/starship.toml $HOME/.config/starship.toml
  eval $(starship init zsh)
fi

if cmd_check "zoxide"; then
  eval "$(zoxide init zsh)"
fi

if cmd_check "rg" "ripgrep"; then
  alias grep="rg"
fi

if cmd_check "fd" "fdfind"; then
  alias fd="fdfind"
fi

if cmd_check "exa"; then
  alias ls="exa --group-directories-first"
  alias ll="exa -l --group-directories-first"
  alias la="exa -a --group-directories-first"
  alias lla="exa -la --group-directories-first"
fi

if cmd_check "fzf"; then
  # fzf config (hook: alt-c, ctrl-t, ctrl-r)
  export FZF_DEFAULT_OPTS='--reverse --border --exact --height=60% -m'

  # use best tools to accelerate
  [[ $commands[fd] ]] && export FZF_ALT_C_COMMAND='fd --type directory'
  [[ $commands[rg] ]] && export FZF_DEFAULT_COMMAND='rg --files'
  [[ $commands[mdfind] ]] && export FZF_CTRL_T_COMMAND="mdfind -onlyin . -name ."
fi

cmd_check "gum"

cmd_check "wtf2000"