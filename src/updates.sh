#!/bin/bash

sentinel=/tmp/dotfiles.sentinel
# check if the sentinel file exists, or if its older than 2 days
if [ ! -f $sentinel ] || [ $(find $sentinel -mtime +2) ]; then
   cd $DOTFILES_PATH
   git pull --rebase
   if [[ $? -eq 0 ]]; then
      touch $sentinel
   else
      git status
   fi
fi

unset sentinel
