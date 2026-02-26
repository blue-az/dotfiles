#!/bin/bash

if [ -f ~/.config/privacy-mode ]; then
    IP="***.***.***.***"
else
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)[\d.]+' | grep -v 127.0.0.1 | head -1)
fi

if [ -z "$IP" ]; then
    TEXT="<span color='#ffffff'>IP</span> <span color='#ff5555'> disconnected</span>"
else
    TEXT="<span color='#ffffff'>IP</span> <span color='#50fa7b'> ${IP}</span>"
fi

echo "{\"text\": \"${TEXT}\"}"
