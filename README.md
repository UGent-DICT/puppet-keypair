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
