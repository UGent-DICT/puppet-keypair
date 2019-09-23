# keypair

## Overview

A module to generate key pairs (OpenPGP or X.509).

This module differs from most other similar modules in that the key is generated
on the *server* during catalogue compilation. Therefore, the generated key can
immediately be exported to puppetdb, without requiring a second puppet run.

## Description

A custom fact gathers the available keys (files, actually, it doesn't check
them to be actual keys). During catalog compilation, the master will either
generate a new key pair, or return an existing key pair, which can be used
elsewhere.

## Development

**Note on running tests:** Since we are preforming some gpg operations during
the tests, your machine might run out of randomness. You can use the following 
tool(s) to generate more entropy:

* [rngd](https://github.com/nhorman/rng-tools): rng-tools contains a deamon to
  help with supplying additional entropy to /dev/random using hardware devices.
* [haveged](http://www.issihosts.com/haveged/): A simple entropy daemon using
  the HAVEGE algorithm

