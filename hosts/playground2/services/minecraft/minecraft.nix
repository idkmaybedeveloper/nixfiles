{ config, pkgs, ... }:

{
  services.minecraft-servers.servers.paper = {
    enable = true;
    autoStart = true;
    package = pkgs.paperServers."paper-1_21_1";
    jvmOpts = "-Xmx4G -Xms2G";
    extraStartPre = ''
      rm -f /run/minecraft/paper.sock
    '';
    serverProperties = {
      server-ip = "0.0.0.0";
      server-port = 25565;
      difficulty = "normal";
      gamemode = "survival";
      max-players = 50;
      motd = "lain's server :3";
      online-mode = false;
    };
    files = {
      "plugins/ViaVersion-5.9.1.jar" = pkgs.fetchurl {
        url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.9.1/PAPER/ViaVersion-5.9.1.jar";
        sha256 = "00gbdwwbqf56s58p1n4ivcfxgi878gsiv79ihlf8xi9qc5ysjfis";
      };
      "plugins/BetterWhitelist-1.0.1.jar" = pkgs.fetchurl {
        url = "https://github.com/Polda18/BetterWhitelist/releases/download/v1.0.1/BetterWhitelist-1.0.1.jar";
        sha256 = "0fdak481svrgx4s5z18siqxzd8sbcajnxrmqzssiia4xr62qmik0";
      };
      "plugins/AuthMe-5.6.0.jar" = pkgs.fetchurl {
        url = "https://github.com/AuthMe/AuthMeReloaded/releases/download/5.6.0/AuthMe-5.6.0.jar";
        sha256 = "1lb4cz9b0frx0l67cs5rnhyr8xvnxa0wa26rz94lxhc702l1ndw0";
      };
      "plugins/PurpurBars-3.0-SNAPSHOT.jar" = pkgs.fetchurl {
        url = "https://github.com/SerlithNetwork/PurpurBars/releases/download/ver-3.0/PurpurBars-3.0-SNAPSHOT.jar";
        sha256 = "11xj4carlipahl7fz253i3ymk2p1hcrkwa71gmhf313x5h0sjksj";
      };
      "plugins/SkinRestorer.jar" = pkgs.fetchurl { 
        url = "https://github.com/SkinsRestorer/SkinsRestorer/releases/download/15.9.0/SkinsRestorer.jar";
        sha256 = "1bfjk94dpmr7q4awaq4nzzyg4hv68pqhx2v32a11z6gqmfamj3ab";
      };
      "plugins/ProtocolLib-5.4.0.jar" = pkgs.fetchurl {
        url = "https://github.com/dmulloy2/ProtocolLib/releases/download/5.4.0/ProtocolLib.jar";
        sha256 = "1kxcbhgzn294dqyvb4m65kgka40vwq4d3i416082svrqnnwplbpf";
      };
      "plugins/ViaBackwards-5.9.1.jar" = pkgs.fetchurl {
        url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/5.9.1/PAPER/ViaBackwards-5.9.1.jar";
        sha256 = "06fpfcjida94g8mg9w2lxwd2gfp42dvfflafli6vi2zsraxiirid";
      };
    };
  };
}