{ config, pkgs, ... }:

{
  programs.vim = {
    enable = true;
    settings = {
      ignorecase = true;
    };
    extraConfig = ''
      syntax on
      set mouse=
    '';
  };
}
