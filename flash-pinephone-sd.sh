#!/usr/bin/env bash
set -euo pipefail

IMG="/tmp/20260520-0353-postmarketOS-v25.12-phosh-25-pine64-pinephone.img.xz"
EXPECTED_SHA256="ff7ef6e71a3d1f65fc1f44f06ee34d21fb8c838854610145f14d3678a08c59f7"
DEV="/dev/mmcblk0"

if [[ ! -b "$DEV" ]]; then
  echo "Missing target device: $DEV" >&2
  exit 1
fi

if [[ ! -f "$IMG" ]]; then
  echo "Missing image: $IMG" >&2
  exit 1
fi

actual_sha256="$(sha256sum "$IMG" | awk '{print $1}')"
if [[ "$actual_sha256" != "$EXPECTED_SHA256" ]]; then
  echo "SHA-256 mismatch for $IMG" >&2
  echo "expected: $EXPECTED_SHA256" >&2
  echo "actual:   $actual_sha256" >&2
  exit 1
fi

echo "Target device:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINTS,MODEL "$DEV"
echo
echo "This will erase all data on $DEV and write:"
echo "  $IMG"
echo
read -r -p "Type FLASH to continue: " confirm
if [[ "$confirm" != "FLASH" ]]; then
  echo "Aborted."
  exit 1
fi

for part in "${DEV}"p*; do
  if [[ -e "$part" ]]; then
    udisksctl unmount -b "$part" >/dev/null 2>&1 || sudo umount "$part" >/dev/null 2>&1 || true
  fi
done

xzcat "$IMG" | sudo dd of="$DEV" bs=4M status=progress conv=fsync
sync

echo
echo "Flash complete. Remove the microSD card and insert it in the PinePhone upper slot."
