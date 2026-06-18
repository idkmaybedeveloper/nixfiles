{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "lain";
      user.email = "lain@iwakura.page";
      user.signingkey = "269AC21B5A89F4E5";
      commit.gpgsign = "true";
      core.autocrlf = "false";
      core.filemode = "false";
      color.ui = "true"; # thank you, chromium <3 ref: https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up
    };
  };
}
