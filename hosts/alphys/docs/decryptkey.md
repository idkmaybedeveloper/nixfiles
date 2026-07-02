# decrypt github key

copy keys to target machine, then - 
```
nix-shell -p ssh-to-age
ssh-to-age -private-key -i /tmp/id_ed25519 > /tmp/keys.txt
```

then:
```
sudo mkdir -p /run/nix/nix.conf.d
SOPS_AGE_KEY_FILE="/tmp/keys.txt" sops -d secrets/github-token.yaml | grep -A 100 "^github-token:" | tail -n +2 | sed 's/^    //' > /tmp/githubtoken.conf
sudo chmod 440 /run/nix/nix.conf.d/github-token.conf
sudo chown root:nixbld /run/nix/nix.conf.d/github-token.conf
```

then build