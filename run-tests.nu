#!/usr/bin/env nu

nix eval -f ./test.nix
| from json
| from json
