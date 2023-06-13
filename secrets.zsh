# identity="-i ~/.ssh/id_ed25519 -i ~/.ssh/id_rsa"

local id="--identity $HOME/.ssh/id_ed25519"
local secrets_file=$DOTFILES_PATH/secrets.age
local secrets_hosts=$DOTFILES_PATH/secrets.hosts


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
  #echo $SECRETS > $DOTFILES_PATH/secrets.age
}

# load them in shell
echo -n "* loading secrets... "
if [[ -f ~/.ssh/hostkey ]]; then
  eval $(age -d -i ~/.ssh/hostkey $secrets_file)
  [[ $! == 0 ]] && echo "[PASS]" || echo "[FAIL]"

else
  echo "[FAIL]: no ~/.ssh/hostkey"
fi