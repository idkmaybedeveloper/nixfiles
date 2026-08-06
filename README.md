# ![](logo.png) nixfiles :3

ok hi this is my one big flake for every machine i own. used to be eight separate
per-host repos, now it's a monorepo. the code is a bit of a zoo (every host pins
its own nixpkgs) but welp, it works :3

## the machines

| attr | what | nixpkgs |
|------|------|---------|
| `m68k` (darwin) | macbook air m3, my main laptop | 26.05 |
| `macvm` (darwin) | x86 macos vm, also hydra runner | 25.11 |
| `macmini` | mac mini server | unstable |
| `nixvm` | linux vm | 25.11 |
| `playground1` | hostkey vds, runs a pile of services | 25.11 |
| `playground2` | hostkey vds, minecraft mostly | 25.11 |
| `puppy` | vds, runs some proxys yk | 25.11 |
| `eva01` | thinkpad x230, secondary laptop | unstable |
| `alphys` | surface laptop 3 (linux-surface kernel, disko) | unstable |
| `default` (nix-on-droid) | phone (pixel 3a) | 24.05 |

## how its wired

- `hosts/<name>/` - per-host config
- `hosts/nixos-common.nix` - baseline auto-imported into every nixos host
- `lib/partials/` - opt-in feature modules. every config gets a `partials`
  attrset so you just write `imports = [ partials.boot-efi partials.chrony ];`
- `services/` - reusable service modules, pulled in with `abs`
  (e.g. `(abs "services/tailscale-exit-node.nix")`)
- `secrets/` - sops secrets, one `.sops.yaml` at the root
- `scripts/` - little helpers (`cpr`, `lmg`, `cmg`, `sops`)

other goodies handed to each module via specialArgs: `inputs`, `outputs` (= self),
and `abs "path"` (absolute path from the repo root).

## impure dependencies

note to self on what has to exist on the host manually:

- `/home/lain/.ssh/agenix_key` - private age key for sops decryption
  (needed on `playground2`, `eva01` and `alphys`)
- `~/.ssh/puppy_host_ed25519_key` (on m68k) - `puppy`s ssh host key, generated
  here and pushed to the box at install time. its what decrypts
  `secrets/puppy.yaml`, so losing it means reinstalling puppy

## setting up

```bash
# nixos
sudo nixos-rebuild switch --flake .#playground1

# darwin
darwin-rebuild switch --flake .#m68k

# phone
nix-on-droid switch --flake .#default

# just check everything evaluates
nix flake check --all-systems
```

for puppy pls see its [readme](hosts/puppy/README.md):

```bash
nix run .#nixos-anywhere -- --flake .#puppy --build-on remote root@<ip>
```

## cat in a readme :cat:

![cat](https://cats.cuddles.rs/meow)