# ida 9.5

`lib/ida/default.nix` is shared by alphys and m68k.
edit credentials with `scripts/sops secrets/ida.yaml`:

```yaml
netrc: |
  machine ida.cuddles.rs
  login lain
  password YOUR_PASSWORD
```

nix downloads the installer automatically using the sops netrc and the hash in
`lib/ida/source.json`. on a fresh host, activate the secret before building ida.

```sh
sudo nixos-rebuild switch --flake .#alphys
```

on alphys, after rebuilding, open a new login session and create the plugin environment:

```sh
uv venv --seed --system-site-packages --python python3.13 ~/.idapro/venv
uvx ida-hcli mcp install
```