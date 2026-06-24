{ config, pkgs, ... }:

let
  motdContent =
    pkgs.runCommand "motd-content"
      {
        nativeBuildInputs = [ pkgs.cowsay ];
      }
      ''
        ${pkgs.cowsay}/bin/cowsay "THIS IS DC2-HOME (mail? maybe something other?)" > $out
      '';
in
{
  environment.etc."motd".source = motdContent;

  environment.systemPackages = with pkgs; [
    cowsay
  ];
}
