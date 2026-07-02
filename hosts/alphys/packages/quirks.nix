{
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.opengl.enable = true; # ghostty fix
  hardware.graphics.enable = true; # ghostty fix
}
