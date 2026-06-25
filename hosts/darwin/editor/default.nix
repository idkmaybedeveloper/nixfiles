{ ... }:

{
  imports = [
    ./nvim.nix
    ./codeum.nix
    #./zed.nix NOTE: https://hydra.nixos.org/build/332364264 KILL YOURSELF
    ./helix.nix
  ];
}
