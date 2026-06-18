{ ... }:

{
  imports = [
    ./nix.nix
    ./ssh.nix
    ./tools.nix
    ./workarounds.nix
  ];

  system.checks.verifyMacOSVersion = false;
}
