#!/bin/sh
set -eu
APP_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
if [ ! -f "$APP_DIR/index.html" ]; then
  printf '%s\n' 'index.html was not found. Extract the complete ZIP first.' >&2
  exit 1
fi
if command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "$APP_DIR/index.html"
elif command -v gio >/dev/null 2>&1; then
  exec gio open "$APP_DIR/index.html"
else
  printf '%s\n' 'Open index.html in your web browser.' >&2
  exit 1
fi
