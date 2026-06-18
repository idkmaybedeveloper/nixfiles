{ config, pkgs, ... }:

let
  motdContent = pkgs.runCommand "motd-content" {
    buildInputs = [ pkgs.cowsay ];
    nativeBuildInputs = [ pkgs.cowsay ];
  } ''
    ${pkgs.cowsay}/bin/cowsay "THIS IS DC3-FL (playground infrastructure)" > $out
  '';
in
{
  environment.etc."motd" = {
    source = motdContent;
  };

  environment.systemPackages = with pkgs; [
    cowsay
  ];
}
