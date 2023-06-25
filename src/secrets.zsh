local id="--identity $HOME/.ssh/id_ed25519"
local secrets_file=$DOTFILES_PATH/src/secrets.age
local secrets_hosts=$DOTFILES_PATH/src/secrets.hosts

function eage() {
  # decompress
  local SECRETS=$(age -d -i ~/.ssh/id_ed25519 $secrets_file)
  if [[ $? != 0 ]]; then 
    echo "!!! cannot decrypt" 
    return 1;
  fi

  tmpfile=$(mktemp)
  echo "$SECRETS" > $tmpfile
  # update
  nano $tmpfile
  if [[ $? != 0 ]]; then 
    echo "aborting"; 
    rm $tmpfile
    return 1
  else
    SECRETS=$(cat $tmpfile)
    rm $tmpfile
  fi

  # save
  SECRETS=$(echo $SECRETS | age -e -R $secrets_hosts -i ~/.ssh/id_ed25519 -o $secrets_file -)
  if [[ $? != 0 ]]; then 
    echo "cannot encrypt" 
    return 1
  fi

  echo "updating..."
  echo $SECRETS > $DOTFILES_PATH/secrets.age
  return 0
}

function ekey() {
  # hosts need to have a private key so that
  # we can make secrets available to them
  if [[ ! -f ~/.ssh/hostkey.pub ]]; then
    echo "generating hostkey..."
    ssh-keygen -t ed25519 -f ~/.ssh/hostkey
  else
    echo "hotkey already exists..."
  fi

  hostkey_pub=$(cat ~/.ssh/hostkey.pub)

  if ! grep "$hostkey_pub" $secrets_hosts; then
    echo "add:\n\n$hostkey_pub\n  at https://github.com/tobi/dotfiles/edit/main/secrets.hosts"
  else
    echo "hostkey already in secrets.hosts"
  fi

}

if apt_cmd "age"; then


  # load them in shell
  echo -n "* loading secrets... "
  if [[ -f ~/.ssh/hostkey ]]; then
    local env=$(age -d -i ~/.ssh/hostkey $secrets_file)
    if [[ $? != 0 ]]; then 
      echo "[FAIL]"; 
      return 1;
    fi
    eval "$env"
    echo "[OK]"

  else
    echo "[FAIL]: no ~/.ssh/hostkey"
  fi
else
  echo "* install age to get secrets access"
fi
