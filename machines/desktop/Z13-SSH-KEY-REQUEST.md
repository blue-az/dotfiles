# z13 SSH key request

Desktop has SSH running at `192.168.8.171`. To authorize z13, please add z13's **public** ED25519 key (the complete single-line contents of `~/.ssh/id_ed25519.pub`) to this repository as `machines/desktop/z13_id_ed25519.pub`, commit, and push it to `main`.

Do not publish or send the private key (`~/.ssh/id_ed25519`). Desktop will fetch the public key, verify that its fingerprint is `SHA256:uwAG7T1r2Za/1jueyz2aDBvhETsn32x7SnjEe/EqFtg`, and only then install it in `blueaz`'s `authorized_keys`.
