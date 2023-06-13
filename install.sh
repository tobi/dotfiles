#/bin/bash
set -e
set -x

if [[ $SHELL != '/bin/zsh' ]]; then
  echo "need zsh"
  echo "apt install -y zsh"
  echo "chsh -u $USER -s /bin/zsh"
  return 1
fi

# # append "hi" ./text
# function append() {
#   [[ grep "$1" "$2" ]] && return 0
#   echo "$1" >> $2
# }

mkdir -p ~/.ssh
curl https://github.com/tobi.keys >> ~/.ssh/authorized_keys

if test -d $HOME/dotfiles; then
  echo "dotfiles exists"
else
  git clone https://github.com/tobi/dotfiles $HOME/dotfiles
fi

cd $HOME/dotfiles

# hosts need to have a private key so that
# we can make secrets available to them
if [[ ! -f ~/.ssh/hostkey ]]; then
  ssh-keygen -t ed25519 -f ~/.ssh/hostkey
  local hostkey_pub=$(cat ~/.ssh/hostkey.pub)

  if [[ ! grep "$hostkey_pub" ~/.zshrc ]]; then
    cd ~/dotfiles
    echo $hostkey_pub >> secrets.hosts
    git add secrets.hosts
    git status
  fi
fi

# install shell hooks
hook="source ./dotfiles/shell"
if [[ ! grep "$hook" ~/.zshrc ]]; then
  echo $hook >> ~/.zshrc
fi

echo "done"