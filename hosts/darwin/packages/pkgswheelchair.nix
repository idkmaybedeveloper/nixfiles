{ config, pkgs, ... }:

{
  #imports = [
  #  ./theos/theos.nix # по мотивам https://gist.githubusercontent.com/enricozb/9dbe928e0d02e45c3aed45bbe98a3eb7/raw/b7471d371dbc1f6b70b73870063f6b90a20a0468/theos.nix
  #];

  nixpkgs.config = {
    allowUnfree = true; # :(
    allowBroken = true; # lol
    android_sdk.accept_license = true;
    permittedInsecurePackages = [
      # "dotnet-sdk-7.0.410"
      "python3.13-ecdsa-0.19.1"
      "quickjs-2025-09-13-2"
      "lima-full-1.2.2" # colima REF: "Lima version 1.2.2 is EOL. See https://lima-vm.io/docs/releases/."
      "lima-additional-guestagents-1.2.2" # colima REF: "Lima version 1.2.2 is EOL. See https://lima-vm.io/docs/releases/."
      "angie-1.12.1" # not a CVE, just "insufficiently maintained in nixpkgs"
    ];
  };

  #nixpkgs.overlays = [
  #  (final: prev: {
  #    mcfgthreads-static = prev.pkgsCross.mingwW64.windows.mcfgthreads.overrideAttrs (_: {
  #      dontDisableStatic = true;
  #    });
  #  })
  #];
}
