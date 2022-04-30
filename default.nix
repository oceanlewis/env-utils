let

  inherit (builtins)
    attrNames
    concatStringsSep
    filter
    first
    genList
    listToAttrs
    readFile
    substring
    stringLength
    ;

  ##
  ## Taken from NixOS/Nixpkgs
  ##

  # https://github.com/NixOS/nixpkgs/blob/master/lib/lists.nix
  range =
    # First integer in the range
    first:
    # Last integer in the range
    last:
    if first > last then
      [ ]
    else
      genList (n: first + n) (last - first + 1);

  # https://github.com/NixOS/nixpkgs/blob/master/lib/attrsets.nix
  mapAttrsToList = f: attrs:
    map (name: f name attrs.${name}) (attrNames attrs);
  escape = list: builtins.replaceStrings list (map (c: "\\${c}") list);

  # https://github.com/NixOS/nixpkgs/blob/master/lib/strings.nix
  addContextFrom = a: b: substring 0 0 a + b;
  escapeRegex = escape (stringToCharacters "\\[{()^$?*+|.");
  stringToCharacters = s:
    map (p: substring p 1 s) (range 0 (stringLength s - 1));
  splitString = _sep: _s:
    let
      sep = builtins.unsafeDiscardStringContext _sep;
      s = builtins.unsafeDiscardStringContext _s;
      splits = builtins.filter builtins.isString (builtins.split (escapeRegex sep) s);
    in
    map (v: addContextFrom _sep (addContextFrom _s v)) splits;

  ##
  ## End
  ##

  readFileAsLines = path:
    let
      fileContents = readFile path;
      lines = filter
        (line: line != "")
        (splitString "\n" fileContents);
    in
    lines;

  readEnvFile = path:
    let
      lines = readFileAsLines path;
      keyValuePairs = builtins.map
        (line: (
          let
            kv = splitString "=" line;
            name = builtins.elemAt kv 0;
            value = builtins.elemAt kv 1;
          in
          { inherit name value; }
        ))
        lines;
    in
    listToAttrs keyValuePairs;

  formatAttrsAsShellVars = attrs:
    let
      attrToExportStatement = name: value:
        "export ${name}=\"${toString value}\"";

      mapAttrsToExportStatements = attrs:
        concatStringsSep "\n" (
          mapAttrsToList
            (name: value: attrToExportStatement name value)
            attrs
        );
    in
    mapAttrsToExportStatements attrs;

  parseEnvFile = path:
    formatAttrsAsShellVars (readEnvFile path);

in
{
  inherit
    readEnvFile
    parseEnvFile
    formatAttrsAsShellVars
    ;
}
