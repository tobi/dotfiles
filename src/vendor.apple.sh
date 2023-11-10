if command_present "brew"; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

add_path "/opt/dev/bin/"
