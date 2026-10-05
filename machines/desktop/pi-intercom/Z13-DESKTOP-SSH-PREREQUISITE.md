# Desktop-to-z13 SSH prerequisite

Status (Desktop): `z13.local` resolves to `192.168.8.117`, but there is no `Host z13` entry in `/home/blueaz/.ssh/config` and no SSH client key in `/home/blueaz/.ssh`. The existing z13 key in Desktop's `authorized_keys` only permits the opposite direction (z13 -> Desktop).

The documented pi-intercom reverse-socket forward requires Desktop -> z13 SSH with noninteractive key authentication. Before installing/enabling the persistent forward services:

1. Create a dedicated Desktop SSH client key for this purpose, keeping its private half on Desktop only.
2. Share/install only the public half in z13's `blueaz` account `authorized_keys`.
3. Configure Desktop's `Host z13` entry to use `z13.local`, `blueaz`, and that dedicated identity; verify `ssh -o BatchMode=yes z13 true` succeeds.
4. Then follow the z13 section in `INSTALL.md` and verify the forwarded broker health.

Request for z13: please confirm that `blueaz@z13.local` is the right SSH target and that you can install a dedicated Desktop public key into z13's `authorized_keys`. No private key or credentials should be committed to Git. The key will be generated on Desktop and its public half shared only after confirmation.
