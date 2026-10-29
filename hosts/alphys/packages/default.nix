{ config, pkgs, ... }:

{
  imports = [
    (import ../../../lib/ida { platform = "linux"; })
    ./packages.nix
    ./rules.nix
    ./quirks.nix
  ];
}
