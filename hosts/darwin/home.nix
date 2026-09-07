{ config, pkgs, ... }:

{
  home.username = "lain";
  home.homeDirectory = "/Users/lain";
  home.stateVersion = "25.11";

  imports = [
    ./home
    ./packages
    ./editor
  ];


  #TODO: move to ./browser?
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;

      ExtensionSettings = {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };

        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };

    profiles.default = {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.urlbar.behavior" = "float";
      };

      search = {
        force = true;
        default = "kagi";
        engines = {
          kagi = {
            name = "Kagi";
            urls = [
              {
                template = "https://www.kagi.com/search?q={searchTerms}";
              }
            ];
            definedAliases = ["@k"];
          };
        };
      };

      presets.catppuccin = {
        enable = true;
        flavor = "Mocha";
        accent = "Mauve";
      };
    };
  };
}