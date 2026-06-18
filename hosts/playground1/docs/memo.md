### how to update
Just run:
```
sudo nixos-rebuild switch --upgrade
```

### install config on new machine
`sudo nixos-rebuild switch --flake .#playground1` OR `./scripts/cpr`

(i recommend changing the hostname to something like 'playground1' (I don't think I will be using nix on any of my main servers))