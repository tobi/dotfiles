local id="--identity $HOME/.ssh/id_ed25519"
local secrets_file=$DOTFILES_PATH/src/secrets.age
local secrets_hosts=$DOTFILES_PATH/src/secrets.hosts

function eage() {
  # decompress
  local SECRETS=$(age -d -i ~/.ssh/id_ed25519 $secrets_file)
  [[ $! != 0 ]] && echo "!!!cannot decrypt";

  # update
  SECRETS=$(echo $SECRETS | gum write --char-limit=0)
  echo $!
  [[ $! != 0 ]] && (echo "cannot update"; return 1)

  # save
  SECRETS=$(echo $SECRETS | age -e -R $secrets_hosts -i ~/.ssh/id_ed25519 -o $secrets_file -)
  [[ $! != 0 ]] && (echo "cannot encrypt"; return 1)

  echo "updating..."
  echo $SECRETS > $DOTFILES_PATH/secrets.age
}

function ekey() {
  # hosts need to have a private key so that
  # we can make secrets available to them
  if [[ ! -f ~/.ssh/hostkey.pub ]]; then
    echo "generating hostkey..."
    ssh-keygen -t ed25519 -f ~/.ssh/hostkey
    hostkey_pub=$(cat ~/.ssh/hostkey.pub)
  else
    echo "hotkey exists..."
  fi

  if ! grep "$hostkey_pub" $secrets_hosts; then
    append "$hostkey_pub" "$secrets_hosts"
    cd $DOTFILES_PATH/src
    git add secrets.hosts
    git status
    cd $HOME
    echo "add:\n\n$hostkey_pub\n  at https://github.com/tobi/dotfiles/edit/main/secrets.hosts"
  else
    echo "hostkey already in secrets.hosts"
  fi

}

if apt_cmd "age"; then


  # load them in shell
  echo -n "* loading secrets... "
  if [[ -f ~/.ssh/hostkey ]]; then
    eval $(age -d -i ~/.ssh/hostkey $secrets_file)
    [[ $! == 0 ]] && echo "[PASS]" || echo "[FAIL]"

  else
    echo "[FAIL]: no ~/.ssh/hostkey"
  fi
else
  echo "* install age to get secrets access"
fi
