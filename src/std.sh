missing_cmds=()
missing_apt_package=()
missing_brew_package=()

command_present() {

  # test if any of $* is present
  for i in "$@"; do
    if command -v "$i" >/dev/null 2>&1; then
      return 0
    fi
  done

  missing_cmds+=$@
  return 1
}

add_package() {
  local package="$1"
  add_apt_package "$package"
  add_brew_package "$package"
}

add_apt_package() {
  local package="$1"
  missing_apt_package+=("$package")
}

add_brew_package() {
  local package="$1"
  missing_brew_package+=("$package")
}

add_package_report() {
  if [[ $VENDOR == "apple" ]]; then
    [[ ${#missing_brew_package[@]} -eq 0 ]] && return 0
    echo "* grab missing: '$missing_brew_package' with 'install_missing'"
  else
    [[ ${#missing_apt_package[@]} -eq 0 ]] && return 0
    echo "* grab missing: '$missing_apt_package' with 'install_missing'"
  fi
}


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

  if [[ "$VENDOR" == "ubuntu" || "$VENDOR" == "debian" ]]; then
    sudo apt update
    sudo apt install -y "${missing_apt_package[@]}"
  fi

  if [[ "$VENDOR" == "apple" ]]; then
    brew install "${missing_brew_package[@]}"
  fi

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

venv() { 
  if [[ ! -f .venv/bin/activate ]]; then
    echo " * no python env in $PWD/.venv, create it?"
    read Y
    [[ $Y == "y" ]] && python3 -m venv .venv
  fi
  
  source .venv/bin/activate
  echo " * activated local env"
  export VENV_ENV="$(basename $PWD)"
 }
