#/bin/bash

set -e

DOTFILES_PATH=$HOME/dotfiles

append() {
  local text="$1" file="$2"

  [[ ! -f $file ]] && touch $file

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

echo "installing dotfiles to zsh/bash"
echo "# Dotfiles" > $HOME/.zshrc
echo "source \$HOME/dotfiles/shell" >> $HOME/.zshrc
touch $HOME/.zshrc.local

chmod -w $HOME/.zshrc
ln -nfs $HOME/.zshrc $HOME/.bashrc

echo
echo "done"
