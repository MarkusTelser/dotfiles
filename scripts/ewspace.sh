#!/usr/bin/env bash

# ewspace = empty i3-workspace
# - switches to first empty workspace
# - in range between 0 and $MAX_DESKTOPS

MAX_DESKTOPS=10
WORKSPACES=$(seq -s '\n' 1 1 ${MAX_DESKTOPS}) # generate list of workspace-numbers
EMPTY_WORKSPACE=$((i3-msg -t get_workspaces | tr ',' '\n' | grep num | awk -F:  '{print int($2)}' ; \
	echo -e ${WORKSPACES} ) | sort -n | uniq -u | head -n 1) # grep workspaces and get first diff with $WORKSPACES
i3-msg -q workspace ${EMPTY_WORKSPACE}
