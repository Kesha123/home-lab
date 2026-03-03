#!/usr/bin/env sh
set -euo pipefail

if [ "$#" -gt 0 ]; then
  exec "$@"
else
  exec /bin/sh
fi
