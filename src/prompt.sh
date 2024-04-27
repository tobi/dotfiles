# Define the function to parse git branch and modifications
git_branch_to_env() {
  local git_status="$(git status 2>/dev/null)"
  export GIT_BRANCH=$(echo "$git_status" | head -n 1 | sed -e 's/^On branch \(.*\)/\1/')
  export GIT_MODS=$(echo "$git_status" | grep -c "\t" || echo 0)
}

# function git_branch_to_env() {
#   local git=$(git status 2>/dev/null)
#   export GIT_BRANCH=$(echo $git | head -n 1 | sed -e 's/^On branch \(.*\)/\1/')
#   export GIT_MODS=$(echo $git | grep "\t" | wc -l)
# }


# Define color variables with tput
color() {
  echo $(wrap $(tput setaf $1))
}

# wrap in zero length for zsh
wrap() {
  local shell=$*
  [[ $SHELL_ENV == "zsh" ]] && shell="%{$*%}"
  echo $shell
}

# Define color variables with tput
cyan="$(color 6)"
magenta="$(color 5)"
blue="$(color 4)"
green="$(color 2)"
reset="$(wrap $(tput sgr0))"

chevron=$(printf '%s❯%s❯%s❯%s' \
  "$(color 70)" \
  "$(color 220)" \
  "$(color 209)" \
  "$reset")

# Function to update the prompt
update_prompt() {
  local branch=""
  local rprompt=""

  # Check for GIT_BRANCH and set the branch and rprompt
  if [[ $GIT_BRANCH != "" ]]; then
    branch=" ${cyan}($GIT_BRANCH)${reset}"
    rprompt="${green}(git) $GIT_BRANCH: +$GIT_MODS${reset}"
  fi

  # Check for CONDA_DEFAULT_ENV and append to rprompt
  if [[ $VENV_ENV != "" ]]; then
    rprompt="$rprompt ${magenta}[venv:${VENV_ENV}]${reset}"
  elif [[ $CONDA_DEFAULT_ENV != "" ]]; then
    rprompt="$rprompt ${magenta}(conda) $CONDA_DEFAULT_ENV${reset}"
  fi

  # PS1 - Using tput instead of raw escape codes for better readability and maintainability
  local host=""
  if [[ $SSH_CONNECTION ]]; then
    host="${green}[$(hostname)] "
  fi

  # Assign to PS1
  PS1="${host}${blue}%n ${blue}%~${branch} ${chevron}%f "
  PROMPT=$PS1
  RPROMPT="$rprompt"

  # terminal title
  echo -ne "\033]0;$(basename "$(dirname "$PWD")")/$(basename "$PWD") $GIT_BRANCH\007"
}

# For bash, we use PROMPT_COMMAND instead of precmd_functions
PROMPT_COMMAND="git_branch_to_env; update_prompt; $PROMPT_COMMAND"
precmd_functions+=(git_branch_to_env update_prompt)
