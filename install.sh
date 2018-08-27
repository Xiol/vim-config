#!/bin/bash

if [[ ! -e dotvimrc ]]; then
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

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
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
          sudo apt-get -y install build-essential CMake python-dev
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
          sudo $YUM -y groupinstall "Development Tools"
          sudo $YUM -y install cmake python-devel
        elif [[ $(uname) == 'Darwin' ]]; then
          echo "Detected OSX, installing CMake with brew."
          brew install CMake
        fi
        ./install.py --clang-completer --gocode-completer
        echo "YCM done."
        break
        ;;
      No)
        sed -i "/YouCompleteMe/c\"Plugin 'Valloric/YouCompleteMe'" "$HOME/.vimrc"
        vim +VundleClean\! +qall
        echo "YCM has been removed from your installation to prevent errors on vim startup."
        break
        ;;
    esac
  done
fi

echo "Finished."

