{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.tangled.knot = {
    enable = true;
    stateDir = "/home/git";
    server = {
      listenAddr = "127.0.0.1:5555";
      owner = "did:plc:bqm2qxgwpzydwl4qsqm7cjxq";
      hostname = "knot-fl1.wejust.rest";
    };
  };
}
