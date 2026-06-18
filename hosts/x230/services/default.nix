{ config, pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./audio.nix
	./tailscale.nix
  ];
}
