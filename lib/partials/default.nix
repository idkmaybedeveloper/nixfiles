# Attrset of opt-in feature modules: `name -> path`, auto-discovered from this dir.
# Passed to every config as the `partials` specialArg, so hosts just write
#   imports = [ partials.boot-efi partials.chrony ];
let
  entries = builtins.readDir ./.;
  isPartial = name: builtins.match ".*\\.nix" name != null && name != "default.nix";
  nixFiles = builtins.filter isPartial (builtins.attrNames entries);
  stripExt = name: builtins.substring 0 (builtins.stringLength name - 4) name;
in
builtins.listToAttrs (
  map (name: {
    name = stripExt name;
    value = ./. + "/${name}";
  }) nixFiles
)
