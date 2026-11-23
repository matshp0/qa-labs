#!/bin/bash
# Usage: ./run.sh lab2|lab3|lab4  -- runs in an unprivileged user+net+mount namespace (no sudo, real network untouched)
cd "$(dirname "$0")"
exec unshare -Urmn bash -c 'mount -t tmpfs tmpfs /var/run && ./setup.sh >/dev/null && ./'"$1"'.sh'
