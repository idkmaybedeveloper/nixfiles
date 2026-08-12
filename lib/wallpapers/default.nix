{ pkgs }:

# shared wallpapers, so the compositor and the bootloader can point at the very
# same store path instead of fetching it twice with two copies of the hash.
{
  meowmeow = pkgs.fetchurl {
    url = "https://cloud.wejust.rest/f90b50d267a041ad8ff286c9d7bcdefc81644e38193deb8ce357d860a0f3902d/meowmeow.jpg";
    hash = "sha256-+QtQ0megQa2P8obJ17ze/IFkTjgZPeuM41fYYKDzkC0=";
  };
}
