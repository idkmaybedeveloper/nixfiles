# `nixfiles/playground1`

```
          _      _____ __         
   ____  (_)  __/ __(_) /__  _____
  / __ \/ / |/_/ /_/ / / _ \/ ___/
 / / / / />  </ __/ / /  __(__  ) 
/_/ /_/_/_/|_/_/ /_/_/\___/____/      
for my shitty VDS server 
```

these are the nixfiles that I use for my server, its experimental so there are quite a few services

### install

(there was a way to copy files, but i was too lazy to edit it, so i just wrote a script)

```
./scripts/cpr
```

### scripts??

`lmg` - list generations

`cpr` - copy configuration files to /etc/nixos/

`cmg` - clean generations

### flake support oh

rebuild switch (idk untested):
```
sudo nixos-rebuild switch --flake .#playground1
```

# my server's mood

![mood](pics/mood.jpg)