#!/bin/bash

set -u

target="${1:-clipboard}"

case "$target" in
    clipboard)
        label="CLIP"
        paste_args=()
        ;;
    primary)
        label="PRIM"
        paste_args=(--primary)
        ;;
    *)
        printf '{"text":"%s ?","class":"critical","tooltip":"Unknown clipboard target"}\n' "$target"
        exit 0
        ;;
esac

json_escape() {
    local input="$1"
    input=${input//\\/\\\\}
    input=${input//\"/\\\"}
    input=${input//$'\n'/\\n}
    input=${input//$'\r'/}
    input=${input//$'\t'/  }
    printf '%s' "$input"
}

types="$(wl-paste "${paste_args[@]}" --list-types 2>/dev/null || true)"

if [ -z "$types" ]; then
    printf '{"text":"%s --","class":"empty","tooltip":"%s is empty"}\n' "$label" "$label"
    exit 0
fi

if printf '%s\n' "$types" | grep -q '^text/'; then
    content="$(wl-paste "${paste_args[@]}" --no-newline 2>/dev/null || true)"
    if [ -n "$content" ]; then
        preview="$(printf '%s' "$content" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-80)"
        if [ "${#content}" -gt 80 ]; then
            preview="${preview}..."
        fi
        tooltip="${label}: ${preview}"
    else
        tooltip="${label}: empty text payload"
    fi
else
    tooltip="${label}: non-text data available"
fi

printf '{"text":"%s OK","class":"filled","tooltip":"%s"}\n' \
    "$label" \
    "$(json_escape "$tooltip")"
