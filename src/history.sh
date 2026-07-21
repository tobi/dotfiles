# history config

# Detect shell first so the rest can branch
if [ -n "$BASH_VERSION" ]; then
  export SHELL_ENV="bash"
elif [ -n "$ZSH_VERSION" ]; then
  export SHELL_ENV="zsh"
fi

export HISTSIZE=50000

if [[ "$SHELL_ENV" == "zsh" ]]; then
  export HISTFILE="$HOME/.cache/.zsh_history"
  export SAVEHIST=50000
  setopt SHARE_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS
elif [[ "$SHELL_ENV" == "bash" ]]; then
  export HISTFILE="$HOME/.cache/.bash_history"
  export HISTFILESIZE=50000
  export HISTCONTROL="erasedups:ignoredups:ignorespace"
  export HISTIGNORE="ls:ll:la:lla:pwd:exit:clear:z"
  shopt -s histappend
fi
