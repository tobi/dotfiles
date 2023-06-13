declare -a missing_cmds=();

# for conditional execution
function cmd_check() {
  local cmd=$1
  if [[ $commands[$cmd] ]]; then
    return 0
  else
    missing_cmds+=("$package")

    # function $cmd {
    #   echo "install $cmd?"
    #   read -p "y/N"
    #   [[ $? == 0 ]] && apt install -y $package
    # }

    return 1
  fi
}
