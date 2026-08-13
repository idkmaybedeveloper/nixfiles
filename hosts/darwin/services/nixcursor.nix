{ pkgs, ... }:

let
  stalker = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/22537ab52a5d2d9c4a75067d836e5936b31b7e60d189ed78edbbd463f92151af/Stalker.cursor";
    hash = "sha256-IlN6tSpdLZxKdQZ9g25ZNrMbfmDRie147bvUY/khUa8=";
  };
in
{
  programs.nixcursor = {
    enable = true;
    theme = stalker;
  };
}
