# history conifg
export HISTFILE="$HOME/.cache/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
export HISTIGNORE="ls:ll:la:lla:pwd:exit:clear:z"
setopt SHARE_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS

if [ -n "$BASH_VERSION" ]; then
  shopt -s histappend
  export SHELL_ENV="bash"
elif [ -n "$ZSH_VERSION" ]; then
  export SHELL_ENV="zsh"
fi