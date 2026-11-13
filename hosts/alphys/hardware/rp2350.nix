{ pkgs, ... }:

{
  # ref: https://github.com/systemd/systemd/blob/main/src/login/73-seat-late.rules.in
  services.udev.packages = [
    pkgs.picotool
    (pkgs.writeTextDir "lib/udev/rules.d/70-orochimaru.rules" ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="0001", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="0001", TAG+="uaccess"
    '')
  ];
}
