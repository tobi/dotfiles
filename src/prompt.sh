#!/usr/bin/env bash

# Define the function to parse git branch and modifications
git_branch_to_env() {
  local git_status
  git_status=$(git status --porcelain --branch 2>/dev/null)
  GIT_BRANCH=$(echo "$git_status" | sed -n 's/^## //;s/\.\.\..*//p')
  GIT_MODS=$(echo "$git_status" | grep -cv "^??")
  export GIT_BRANCH GIT_MODS
}

wrap() {
  if [[ $SHELL_ENV == "zsh" ]]; then
    echo "%{$*%}"
  else
    echo "\[$*\]"
  fi
}

# Define color variables
cyan="$(wrap '\033[36m')"
magenta="$(wrap '\033[35m')"
blue="$(wrap '\033[34m')"
green="$(wrap '\033[32m')"
red="$(wrap '\033[31m')"
reset="$(wrap '\033[0m')"

chevron=$(printf '%s❯%s❯%s❯%s' \
  "$(wrap '\033[32m')" \
  "$(wrap '\033[33m')" \
  "$(wrap '\033[31m')" \
  "$reset")

# Function to update the prompt for Zsh
update_prompt_zsh() {
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

  # Set up PS1
  local host=""
  if [[ $SSH_CONNECTION ]]; then
    host="${green}[$(hostname)] "
  fi

  # Assign to PS1
  PS1="${host}${blue}%n ${blue}%~${branch} ${chevron}%f "
  PROMPT=$PS1
  RPROMPT="$rprompt"

  # terminal title
  # PS1+="\[\033]0;\w\007\]"
}

# Function to update the prompt for Bash
update_prompt_bash() {
  local exit_code=$?
  local branch=""
  local rprompt=""

  # Check for GIT_BRANCH and set the branch and rprompt
  if [[ -n $GIT_BRANCH ]]; then
    branch=" \[${cyan}\]($GIT_BRANCH)\[${reset}\]"
    rprompt="\[${green}\](git) $GIT_BRANCH: +$GIT_MODS\[${reset}\]"
  fi

  # Check for virtual environments
  if [[ -n $VIRTUAL_ENV ]]; then
    rprompt="$rprompt \[${magenta}\][venv:$(basename "$VIRTUAL_ENV")]\[${reset}\]"
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    rprompt="$rprompt \[${magenta}\](conda) $CONDA_DEFAULT_ENV\[${reset}\]"
  fi

  # Set host for SSH connections
  local host=""
  if [[ -n $SSH_CONNECTION ]]; then
    host="\[${green}\][$(hostname)] \[${reset}\]"
  fi

  # Set exit code indicator
  local exit_indicator=""
  if [[ $exit_code -ne 0 ]]; then
    exit_indicator="\[${red}\]✘ ${exit_code}\[${reset}\]"
  fi

  if [[ -n $rprompt ]]; then
    rprompt="-> $rprompt\n"
  fi

  # Set prompt
  PS1="[bash] ${exit_indicator}${host}\[${blue}\]\u \[${blue}\]\w${branch} ${chevron}\[${reset}\] "

  # Set terminal title (works in most terminal emulators)
  # PS1+="\[\033]0;\w\007\]"
}

if [[ -n $BASH ]]; then
  PROMPT_COMMAND="git_branch_to_env; update_prompt_bash"
  update_prompt_bash
else
  PROMPT_COMMAND="git_branch_to_env; update_prompt_zsh"
  update_prompt_zsh
fi
