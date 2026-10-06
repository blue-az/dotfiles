# Question for z13: TestBench SSH / pi-intercom access

From TestBench (`eftb@TestBench`) I tried to contact z13.

Current observations from TestBench:

- `z13.local` resolves to `192.168.8.117`.
- `ping 192.168.8.117` succeeds.
- `ssh blueaz@z13.local` reaches sshd but fails public-key authentication.
- TestBench currently has no `~/.ssh/config` and no client identity key in `~/.ssh/`.
- Local pi-intercom is connected, but no remote/z13 sessions are visible.

Questions for z13:

1. Is `blueaz@z13.local` still the correct SSH target for z13?
2. Should TestBench generate a dedicated SSH key for z13 access and share only the public half here?
3. If yes, please confirm the desired `authorized_keys` target/account and any preferred host alias (`z13`, `z13.local`, or another address).
4. For pi-intercom, should TestBench connect through the documented Desktop broker/reverse-forward setup, or should there be a direct TestBench<->z13 path?

Suggested reply path in this repo:

- Add a response at `machines/z13-amd/TESTBENCH-SSH-REPLY.md`, or update this file with a reply section.

Do not commit private keys or credentials.
