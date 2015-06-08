#!/bin/bash

if [[ ! -d dotvim || ! -e dotvimrc ]]; then
  echo "You have to execute this from the same directory as the config files."
  exit 1
fi

if [[ -e "$HOME/.vimrc" || -e "$HOME/.vim" ]]; then
  echo "Existing vim configuration found, aborting. Please backup/remove existing configuration."
  exit 2
fi

cp dotvimrc "$HOME/.vimrc"
cp -r dotvim "$HOME/.vim"
vim +VundleInstall +qall
sed -i 's/silent! //' "$HOME/.vimrc"

echo "Perform YouCompleteMe installation?"
select yn in "Yes" "No"; do
  case $yn in
    Yes) 
      cd "$HOME/.vim/bundle/YouCompleteMe"
      echo "Blind assumption: You're running Debian."
      echo "Need to install build-essential, CMake and python-dev. Please enter sudo password:"
      sudo apt-get install build-essential CMake python-dev
      ./install.sh --clang-completer
      echo "YCM done."
      break
      ;;
    No)
      echo "Vim will likely throw errors on startup until you complete YCM installation or remove the Plugin."
      break
      ;;
  esac
done

echo "Finished."

