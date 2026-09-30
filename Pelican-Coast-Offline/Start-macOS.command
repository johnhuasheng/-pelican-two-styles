#!/bin/sh
set -eu
APP_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
if [ ! -f "$APP_DIR/index.html" ]; then
  printf '%s\n' 'index.html was not found. Extract the complete ZIP first.' >&2
  exit 1
fi
exec open "$APP_DIR/index.html"
