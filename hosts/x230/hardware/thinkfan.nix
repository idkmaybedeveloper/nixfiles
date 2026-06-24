{ config, pkgs, ... }:

{
  services.thinkfan = {
    enable = true;
    levels = [
      [
        0
        0
        64
      ]
      [
        1
        64
        73
      ]
      [
        2
        73
        80
      ]
      [
        3
        80
        85
      ]
      [
        6
        85
        90
      ]
      [
        7
        90
        95
      ]
      [
        "level auto"
        95
        32767
      ]
    ];
  };
}
