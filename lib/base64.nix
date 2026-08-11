#pure-eval base64, so things like announce and profile-title can be written as
#plain text right in the config instead of being pasted in pre-encoded
{ lib }:

let
  inherit (builtins)
    concatStringsSep
    elemAt
    fromJSON
    genList
    length
    listToAttrs
    stringLength
    substring
    ;

  inherit (lib) mod;

  hexDigits = "0123456789abcdef";

  hex4 =
    cp:
    concatStringsSep "" (
      map (place: substring (mod (cp / place) 16) 1 hexDigits) [
        4096
        256
        16
        1
      ]
    );

  jsonChar = cp: fromJSON ''"\u${hex4 cp}"'';

  #codepoints past the bmp only fit in a json escape as a surrogate pair...
  jsonAstral =
    cp:
    let
      rest = cp - 65536;
    in
    fromJSON ''"\u${hex4 (55296 + rest / 1024)}\u${hex4 (56320 + mod rest 1024)}"'';

  byteChar =
    b:
    if b < 128 then
      jsonChar b
    else if b < 192 then
      substring 1 1 (jsonChar b)
    else if b < 224 then
      substring 0 1 (jsonChar ((b - 192) * 64))
    else if b < 240 then
      substring 0 1 (jsonChar (if b == 224 then 2048 else (b - 224) * 4096))
    else
      substring 0 1 (jsonAstral (if b == 240 then 65536 else (b - 240) * 262144));

  byteOf = listToAttrs (
    map (b: {
      name = byteChar b;
      value = b;
    }) (genList (i: i + 1) 191 ++ genList (i: i + 194) 51)
  );

  alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  chr = i: substring i 1 alphabet;
in
str:
let
  bytes = genList (i: byteOf.${substring i 1 str}) (stringLength str);
  total = length bytes;

  byteAt = i: if i < total then elemAt bytes i else 0;

  group =
    i:
    let
      at = i * 3;
      b0 = byteAt at;
      b1 = byteAt (at + 1);
      b2 = byteAt (at + 2);

      quad =
        chr (b0 / 4) + chr (mod b0 4 * 16 + b1 / 16) + chr (mod b1 16 * 4 + b2 / 64) + chr (mod b2 64);

      left = total - at;
    in
    if left >= 3 then quad else substring 0 (left + 1) quad + substring 0 (3 - left) "==";
in
concatStringsSep "" (genList group ((total + 2) / 3))
