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
  local command_name
  for command_name in "$@"; do
    command -v "$command_name" >/dev/null 2>&1 && return 0
  done
  return 1
}

# Mark the machine for reconciliation when a tool introduced by a dotfiles
# update is absent. apply performs all network and package-manager work.
DOTFILES_APPLY_NEEDED=0
require_apply_tool() {
  command -v "$1" >/dev/null 2>&1 || DOTFILES_APPLY_NEEDED=1
}

add_package() {
  local package="$1"
  DOTFILES_APPLY_NEEDED=1
  add_apt_package "$package"
  add_brew_package "$package"
  add_pacman_package "$package"
}

# Prefer a native installation, then a dotfiles lazy shim. Native package
# fallbacks are needed only on hosts without mise.
# add_package_mise <tool> [apt-package] [brew-package] [pacman-package]
add_package_mise() {
  local tool="$1"
  local apt_package="${2:-}"
  local brew_package="${3:-${2:-}}"
  local pacman_package="${4:-${2:-}}"

  if command_present "$tool" || [[ -x "$DOTFILES_PATH/bin/shims/$tool" ]]; then
    return
  fi
  [[ -z "${DOTFILES_NO_SHIMS:-}" ]] || return

  DOTFILES_APPLY_NEEDED=1
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

reload() {
  source "$HOME/.${SHELL_ENV}rc"
}

venv() {
  if [[ ! -f .venv/bin/activate ]]; then
    echo " * no python env in $PWD/.venv, create it?"
    read -r Y
    [[ $Y == "y" ]] && python3 -m venv .venv
  fi

  source .venv/bin/activate
  echo " * activated local env"
  VENV_ENV="$(basename "$PWD")"
  export VENV_ENV
}
