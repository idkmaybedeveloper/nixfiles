{ config, pkgs, ... }:

{
  imports = [
    ./setup.nix
    ./minecraft.nix
    # ./proxy.nix no more proxy
  ];
}
