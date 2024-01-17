#!/usr/bin/env bash

# ewspace = empty i3-workspace
# - switches to first empty workspace
# - in range between 0 and $MAX_DESKTOPS

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
NUMBER_WINDOWS=$(i3-msg -t get_tree | jq -r "recurse(.nodes[]) | select(.name == \"$CURRENT_WORKSPACE\") | recurse(.nodes[]) | select(.window) | .name" )
# only switch to empty workspace, if current one is filled with atleast one window
echo $NUMBER_WINDOWS
if $NUMBER_WINDOWS ; then
	exit 0;
fi

MAX_DESKTOPS=10
WORKSPACES=$(seq -s '\n' 1 1 ${MAX_DESKTOPS}) # generate list of workspace-numbers
EMPTY_WORKSPACE=$((i3-msg -t get_workspaces | tr ',' '\n' | grep num | awk -F:  '{print int($2)}' ; \
	echo -e ${WORKSPACES} ) | sort -n | uniq -u | head -n 1) # grep workspaces and get first diff with $WORKSPACES
i3-msg -q workspace ${EMPTY_WORKSPACE}
