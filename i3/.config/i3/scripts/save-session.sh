#!/bin/bash
# Save all active workspaces
for ws in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
    i3-resurrect save -w "$ws"
done
echo "Session saved"
