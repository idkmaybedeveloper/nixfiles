{ partials, ... }:

{
  # shared baseline imported by every NixOS host (wired in flake.nix via mkNixosSystem).
  # opt-in feature modules live in lib/partials and are imported per host.
  imports = [
    partials.users
    partials.networkmanager
    partials.nix-common
    partials.openssh-hardening
  ];
}
