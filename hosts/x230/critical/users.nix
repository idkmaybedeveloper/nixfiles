{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with 'passwd'.
  # NOTE: base account (isNormalUser/shell/wheel) comes from lib/partials/users.nix
  users.users.lain = {
    description = "lain";
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [
      gedit
    #  thunderbird
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAI/yVGFP4ga7N6ULO3S63HexjcNIxTdI1y1bvpivhZI platon@Moofbook.local"
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };
}
