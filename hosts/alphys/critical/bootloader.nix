{ pkgs, ... }:

let
  wallpapers = import ../../../lib/wallpapers { inherit pkgs; };
in
{
  # limine/efi from lib/partials/boot-limine.nix
  # kernel comes from nixos-hardware microsoft-surface-common, so its not pinned.
  boot.loader.limine = {
    maxGenerations = 10;
    # efiInstallAsRemovable = true;

    style = {
      wallpapers = [ wallpapers.meowmeow ];
      wallpaperStyle = "stretched";

      interface = {
        branding = "alphys :3";
        brandingColor = "89B4FA";
        helpColor = "6C7086";
        helpColorBright = "89B4FA";
      };

      graphicalTerminal = {
        foreground = "CDD6F4";
        #TTRRGGBB, so 60 is a mostly-transparent panel over the wallpaper
        background = "601E1E2E";
        brightForeground = "FFFFFF";
        margin = 32;
        marginGradient = 8;
      };
    };
  };
}
