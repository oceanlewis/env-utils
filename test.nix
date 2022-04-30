let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;

  env-utils = import ./default.nix;

  inherit (lib)
    assertMsg
    concatStringsSep
    mapAttrsToList;

  inherit (builtins)
    isAttrs
    isInt
    isFloat
    isString
    replaceStrings
    toJSON
    trace;

  attrToString = attrs:
    let
      entries = mapAttrsToList
        (name: value: "  ${name} = ${format value};")
        attrs;
    in
    ''
      {
      ${concatStringsSep "\n" entries}
      }
    '';

  format = data:
    if isAttrs data then attrToString data
    else if isNull data then "null"
    else if isInt data then (toString data)
    else if isFloat data then (toString data)
    else if isString data
    then ''"${replaceStrings ["\"" "\n"] ["\\\"" "\\n"] data}"''
    else toString data;

  equalityTest = { description, expected, actual, ... }:
    let
      passed =
        if expected != actual
        then
          trace ''

          ------------
          Test failed: ${description}

          Expected:
          ${format expected}

          Got:
          ${format actual}
          ''
            false
        else true;
    in
    { inherit description passed; };

  runTests = tests:
    map
      (t:
        if t.type == "equality"
        then equalityTest t
        else throw "Unsupported test type: ${t.type}"
      )
      tests;

  testResults = runTests [
    {
      type = "equality";
      description = "Can read sample environment.env file";
      expected = { HELLO = "world"; GOODBYE = "joe"; };
      actual = env-utils.readEnvFile ./test-assets/environment.env;
    }
    {
      type = "equality";
      description = "Can format an attribute set as a list of shell variable exports";
      expected = ''
        export FOO="bar"
        export PORT="3000"
        export SERVER="localhost:3000"'';
      actual = env-utils.formatAttrsAsShellVars {
        FOO = "bar";
        SERVER = "localhost:3000";
        PORT = 3000;
      };
    }
    {
      type = "equality";
      description = ''
        Can format sample environment.env file contents as export statements
      '';
      expected = ''
        export GOODBYE="joe"
        export HELLO="world"'';
      actual = env-utils.parseEnvFile ./test-assets/environment.env;
    }
    {
      type = "equality";
      description = ''
        Consecutive env file reads can be safely iterpolated together
      '';
      expected = ''
        export FOO="bar"
        export GOODBYE="joe"
        export HELLO="world"'';
      actual = ''
        ${env-utils.parseEnvFile ./test-assets/single-entry.env}
        ${env-utils.parseEnvFile ./test-assets/environment.env}'';
    }
  ];
in
toJSON testResults
