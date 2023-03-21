#!/usr/bin/env bash

HOME=$1
CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="${CDIR}/backup"
backup_files=()

# ------------------
# UTILITY FUNCTIONS
# ------------------

function print(){
    if [ $# == 2 ]; then case $2 in
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
    if [ -e "$2" ] && [ ! -h "$2" ]; then
				cd $CDIR && sudo -u $RUSER mkdir -p $BACKUP_DIR

				# if directory exists and is not empty
        if [[ -d "$2" ]] && [[ ! -z "$(ls -A "$2")" ]]; then
            print "removing existing directory $2" 2
						backup_files+=("$2")
        elif [[ -f "$2" ]]; then
            print "removing existing file $2" 2
		        backup_files+=("$2")
        fi
				cp -RL $2 $BACKUP_DIR && rm -rf $2
    fi

    if [ -h "$2" ]; then
				print "updating existing symlink at $2 (to $1)" 1
        rm $2
		else
				print "creating symlink at $2 (to $1)" 0
		fi
		sudo -u $RUSER ln -s $1 $2
}

function update_sys {
    if [ -x "$(command -v pacman)" ]; then
        pacman --noconfirm -Syu 1> /dev/null
    elif [ -x "$(command -v apt-get)" ]; then
        apt-get -y update 1> /dev/null
        apt-get -y dist-upgrade 1> /dev/null
    else
        echo "No supported package manager!"
        exit 1
    fi
}


# ------------------
# MODULE FUNCTIONS 
# ------------------ 
# "alacritty" "bash" "zsh" "tmux" "nvim" "i3" "scripts"

function pre_modules {
	if [[ ! -d $HOME/.config ]]; then
		sudo -u $RUSER mkdir -p $HOME/.config
	fi

	# exit if package-manager lock can't be is acquired
	if [ -x "$(command -v pacman)" ] && ! pacman --noconfirm -Sy &> /dev/null ; then
			echo "pacman lock can not be acquired!"
			exit 1
	elif [ -x "$(command -v apt-get)" ] && ! apt-get -y install &> /dev/null ; then
			echo "apt-get lock can not be acquired!"
			exit 1
	fi 

	# install fonts if one of following modules is present 
	if [[ "${modules[*]}" =~ "alacritty" ]] \
	|| [[ "${modules[*]}" =~ "bash" ]] \
	|| [[ "${modules[*]}" =~ "zsh" ]] \
	|| [[ "${modules[*]}" =~ "i3" ]]; then
		if [ -x "$(command -v pacman)" ]; then
			pacman --noconfirm -S curl ttf-dejavu
		elif [ -x "$(command -v apt-get)" ]; then
			apt-get -y install curl
		fi	

		sudo -u $RUSER mkdir -p $HOME/.local/share/fonts
		cd $HOME/.local/share/fonts

		# install SourceCodePro Regular Semibold Italic Semibold-Italic
		sudo -u $RUSER mkdir -p SourceCodePro && cd SourceCodePro
		sudo -u $RUSER curl -fLo "Source Code Pro Regular Nerd Font Complete.ttf"\
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "Source Code Pro Regular Nerd Font Complete-Mono.ttf"\
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf
		sudo -u $RUSER curl -fLo "Source Code Pro Semibold Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Semibold/complete/Sauce%20Code%20Pro%20Semibold%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "Source Code Pro Semibold Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Semibold/complete/Sauce%20Code%20Pro%20Semibold%20Nerd%20Font%20Complete%20Mono.ttf
		sudo -u $RUSER curl -fLo "Source Code Pro Italic Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Italic/complete/Sauce%20Code%20Pro%20Italic%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "Source Code Pro Italic Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Italic/complete/Sauce%20Code%20Pro%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
		sudo -u $RUSER curl -fLo "Source Code Pro Semibold Italic Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Semibold-Italic/complete/Sauce%20Code%20Pro%20Semibold%20Italic%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "Source Code Pro Semibold Italic Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/SourceCodePro/Semibold-Italic/complete/Sauce%20Code%20Pro%20Semibold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
		cd ../

		# install DejaVuSansMono Regular Bold Italic Bold-Italic
		sudo -u $RUSER mkdir -p DejaVuSansMono && cd DejaVuSansMono
		sudo -u $RUSER curl -fLo "DejaVu Sans Mono Regular Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "DejaVu Sans Mono Regular Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete%20Mono.ttf	
		sudo -u $RUSER curl -fLo "DejaVu Sans Mono Bold Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Bold/complete/DejaVu%20Sans%20Mono%20Bold%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "DejaVu Sans Mono Bold Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Bold/complete/DejaVu%20Sans%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
		sudo -u $RUSER curl -fLo "DejaVu Sans Mono Italic Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Italic/complete/DejaVu%20Sans%20Mono%20Oblique%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "DejaVu Sans Mono Italic Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Italic/complete/DejaVu%20Sans%20Mono%20Oblique%20Nerd%20Font%20Complete%20Mono.ttf
		sudo -u $RUSER curl -fLo "DejaVu Sans Mono Bold Italic Nerd Font Complete.ttf" \
			https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Bold-Italic/complete/DejaVu%20Sans%20Mono%20Bold%20Oblique%20Nerd%20Font%20Complete.ttf
		# sudo -u $RUSER curl -fLo "DejaVu Sans Mono Bold Italic Nerd Font Complete-Mono.ttf" \
		# 	https://github.com/ryanoasis/nerd-fonts/raw/v2.2.2/patched-fonts/DejaVuSansMono/Bold-Italic/complete/DejaVu%20Sans%20Mono%20Bold%20Oblique%20Nerd%20Font%20Complete%20Mono.ttf
	fi

	# install fzf,neofetch,aliases,dircolors if one of following modules is present 
	if [[ "${modules[*]}" =~ "bash" ]] \
	|| [[ "${modules[*]}" =~ "zsh" ]]; then
		if [ -x "$(command -v pacman)" ]; then
			pacman --noconfirm -S fzf neofetch
		elif [ -x "$(command -v apt-get)" ]; then
			apt-get -y install fzf neofetch	
		fi

		createSymLink $CDIR/aliases/aliasrc $HOME/.config/aliasrc
		createSymLink $CDIR/dircolors/dir_colors $HOME/.dircolors
	fi
}

function alacritty {
	# install terminal (alacritty)
	if [ -x "$(command -v pacman)" ]; then
		pacman --noconfirm -S alacritty
	elif [ -x "$(command -v apt-get)" ]; then
		add-apt-repository -y ppa:aslatter/ppa
		apt-get -y update
		apt-get -y install alacritty 
	fi
	
	createSymLink "$CDIR/alacritty/" "$HOME/.config/alacritty"
	ln -sf "/usr/bin/alacritty" "/usr/bin/terminal"
}


function bash {
	if [ -x "$(command -v pacman)" ]; then
		pacman --noconfirm -S bash
	elif [ -x "$(command -v apt-get)" ]; then
		apt-get -y install bash
	fi
	
	createSymLink $CDIR/bash/bashrc $HOME/.bashrc
	createSymLink $CDIR/bash/bash_prompt $HOME/.bash_prompt
	createSymLink $CDIR/bash/bash_profile $HOME/.bash_profile
}

function zsh {
	if [ -x "$(command -v pacman)" ]; then
		pacman --noconfirm -S zsh zsh-completions git
	elif [ -x "$(command -v apt-get)" ]; then
		apt-get -y install zsh git
	fi

	sudo -u $RUSER \
		git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

	if [[ ! -d $HOME/.config/zsh ]]; then
		sudo -u $RUSER mkdir -p $HOME/.config/zsh
	fi
	
	createSymLink $CDIR/zsh/zshenv $HOME/.zshenv
	createSymLink $CDIR/zsh/zshrc $HOME/.config/zsh/.zshrc
	createSymLink $CDIR/zsh/zsh_prompt $HOME/.config/zsh/.zsh_prompt
	createSymLink $CDIR/zsh/plugins $HOME/.config/zsh/.plugins
}

function tmux {
	if [ -x "$(command -v pacman)" ]; then
		pacman --noconfirm -S tmux
	elif [ -x "$(command -v apt-get)" ]; then
		apt-get -y install tmux
	fi

	if [[ ! -d $HOME/.config/tmux ]]; then
		sudo -u $RUSER mkdir -p $HOME/.config/tmux
	fi
	
	createSymLink $CDIR/tmux $HOME/.config/tmux
}

function nvim {
	# install neovim through official distro repos
	if [ -x "$(command -v pacman)" ]; then
    pacman --noconfirm -S vim neovim nodejs go clang python3 python-pip base-devel fd ripgrep
	elif [ -x "$(command -v apt-get)" ]; then
		add-apt-repository -y ppa:neovim-ppa/stable
		apt-get -y update
		apt-get -y install vim neovim nodejs golang clangd python3 python3-pip build-essential fd-find ripgrep
		ln -sf $(which fdfind) ~/.local/bin/fd
		print "WARNING: Make sure that \$HOME/.local/bin is in your \$PATH" 1
	fi
	sudo -u $RUSER pip3 install pyright

	# install nvim plugin manager "plug"
	sudo -u $RUSER curl -fLo ~/.local/share/nvim/site/autoload/plug.vim \
		--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	createSymLink $CDIR/nvim $HOME/.config/nvim
	createSymLink $CDIR/vim/vimrc $HOME/.vimrc

	sudo -u $RUSER nvim +PlugInstall +qall
}

# TODO test setup
function i3 {
	if [ -x "$(command -v pacman)" ]; then
    pacman --noconfirm -S dmenu # breaks dependencys with dmenu-manjaro
    pacman --noconfirm -S i3status # breaks dependencys with i3status-manjaro
    pacman --noconfirm -S i3-wm i3-gaps i3lock feh picom udiskie flameshot
	elif [ -x "$(command -v apt-get)" ]; then
		apt-get -y install i3 dmenu feh picom udiskie flameshot
	fi

	if [[ ! -d $HOME/.config/i3 ]]; then
		sudo -u $RUSER mkdir -p $HOME/.config/i3
	fi

	if [[ ! -d $HOME/.config/i3status ]]; then
		sudo -u $RUSER mkdir -p $HOME/.config/i3status
	fi

	if [[ ! -d $HOME/.config/flameshot ]]; then
		sudo -u $RUSER mkdir -p $HOME/.config/flameshot
	fi

	createSymLink $CDIR/i3/dmenurc $HOME/.dmenurc
	createSymLink $CDIR/i3/picom.conf $HOME/.config/picom.conf
	createSymLink $CDIR/i3/config $HOME/.config/i3/config
	createSymLink $CDIR/i3/i3status $HOME/.config/i3status/config
	createSymLink $CDIR/i3/flameshot.ini $HOME/.config/flameshot/flameshot.ini

	# download background-wallpapers into '~/Pictures/i3-wallpapers'
	sudo -u $RUSER mkdir -p $HOME/Pictures/i3-wallpapers
	cd $HOME/Pictures/i3-wallpapers
	curl -fLo "layered-mountain-view.jpg" "https://images.pexels.com/photos/1323550/pexels-photo-1323550.jpeg?cs=srgb&dl=pexels-simon-berger-1323550.jpg&fm=jpg&w=4608&h=2963"
	curl -fLo "seiser-alm2.jpg" "https://backiee.com/static/wpdb/wallpapers/3840x2160/190580.jpg"
	curl -fLo "promontory-point-chicago.png" "https://i.redd.it/t7v63cixnni91.png"
	curl -fLo "green-rice-field-sky.jpg" "https://images.pexels.com/photos/1146708/pexels-photo-1146708.jpeg?cs=srgb&dl=pexels-johannes-plenio-1146708.jpg&fm=jpg&w=5068&h=2850"
}

function scripts {
	if [[ ! -d $HOME/.local/bin ]]; then
		sudo -u $RUSER mkdir -p $HOME/.local/bin
	fi

	if [ -x "$(command -v pacman)" ]; then
    pacman --noconfirm -S bat xdotool gawk sed
	elif [ -x "$(command -v apt-get)" ]; then
		apt-get -y install bat xdotool gawk sed
		# on debian or ubuntu bat useses the batcat command by default
		createSymLink /usr/bin/batcat $HOME/.local/bin/bat
	fi

	chmod +x $CDIR/scripts/*

	for filename in $CDIR/scripts/*; do
		createSymLink $filename $HOME/.local/bin/$(basename ${filename%.sh})
	done
}

# -------------
# MAIN SCRIPT
# -------------

# require root priviledges for package installations/updates
if [ "$EUID" -ne 0 ]; then
    echo "Please run script as root!"
    exit 1
fi

# get real user
if [ $SUDO_USER ]; then
    RUSER=$SUDO_USER
else
    RUSER=$(whoami)
fi

# accept only exectution with one param
if (( "$#" != 1 )); then
    echo "Invalid number of parameters"
    echo "Usage: ./script.sh <HOME_DIR>"
    exit 1
fi

modules=("alacritty" "bash" "zsh" "tmux" "nvim" "i3" "scripts")
echo "Available modules: ${modules[@]}"
read -p "Do you want to install all? Include/Exclude some? [AIE] " uinput

case ${uinput:0:1} in 
	a|A ) ;;
	i|I ) 
		read -p "Modules to include: " uinput
		for i in ${modules[@]}; do
			test=0
			for j in ${uinput[@]}; do 
				[[ $i == $j ]] && test=1
			done
			[[ $test -eq 0 ]] && modules=("${modules[@]/$i}")
		done ;;
	e|E ) 
		read -p "Modules to exclude: " uinput
		for del in ${uinput[@]}; do
			 modules=("${modules[@]/$del}") 
		done ;;
	* ) exit 1;; 
esac

echo "Selected modules: " ${modules[@]} | xargs
read -p "Are you sure? [Y/n] " uinput
case ${uinput:0:1} in 
	y|Y ) ;;
	* ) exit 1;; 
esac

# update_sys
pre_modules

# call functions of selected modules
for module_func in ${modules[@]}; do
	$module_func
done

# inform user about count of backed-up files
echo
if [[ ${#backup_files[@]} -gt 0 ]]; then
	echo "${#backup_files[@]} files backed up into $BACKUP_DIR"
	for item in "${backup_files[@]}"; do
			echo "- $item"
	done
else
	echo "No files backed up into $BACKUP_DIR"
fi

echo 
echo "For changes to take affect,"
echo "you have to open a new terminal instance or"
echo "'source ~/.bashrc' and 'source ~/.config/zsh/.zshrc'"
