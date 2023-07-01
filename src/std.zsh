declare -a missing_cmds=();
declare -a missing_scripts=();
declare -a missing_package=();

# for conditional execution
function apt_cmd() {
  local cmd="$1"
  local package="${2:-$cmd}"

  if [[ $commands[$cmd] ]]; then
    return 0
  else
    missing_cmds+=("$cmd")
    missing_package+=("$package")
    return 1
  fi
}

# for conditional execution
function sh_cmd() {
  local cmd="$1"
  local script="$2"

  if [[ $commands[$cmd] ]]; then
    return 0
  else
    missing_cmds+=("$cmd")
    missing_scripts+=("$script")
    return 1
  fi
}

function einstall() {
  set +x
  sudo apt install -y $missing_package;
  # for each cmd
  for i in {1..${#missing_cmds[@]}}; do
    local script=${missing_scripts[$i]}
    bash -c "$script"
  done
  set -x
}

function append_to_file() {
  local text="$1" file="$2"

  if ! grep -q "$text" "$file"; then
    echo -e "$text" >> "$file"
    return 0
  fi
  return 1
}


function reload() {
  source ~/.zshrc
}
