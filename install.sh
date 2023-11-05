#/bin/bash

set -e

DOTFILES_PATH=$HOME/dotfiles

function append() {
  local text="$1" file="$2"

  if ! grep -q "$text" "$file"; then
    echo "$text" >>"$file"
  fi
}

echo "fetching public key..."
mkdir -p $HOME/.ssh
append "$(curl https://github.com/tobi.keys)" $HOME/.ssh/authorized_keys

echo "installing dotfiles..."
if test -d $HOME/dotfiles; then
  echo "dotfiles exists"
else
  git clone https://github.com/tobi/dotfiles $DOTFILES_PATH
fi

cd $HOME/dotfiles

echo "installing dotfiles to .zshrc..."
hook="source ~/dotfiles/shell"
append "$hook" $HOME/.zshrc

if command -v 'zsh' &>/dev/null; then
  echo "* install zsh!"

  echo "Do you want to change your shell to zsh? (y/n)"
  read answer
  if echo "$answer" | grep -iq "^y"; then
    echo "Changing shell to zsh..."
    sudo apt install zsh
    chsh -s "$(which zsh)"
    echo "Shell changed to zsh."
  else
    echo "Shell not changed."
  fi

fi

echo
echo "done"
