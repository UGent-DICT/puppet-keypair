# gpg_key

## Overview

A module to generate OpenPGP key pairs for use with GnuPG.

The default manifest will make sure that at least one key pair (i.e. a public
and private key) exist in `/etc/gpg_keys/`.

## Description

A custom fact gathers the available keys (files, actually, it doesn't check
them to be actual keys). During catalog compilation, the master will either
generate a new key pair, or return an existing key pair, which can be used
elsewhere.
