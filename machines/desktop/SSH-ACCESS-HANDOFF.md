# SSH access handoff

The desktop at `192.168.8.171` is reachable over SSH. The ED25519 host key was verified by the operator and its fingerprint is:

`SHA256:/Eka/U5rO0j+4A4AZHLHbw/X8md/bh01aHpRqSIc/Ww`

SSH login as `blueaz` still fails public-key authentication. The z13 client offers ED25519 public key fingerprint:

`SHA256:uwAG7T1r2Za/1jueyz2aDBvhETsn32x7SnjEe/EqFtg`

Please confirm that this exact z13 key is authorized in the desktop account `blueaz`'s `authorized_keys`. Once authorized, the z13 session can connect and inspect the display/boot issue. The host-key verification is already updated locally; no host-key bypass is needed.
