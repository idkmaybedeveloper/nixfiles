{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
  nmap
  rustscan
  metasploit
  ];
}
