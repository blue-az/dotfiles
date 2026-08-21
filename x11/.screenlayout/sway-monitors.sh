#!/bin/sh
# Shared monitor identifiers for the sway-*.sh layout scripts. Sourced, not run.
#
# Outputs are matched by identifier ("make model serial") rather than connector
# name. Connector names are handed out by the GPU and shifted when the RTX 2080
# went in: the left Acer moved DP-3 -> DP-1, so every layout script's opening
# `output DP-1 disable` switched off the left Acer instead of the 1080p TV, and
# DP-3 no longer existed at all. Identifiers follow the monitor, so they survive
# GPU swaps and cable moves.
#
# Refresh after a hardware change with:
#   swaymsg -t get_outputs -r | jq -r '.[] | "\(.make) \(.model) \(.serial)"'
#
# The embedded double quotes are required: swaymsg joins its arguments into a
# single command string, so an identifier containing spaces has to stay quoted
# inside that string or sway parses each word as a separate argument.

LEFT='"Acer Technologies Acer AL2216W L92080554231"'
MAIN='"Acer Technologies XB271HU #ASP2u3xvGwHd"'
TV4K='"LG Electronics LG TV SSCR2 0x01010101"'

# The 1080p LG TV. Note both LG sets report serial 0x01010101 and differ only by
# model string - the 4K is "LG TV SSCR2", this one is plain "LG TV". Do not drop
# the model word or the two become indistinguishable.
TV1080='"LG Electronics LG TV 0x01010101"'

# out <identifier> <args...> - configure one output, skipping unknown monitors
# so a missing identifier degrades the layout instead of erroring.
out() {
	[ -n "$1" ] || return 0
	id=$1
	shift
	swaymsg "output $id $*"
}
