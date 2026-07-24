# Detect the OS vendor once. Sourced before any add_package_* call.
if [[ -z "${VENDOR:-}" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    export VENDOR="apple"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "${ID:-}" in
      ubuntu|pop)      export VENDOR="ubuntu" ;;
      debian)          export VENDOR="debian" ;;
      arch|manjaro|garuda|endeavouros|cachyos) export VENDOR="arch" ;;
      *)               export VENDOR="${ID:-unknown}" ;;
    esac
  else
    export VENDOR="unknown"
  fi
fi
missing_cmds=()
missing_apt_package=()
missing_brew_package=()
missing_pacman_package=()

# Detect mise once; package declarations reuse this instead of spawning checks.
if command -v mise >/dev/null 2>&1; then
  MISE_AVAILABLE=1
else
  MISE_AVAILABLE=0
fi

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

# Mark the machine for reconciliation when a tool introduced by a dotfiles
# update is absent. apply.sh performs all network and package-manager work.
DOTFILES_APPLY_NEEDED=0
require_apply_tool() {
  command -v "$1" >/dev/null 2>&1 || DOTFILES_APPLY_NEEDED=1
}

add_package() {
  local package="$1"
  add_apt_package "$package"
  add_brew_package "$package"
  add_pacman_package "$package"
}

# Prefer mise, with optional native fallbacks:
# add_package_mise <tool> [apt-package] [brew-package] [pacman-package]
add_package_mise() {
  local tool="$1"
  local apt_package="${2:-}"
  local brew_package="${3:-${2:-}}"
  local pacman_package="${4:-${2:-}}"

  if [[ "$MISE_AVAILABLE" == 1 ]]; then
    return
  fi

  case "$VENDOR" in
    ubuntu|debian)
      [[ -z "$apt_package" ]] || add_apt_package "$apt_package"
      ;;
    apple)
      [[ -z "$brew_package" ]] || add_brew_package "$brew_package"
      ;;
    arch)
      [[ -z "$pacman_package" ]] || add_pacman_package "$pacman_package"
      ;;
    *)
      ;;
  esac
}

add_apt_package() {
  local package="$1"
  missing_apt_package+=("$package")
}

add_brew_package() {
  local package="$1"
  missing_brew_package+=("$package")
}

add_pacman_package() {
  local package="$1"
  missing_pacman_package+=("$package")
}

# Function to append to a file
append_to_file() {
  local text="$1" file="$2"

  if [ ! -f "$file" ]; then
    touch "$file"
  fi

  if ! grep -qF -- "$text" "$file"; then
    echo -e "$text" >>"$file"
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
