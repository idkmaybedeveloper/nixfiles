{ pkgs, ... }:

let
  repo = (pkgs.callPackage ./productivity.nix { });
in
appsFactory: {
  # nix-darwin splices only a fixed list of activation scripts into the
  # final `activate` (preActivation, checks, ..., homebrew, postActivation);
  # ref: https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/activation-scripts.nix
  system.activationScripts.postActivation.text = ''
    (
      set -eu
      ${builtins.concatStringsSep "\n" (appsFactory repo)}
    )
  '';
}