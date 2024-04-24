# Set variables at the script's top level
id="$HOME/.ssh/id_ed25519"
secrets_file="${DOTFILES_PATH}/src/secrets.age"
hostkey_file="${HOME}/.ssh/hostkey"
secrets_hosts="${DOTFILES_PATH}/src/secrets.hosts"

secrets_edit() {
  tmpfile=$(mktemp -tsecret)

  age --decrypt -i $id -o $tmpfile $secrets_file || {
    printf "!!! cannot decrypt\n"

    if ! grep -qF -- "$hostkey".pub "$secrets_hosts"; then
      printf "    add:\n\n%s\n\n  at https://github.com/tobi/dotfiles/edit/main/src/secrets.hosts\n" $(cat $hostkey.pub)
    fi

    return 1
  }

  crc=$(crc32 $tmpfile)

  nano "$tmpfile" || {
    printf "!!! aborting\n"
    rm "$tmpfile"
    return 1
  }

  if [[ $crc == $(crc32 $tmpfile) ]]; then
    printf "!!! no changes in file\n"
    rm "$tmpfile"
    return 1
  fi

  if ! head -n 1 "$tmpfile" | grep -q "^export " >/dev/null; then
    printf "!!! not valid\n"
    rm "$tmpfile"
    return 1
  fi

  age --encrypt -R $secrets_hosts -i $id -o $secrets_file $tmpfile || {
    printf "!!! cannot encrypt\n"
    rm "$tmpfile"
    return 1
  }

  rm "$tmpfile"
  printf "OK\n"

}

secrets_generate_hostkey() {
  if [ ! -f $hostkey_file ]; then
    printf "generating hostkey...\n"
    ssh-keygen -t ed25519 -f "$hostkey_file"
  else
    #printf "hostkey already exists...\n"
  fi
}

secrets() {
  secrets_generate_hostkey

  # printf "* loading secrets... "
  if ! command -v age >/dev/null 2>&1; then
    #printf "[FAIL]: age not installed\n"
    return 1
  fi

  eval $(age --decrypt -i "$HOME/.ssh/hostkey" "$secrets_file" 2>/dev/null)

}
