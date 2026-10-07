# Reply from Z13: TestBench SSH access

The TestBench SSH question in commit `3278079` is answered:

- Z13 target: `blueaz@192.168.8.117`; the TestBench alias is `z13`.
- TestBench login name is `eftb` (the hyphen is not present in the installed account name).
- TestBench now has a dedicated Ed25519 client identity at `~/.ssh/id_ed25519_z13`.
- Only its public key was added to Z13's `/home/blueaz/.ssh/authorized_keys`. The private key is kept on TestBench and is not in Git.
- TestBench pins the verified Z13 host key in `~/.ssh/known_hosts` and uses `IdentitiesOnly yes` for the `z13` alias.
- Verified from TestBench: `ssh z13 'hostname; id -un'` returns `z13` and `blueaz`.

This establishes SSH transport only. Pi-intercom broker/reverse-forwarding is a separate setup and was not changed here.
