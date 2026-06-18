{ config, lib, pkgs, ... }:

{
  services.tangled.knot = {
    enable = true;
    motd = "haii!!\n this knot is being hosted by iwakura.page\n";
    stateDir = "/home/git";
    server = {
      listenAddr = "127.0.0.1:5555";
      owner = "did:plc:bqm2qxgwpzydwl4qsqm7cjxq";
      hostname = "knot-fl2.wejust.rest";
    };
  };
}
