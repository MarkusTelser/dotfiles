# smartcd ...
# - acts like the standard cd program
# - but understands when the argument is a file-path
# - and suggests to change into parent-folder 
# - without having to manually adjust the argument
# Intended use-cases for faster navigation:
#	- searching for a file in fzf, without knowing the directory name
#	- editing a neighboring file, but you only have the absolute-path to one
# compatible with bash and zsh-syntax

# can't be executed, only sourced
[[ -n $BASH_VERSION && "${BASH_SOURCE[0]}" == "${0}" ]] && echo "smartcd: script can only be sourced..." 1>&2 && return 1
[[ -n $ZSH_VERSION && ! $ZSH_SUBSHELL ]] && echo "smartcd: script can only be sourced..." 1>&2 && return 1

function cd() {
	# replace wierd zsh-error-origin-prefix and convert output to lowercase
	result=$(builtin cd $1 2>&1 | sed -e "s/cd:2://1" | awk '{print tolower($0)}')

	# on success: change into directory 
	if [ -z "$result" ]; then
		builtin cd $1; return 0
	fi
	# on error (other than not a directory): print error and exit
	if [[ ! "$result" =~ "not a directory" ]]; then
		printf '%s\n' "$result"; return 1
	fi

	# get parent directory & replace abs path with tilde
	spath=$( dirname "$1" )
	[[ "$spath" =~ ^"$HOME"(/|$) ]] && spath="~${spath#$HOME}"

	# stop if the parent dir is the current path
	[[ "$spath" == "." ]] && return 1 

	# suggest changing into parent directory
	echo -n "Did you mean \"$spath\"? [Y/n] "
	read uinput 
	case ${uinput:0:1} in 
		y|Y|"" ) builtin cd "`dirname $1`" ;;
	esac
}
