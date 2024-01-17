#!/usr/bin/env bash

# fmux = fzf + tmux session creator 
# - selects folder in fzf
# - creates + attach tmux session in folders path
# - launch tayout, if session doesn't exist
# heavily inspired by https://github.com/ThePrimeagen

res=$(find ~ -maxdepth 3 -type d | fzf)

# stop if no folder was selected
if [[ -z $res ]]; then
	exit 0
fi

tmux_running=$(pgrep tmux)
fzf_output=$(basename "$res" | tr . _)

# tmux instance does not exist
if [[ -z $tmux_running ]]; then
	tmux new-session -ds $fzf_output -c $res
	if [ -x "$(command -v tayout)" ]; then
		tmux send-keys -t $fzf_output "tayout" ENTER
	fi
# session doesnt exist in tmux instance
elif ! tmux has-session -t=$fzf_output 2> /dev/null; then
	tmux new-session -ds $fzf_output -c $res
	if [ -x "$(command -v tayout)" ]; then
		tmux send-keys -t $fzf_output "tayout" ENTER
	fi
fi

# switch and attach to session
tmux attach-session -d -t $fzf_output
