#!/usr/bin/env bash

HOME=$1
ABS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="${ABS_DIR}/backup"
count_files=0

function print(){
    if [ $# == 2 ]; then
        case $2 in  
            0) icon="\u2713"; color="\u001b[32m";; # success
            1) icon="\u0021"; color="\u001b[33m";; # warning
            2) icon="\u0078"; color="\u001b[31m";; # error
        esac
        COLOR_SUPPORT=$(tput colors 2> /dev/null)
        if [ $? = 0 ] && [ $COLOR_SUPPORT -gt 2 ]; then
            echo -e "$color- [$icon] $1\u001b[0m"
        else
            echo -e "- [ $icon ] $1"
        fi
    fi
}

function createSymLink(){
    if [ -h "$2" ]; then
        print "Removing existing symlink $2" 2
        rm $2
    elif [ -e "$2" ]; then
        mkdir -p $BACKUP_DIR
        mv $2 $BACKUP_DIR
        if [[ -d "$2" ]]; then
            print "Backing up existing directory $2" 1
        elif [[ -f "$2" ]]; then
            print "Backing up existing file $2" 1
        fi
        echo "increment"
        count_files=$((count_files+1))
    fi

    print "creating symlink from $ABS_DIR/$1 to $2" 0
    ln -s $ABS_DIR/$1 $2
}

function update_sys {
    if [ -x "$(command -v pacman)" ]; then 
        sudo pacman -Syu
    elif [ -x "$(command -v apt-get)" ]; then 
        sudo apt-get update 
        sudo apt-get dist-upgrade
    else 
        echo "No supported package manager!"
        exit
    fi
}


# accept only exectution with one param
if (( "$#" != 1 )); then
    echo "Invalid number of parameters"
    echo "Usage: ./script.sh <HOME_DIR>"
    exit
fi

# require root priviledges for package installations/updates
if [ "$EUID" -ne 0 ]; then 
    echo "Please run script as root!"
    # exit
fi


update_sys

# install neovim and plugin manager
if [ -x "$(command -v pacman)" ]; then 
    sudo pacman -S vim neovim git nodejs go
elif [ -x "$(command -v apt-get)" ]; then 
    echo -e "\n\n\n\n"
    sudo apt-get -y install vim neovim git nodejs golang
fi

createSymLink "nvim" $HOME/.config/nvim
createSymLink "vim/vimrc" $HOME/.vimrc
createSymLink "bash/bashrc" $HOME/.bashrc

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


nvim +PluginInstall +qall

# inform user about count of backed-up files
if [ $count_files != 0 ]; then
    echo "$count_files files backed up into $BACKUP_DIR"
fi