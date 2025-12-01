#!/bin/bash
# Restore all saved workspaces
for ws in $(i3-resurrect ls | grep -oP 'workspace_\K[^_]+' | sort -u); do
    i3-resurrect restore -w "$ws"
done
echo "Session restored"
