#!/bin/bash
# A helper script that ensures firefly_cli is installed,
# installs the given app, and launches it in emulator.

set -o errexit   # abort on nonzero exit code
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if test "$1"; then
  true
else
  echo "an app ID is required"
  exit 1
fi

# Install firefly_cli.
if which firefly_cli; then
  true
else
  if which curl; then
    bash -c "$(curl https://fireflyzero.com/install.sh)"
  else
    bash -c "$(wget -O- https://fireflyzero.com/install.sh)"
  fi
fi

# We need to call firefly_cli in a subshell
# in case the install script patched $PATH through .zshrc.
bash -c "firefly_cli import $1"
bash -c "firefly_cli emulator -- --id $1"
