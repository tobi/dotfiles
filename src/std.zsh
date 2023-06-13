declare -a missing_cmds=();

# for conditional execution
function cmd_check() {
  local cmd="$1"
  local package="${2:-$cmd}"

  if [[ $commands[$cmd] ]]; then
    return 0
  else
    missing_cmds+=("$package")

    function $cmd {

      echo "install $package? y/N: "
      read -p response

      if [[ $response == [Yy] ]]; then
          sudo apt install -y "$package"
      fi
    }

    return 1
  fi
}

function append_to_file() {
  local text="$1" file="$2"

  if ! grep -q "$text" "$file"; then
    echo -e "$text" >> "$file"
  fi
}