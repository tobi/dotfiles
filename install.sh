#/bin/bash

set -e

DOTFILES_PATH=$HOME/dotfiles

function append() {
  local text="$1" file="$2"

  if ! grep -q "$text" "$file"; then
    echo -e "$text" >> "$file"
  fi
}

mkdir -p $HOME/.ssh
append "$(curl https://github.com/tobi.keys)" $HOME/.ssh/authorized_keys

if test -d $HOME/dotfiles; then
  echo "dotfiles exists"
else
  git clone https://github.com/tobi/dotfiles $DOTFILES_PATH
fi

cd $HOME/dotfiles

# install shell hooks
hook="source ~/dotfiles/shell"
append "$hook" $HOME/.zshrc

if command -v 'zsh' &> /dev/null; then
  cd $HOME && exec zsh
else
  echo "* install zsh!"
  echo "  sudo apt install zsh"
fi

echo "chsh -s $(which zsh)"
echo
echo "done"