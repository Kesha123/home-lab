#!/usr/bin/env sh
# set -euo pipefail
set -eu

if [ "$#" -gt 0 ]; then
  exec "$@"
else
  exec /bin/sh
fi
