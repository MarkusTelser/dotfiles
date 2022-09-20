#!/usr/bin/env bash

# tayout = tmux + layout
# workplace-setup (pane-layout & auto-tools-startup)

tmux rename-window -t 0 default

W=$(tmux display -p -t 0 '#{window_width}')
OFFW=$((W / 10))

tmux send-keys 'clear' Enter
tmux send-keys 'git status' Enter

tmux split-window -h
tmux selectp -t 1 
tmux resize-pane -L $OFFW
tmux send-keys 'clear && (ls TODO.md &> /dev/null && nvim TODO.md) || nvim' Enter

tmux selectp -t 0
tmux split-window -v
tmux selectp -t 1
tmux send-keys 'clear' Enter
tmux send-keys 'ls -l' Enter

tmux selectp -t 0
