#!/bin/bash

if [[ ! -d dotvim || ! -e dotvimrc ]]; then
  echo "You have to execute this from the same directory as the config files."
  exit 1
fi

if [[ -e "$HOME/.vimrc" || -e "$HOME/.vim" ]]; then
  echo "Existing vim configuration found, aborting. Please backup/remove existing configuration."
  exit 2
fi

if [[ ! -x /usr/bin/git ]]; then
  echo "Please install git"
  exit 3
fi

cp dotvimrc "$HOME/.vimrc"
cp -r dotvim "$HOME/.vim"

if [[ ! -d "$HOME/.vim/bundle" ]]; then
  mkdir "$HOME/.vim/bundle"
fi

git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

vim +VundleInstall +qall
sed -i 's/silent! //' "$HOME/.vimrc"

if grep -q "Valloric/YouCompleteMe" "$HOME/.vimrc"; then
  echo "Perform YouCompleteMe installation?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes) 
        cd "$HOME/.vim/bundle/YouCompleteMe"
        if [[ -e /etc/debian_version ]]; then
          echo "Detected Debian-family distro."
          echo "Need to install build-essential, CMake and python-dev. Please enter sudo password:"
          sudo apt-get install build-essential CMake python-dev
        elif [[ -e /etc/redhat-release ]]; then
          echo "Detected RHEL-family distro."
          echo "Need to install Development Tools, cmake and python-devel. This will install a fair"
          echo "amount of potentially unnecessary packages, so you might want to CTRL+C and manually"
          echo "install if you don't want/need the Dev Tools group installed."
          if [[ -x /usr/bin/dnf ]]; then
            YUM="/usr/bin/dnf"
          else
            YUM="/usr/bin/yum"
          fi
          sudo $YUM groupinstall "Development Tools"
          sudo $YUM install cmake python-devel
        fi
        ./install.sh --clang-completer --gocode-completer
        echo "YCM done."
        break
        ;;
      No)
        echo "Vim will likely throw errors on startup until you complete YCM installation or remove the Plugin."
        break
        ;;
    esac
  done
fi

echo "Finished."

