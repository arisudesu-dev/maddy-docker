#!/bin/sh
set -e

case "$1" in -*)
    set -- maddy "$@"
esac

exec "$@"
