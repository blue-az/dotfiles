#!/usr/bin/env bash
# operator-verifier-setup — provision the UID-isolated verifier identity on the seat.
#
# Idempotent. Run with sudo. Safe to re-run.
#
# WHY THIS FILE EXISTS
# EXECUTOR_IDENTITY_SPEC.md:103 puts "provisioning OS users or containers" out of
# scope for operator-control-plane, and correctly so -- it is machine setup, not
# ledger logic. But that exclusion left the one mechanism that makes uid_isolated
# verification real living nowhere at all. On 2026-08-25 it was an ephemeral
# container (uid 971, repo bind-mounted at /repo, --rm). It was never scripted.
# When it exited, trusted verification silently stopped being possible, and the
# loss was only found by digging through session transcripts three days later.
# This script is that mechanism, versioned.
#
# WHAT IT DOES NOT DO
# It does not grant the verifier pi/Codex credentials. That is a live decision:
# sharing ~/.pi/agent/auth.json hands the verifier account the operator's OAuth
# refresh token, which weakens the very boundary the separate UID creates. A
# credential-free verifier that only re-runs a pinned command and records the
# result is the stronger trust story. Decide deliberately; do not default into it.
set -euo pipefail

VERIFIER_USER="uid-971"
VERIFIER_UID="971"
LEDGER="${1:-/home/blueaz/operator-control-plane/.operator}"

[ "$(id -u)" -eq 0 ] || { echo "must run as root (sudo $0)" >&2; exit 1; }

if id -u "$VERIFIER_USER" >/dev/null 2>&1; then
    have="$(id -u "$VERIFIER_USER")"
    [ "$have" = "$VERIFIER_UID" ] || {
        echo "$VERIFIER_USER exists with uid $have, expected $VERIFIER_UID" >&2; exit 1; }
    echo "ok: $VERIFIER_USER already exists (uid $VERIFIER_UID)"
else
    useradd -r -u "$VERIFIER_UID" -M -s /usr/sbin/nologin "$VERIFIER_USER"
    echo "created: $VERIFIER_USER (uid $VERIFIER_UID)"
fi

[ -d "$LEDGER" ] || { echo "no ledger at $LEDGER" >&2; exit 1; }

# The grant must be RECIPROCAL and RECURSIVE. Both halves were learned the hard
# way on 2026-08-30, on the seat ledger, within an hour of writing this script:
#
#   reciprocal -- a one-way "d:u:uid-971:rwx" covers files the OWNER creates. It
#     says nothing about files uid-971 creates, and SQLite makes the -wal/-shm as
#     whoever opens the database first. uid-971 opened it, the WAL came out owned
#     by 971 mode 0664, and blueaz -- now merely "other" -- got exactly the z13
#     error this script was written to prevent: "attempt to write a readonly
#     database". Grant both identities, in both directions.
#
#   recursive -- default entries apply only to entries created AFTER they are
#     set. Subdirectories that already exist inherit nothing, so evidence/<task>/
#     stayed unwritable and evidence-attach died with PermissionError. -R fixes
#     existing content; the d: entries cover future content.
#
# Recovery note if a WAL is already misowned: setfacl cannot touch a file you do
# not own ("Operation not permitted"). With no process holding the database open
# and the WAL at 0 bytes, remove ledger.sqlite3-wal and -shm; SQLite recreates
# them. Back up ledger.sqlite3 first.
OWNER_USER="$(stat -c %U "$LEDGER")"
setfacl -R -m "u:${OWNER_USER}:rwX" -m "u:${VERIFIER_USER}:rwX" \
           -m "d:u:${OWNER_USER}:rwX" -m "d:u:${VERIFIER_USER}:rwX" \
           -m "d:u::rwx" -m "d:g::r-x" -m "d:m::rwx" -m "d:o::r-x" "$LEDGER"
echo "acl set on $LEDGER:"
getfacl -p "$LEDGER" 2>/dev/null | grep -E "^(user|default:user):"

cat <<'NOTE'

Next: the verifier is provisioned but cannot be driven non-interactively until
`sudo -u uid-971` is permitted without a password for the specific review command.
Write that sudoers rule as one exact command, never ALL. Then:

  cd <repo> && ./operator review-delegate <claim> --mode uid-isolated \
      --reviewer <harness> --review-user uid-971

which prints the launch command. review-delegate never verifies by itself;
evidence-attach enforces the final trust mode.
NOTE
