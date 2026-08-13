{ config, lib, ... }:

let
  inherit (config.lib.topology) mkInternet mkRouter mkConnection;
  home = builtins.getEnv "HOME";
  sshHosts = import ./lib/ssh-hosts.nix { inherit lib; } (
    if home == "" then "/nonexistent" else "${home}/.ssh/config"
  );
  addr = alias: lib.optional (sshHosts ? ${alias}) sshHosts.${alias};

  #every box that joined the tailnet gets the same virtual interface
  tailscaleInterface = alias: {
    tailscale0 = {
      virtual = true;
      type = "tun";
      network = "tailnet";
      addresses = addr alias;
    };
  };

  wanInterface = alias: {
    wan = {
      type = "ethernet";
      network = "internet";
      addresses = addr alias;
    };
  };
in
{
  #global topology bits that no single host owns. per-host details are picked up
  #automatically from the nixos configs (services, firewall, ...); interfaces are
  #only auto-detected on systemd-networkd/networking.interfaces hosts, and since
  #everything here runs networkmanager or plain dhcp they are spelled out below.

  nodes.internet = mkInternet {
    connections = [
      (mkConnection "puppy" "wan")
      (mkConnection "playground1" "wan")
      (mkConnection "playground2" "wan")
      (mkConnection "router" "wan")
    ];
  };

  #home and macmini are not exposed directly, they sit behind the main router
  nodes.router = mkRouter "home router" {
    interfaces.wan.addresses = addr "router.wejust.rest";
    connections.lan1 = mkConnection "home" "eth0";
    connections.lan2 = mkConnection "macmini" "enp2s0f0";
    connections.wifi = mkConnection "home" "wlan0";
    interfaceGroups = [
      [
        "lan1"
        "lan2"
        "wifi"
      ]
      [ "wan" ]
    ];
  };

  #hostkey vps boxes
  nodes.puppy.interfaces = wanInterface "puppy.cuddles.rs";
  nodes.playground1.interfaces =
    wanInterface "playground1" // tailscaleInterface "playground1=tailscale";
  nodes.playground2.interfaces =
    wanInterface "playground2" // tailscaleInterface "playground2=tailscale";

  nodes.macmini.interfaces = {
    enp2s0f0 = {
      type = "ethernet";
      network = "home-lan";
      addresses = addr "minihome";
    };
  }
  // tailscaleInterface "tailminimac";
  #both vms run on home, reachable from outside only through the router
  nodes.nixvm = {
    guestType = "vm";
    parent = "home";
    interfaces.eth0 = {
      type = "ethernet";
      network = "home-lan";
    };
  };

  #laptops roam, so no fixed uplink is drawn for them
  nodes.eva01.interfaces = {
    wlan0.type = "wifi";
  }
  // tailscaleInterface "eva01";
  nodes.alphys.interfaces = {
    wlan0.type = "wifi";
  }
  // tailscaleInterface "alphys";

  #darwin / nix-on-droid hosts live outside nixosConfigurations, so nix-topology
  #can't introspect them. keep them as plain nodes so the picture stays honest
  nodes.m68k = {
    name = "m68k";
    deviceType = "device";
    deviceIcon = "devices.laptop";
    hardware.info = "MacBook Air M3 (aarch64-darwin)";
    interfaces = {
      wifi.type = "wifi";
    }
    // tailscaleInterface "m68k";
  };

  #remote box that hosts the x86_64 vm, running plain debian for now (maybe nixOS in future?)
  nodes.home = {
    name = "home";
    deviceType = "device";
    deviceIcon = "devices.cloud-server";
    hardware.info = "debian, x86_64";
    interfaces = {
      eth0 = {
        type = "ethernet";
        network = "home-lan";
        addresses = addr "home=local";
      };
      wlan0 = {
        type = "wifi";
        network = "home-lan";
      };
    }
    // tailscaleInterface "home=tailscale";
  };

  nodes.macvm = {
    name = "macvm";
    deviceType = "device";
    deviceIcon = "devices.desktop";
    hardware.info = "x86_64-darwin VM";
    guestType = "vm";
    parent = "home";
    interfaces.eth0 = {
      type = "ethernet";
      network = "home-lan";
    };
  };

  nodes.droid = {
    name = "nix-on-droid";
    deviceType = "device";
    deviceIcon = "devices.desktop";
    hardware.info = "android, nix-on-droid";
    interfaces.wifi.type = "wifi";
  };

  networks = {
    internet.name = "internet";
    tailnet = {
      name = "tailnet";
      cidrv4 = "100.64.0.0/10";
    };
    home-lan = {
      name = "home lan";
      cidrv4 = "192.168.1.0/24";
    };
  };
}
