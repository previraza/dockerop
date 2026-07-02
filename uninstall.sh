#!/usr/bin/env sh
set -eu

target_dir="${DOCKEROP_INSTALL_DIR:-$HOME/.local/bin}"
target_file="$target_dir/dockerop"

if [ -e "$target_file" ] || [ -L "$target_file" ]; then
  rm -f "$target_file"
  echo "removed $target_file"
else
  echo "dockerop is not installed at $target_file"
fi
