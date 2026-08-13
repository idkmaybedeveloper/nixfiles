{ lib }:

path:
if !builtins.pathExists path then
  { }
else
  let
    lines = lib.splitString "\n" (builtins.readFile path);

    step =
      state: line:
      let
        words = builtins.filter (w: w != "") (
          lib.splitString " " (lib.replaceStrings [ "\t" ] [ " " ] line)
        );
        key = lib.toLower (builtins.head words);
        rest = builtins.tail words;
      in
      if words == [ ] then
        state
      else if key == "host" then
        state // { aliases = rest; }
      else if key == "hostname" && rest != [ ] then
        state // { out = state.out // lib.genAttrs state.aliases (_: builtins.head rest); }
      else
        state;
  in
  (builtins.foldl' step {
    aliases = [ ];
    out = { };
  } lines).out