#!/bin/bash

# notes = automated template setup
# for quickly writing notes in nvim
# and simultaneously previewing them in browser
# plugin: "Markdown-Viewer" by github.com/simov (version 5.1)

# check for title argument
if [ -z "$1" ]; then
	echo "Error: No name as argument privided"
	exit 1
fi

filename=$(basename -- "$1")
extension="${filename##*.}"

# check for wrong file extension types
if [[ "$extension" != "md" && "$extension" != "markdown" ]]; then
	echo "Error: Invalid file type"
	exit 1
fi

# create file and write title, if it exists
if [ ! -f "$1" ]; then
	touch "$1"
	title=${filename%.*} # remove file ending
	echo -e "# ${title^}\n" > "$1"
fi

current_window=$(xdotool getwindowfocus)

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

# open brave with markdown preview plugin
# create new window if none on current desktop
urlencoded=$(rawurlencode "$1")
current_browser=$(xdotool search --desktop $(xdotool get_desktop) --class Brave)
if [ -z "$current_browser" ]; then
	brave --new-window $urlencoded &> /dev/null & 
else
	brave $urlencoded &> /dev/null
fi

# get stolen focus back from browser to terminal
xdotool windowfocus $current_window

# open nvim with cursor at end of file
nvim "+ normal G$" "$1" 
