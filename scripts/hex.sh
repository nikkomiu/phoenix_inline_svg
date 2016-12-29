#!/usr/bin/env bash

## Setup user
mkdir -p ~/.hex
echo '{username,<<"'${HEX_USERNAME}'">>}' > ~/.hex/hex.config
echo '{encrypted_key,<<"'${HEX_KEY}'">>}' > ~/.hex/hex.config

## Add rebar3 to global
mkdir -p ~/.config/rebar3
echo '{plugins, [rebar3_hex]}.' > ~/.config/rebar3/rebar.config

mix hex publish <<EOF
y
EOF

mix hex publish.docs <<EOF
y
EOF
