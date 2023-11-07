missing_cmds=()
missing_scripts=()
missing_package=()

# Function to check for commands, adjusted for Bash
check_cmd_or_install() {
  local cmd="$1"
  local apt_package="${2:-$cmd}"

  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  else
    missing_cmds+=("$cmd")
    missing_package+=("$apt_package")
    return 1
  fi
}

# Function to check for scripts, adjusted for Bash
sh_cmd() {
  local cmd="$1"
  local script="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  else
    missing_cmds+=("$cmd")
    missing_scripts+=("$script")
    return 1
  fi
}

# Function to install missing commands, adjusted for Bash loop syntax
install_missing() {
  set +x
  sudo apt install -y "${missing_package[@]}"
  for i in "${!missing_cmds[@]}"; do
    local script=${missing_scripts[$i]}
    bash -c "$script"
  done
  set -x
}

# Function to append to a file
append_to_file() {
  local text="$1" file="$2"

  if [ ! -f "$file" ]; then
    touch "$file"
  fi

  if ! grep -qF -- "$text" "$file"; then
    echo -e "$text" >> "$file"
    return 0
  fi
  return 1
}

reload() {
  source ~/.zshrc
}
