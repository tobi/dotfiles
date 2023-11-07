# Set variables at the script's top level
id="--identity $HOME/.ssh/id_ed25519"
secrets_file="${DOTFILES_PATH}/src/secrets.age"
secrets_hosts="${DOTFILES_PATH}/src/secrets.hosts"

eage() {
  SECRETS=$(age -d "$id" "$secrets_file" 2>/dev/null) || {
    printf "!!! cannot decrypt\n"
    return 1
  }

  tmpfile=$(mktemp)

  printf "%s" "$SECRETS" > "$tmpfile"
  unset $SECRETS
  nano "$tmpfile" || {
    printf "!!! aborting\n"
    rm "$tmpfile"
    return 1
  }

  age -e -R "$secrets_hosts" "$id" -o "$secrets_file" "$tmpfile" || {
    printf "!!! cannot encrypt\n"
    rm "$tmpfile"
    return 1
  }

  rm "$tmpfile"
}

ekey() {
  if [ ! -f "$HOME/.ssh/hostkey.pub" ]; then
    printf "generating hostkey...\n"
    ssh-keygen -t ed25519 -f "$HOME/.ssh/hostkey"
  else
    printf "hostkey already exists...\n"
  fi

  hostkey_pub=$(< "$HOME/.ssh/hostkey.pub")

  if ! grep -qF -- "$hostkey_pub" "$secrets_hosts"; then
    printf "add:\n\n%s\n\n  at https://github.com/tobi/dotfiles/edit/main/src/secrets.hosts\n" "$hostkey_pub"
  else
    printf "hostkey already in secrets.hosts\n"
  fi
}

load_secrets() {
  printf "* loading secrets... "
  if ! command -v age >/dev/null 2>&1; then
    printf "[FAIL]: age not installed\n"
    return 1
  fi
  if [ -f "$HOME/.ssh/hostkey" ]; then
    env=$(age -d -i "$HOME/.ssh/hostkey" "$secrets_file" 2>/dev/null) && {
      eval "$env"
      printf "[OK]\n"
    } || {
      printf "[FAIL]\n"
      return 1
    }
  else
    printf "[FAIL]: no ~/.ssh/hostkey\n"
  fi
}
