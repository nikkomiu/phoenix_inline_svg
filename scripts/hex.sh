#!/usr/bin/env bash

# Log In
mix hex.user auth <<EOF
$HEX_USERNAME
$HEX_PASSWORD
EOF

# Publish
mix hex.publish <<EOF
${HEX_PASSWORD}
y
EOF

# Publish Docs
mix hex.publish docs <<EOF
${HEX_PASSWORD}
y
EOF
