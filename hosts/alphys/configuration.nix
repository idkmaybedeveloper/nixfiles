{
  config,
  pkgs,
  lib,
  partials,
  abs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./ssh
    ./packages
    ./critical
    ./mics
    ./security
    ./services
    ./hardware
    partials.sops-base
  ];

  sops.defaultSopsFile = abs "secrets/x230-github-token.yaml";

  sops.secrets.github-token = {
    sopsFile = abs "secrets/x230-github-token.yaml";
    key = "github-token";
  };

  sops.templates.github-token-conf = {
    content = ''
      ${config.sops.placeholder."github-token"}
    '';
    mode = "440";
    owner = "root";
    group = "nixbld";
  };

  environment.etc."somesecrets/github-tokens.conf".source =
    config.sops.templates.github-token-conf.path;

  nix.extraOptions =
    let
      githubTokenFile = config.sops.templates.github-token-conf.path;
      fileExists = builtins.pathExists githubTokenFile;
    in
    lib.optionalString (config.sops.templates ? github-token-conf && fileExists) ''
      include ${githubTokenFile}
    '';

  system.stateVersion = "25.11";
}