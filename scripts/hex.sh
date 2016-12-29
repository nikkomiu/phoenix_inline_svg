#!/usr/bin/env bash

## Setup user
mkdir -p ~/.hex
echo '{username,<<"'${HEX_USERNAME}'">>}.' > ~/.hex/hex.config
echo '{encrypted_key,<<"'${HEX_KEY}'">>}.' >> ~/.hex/hex.config

mix hex.publish <<EOF
y
EOF

mix hex.publish docs <<EOF
y
EOF
