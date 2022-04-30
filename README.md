# env-utils

A small set of Nix utility functions to allow for reading env files and interpolating them into `mkShell`'s `shellHook`.

## Usage 

### `readEnvFile :: (<path> -> <attrset>)`

Read an env file given a path and return an attrset.

```nix
env-utils.readEnvFile ./test-assets/environment.env
# { HELLO = "world"; GOODBYE = "joe"; };
```

### `formatAttrsAsShellVars :: (<attrset> -> <string>)`

Format an attribute set as a list of shell variable exports.

```nix
env-utils.formatAttrsAsShellVars {
  FOO = "bar";
  SERVER = "localhost:3000";
  PORT = 3000;
}

# export FOO="bar"
# export PORT="3000"
# export SERVER="localhost:3000"
```

### `parseEnvFile :: (<path> -> <string>)`

Read an env file contents and parse them into export statements.

```nix
env-utils.parseEnvFile ./test-assets/environment.env
# export GOODBYE="joe"
# export HELLO="world"
```

