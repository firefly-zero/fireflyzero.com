#!/bin/bash
# A helper script that ensures firefly_cli is installed,
# installs the given app, and launches it in emulator.

set -o errexit   # abort on nonzero exit code
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if test $1; then
  true
else
  echo "an app ID is required"
  exit 1
fi

# Install firefly_cli.
if which firefly_cli; then
  true
else
  bash -c "$(curl https://fireflyzero.com/install.sh)"
fi

firefly_cli import $1
firefly_cli emulator -- --id $1
