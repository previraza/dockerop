#!/usr/bin/env sh
set -eu

target_dir="${DOCKEROP_INSTALL_DIR:-$HOME/.local/bin}"
force="${DOCKEROP_FORCE_INSTALL:-0}"
mode="${DOCKEROP_INSTALL_MODE:-symlink}"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_file="$script_dir/dockerop"
target_file="$target_dir/dockerop"

if [ ! -f "$source_file" ]; then
  echo "dockerop installer: missing $source_file" >&2
  exit 1
fi

mkdir -p "$target_dir"

if [ -e "$target_file" ] || [ -L "$target_file" ]; then
  if [ "$force" != "1" ]; then
    echo "dockerop installer: $target_file already exists" >&2
    echo "set DOCKEROP_FORCE_INSTALL=1 to replace it" >&2
    exit 1
  fi
  rm -f "$target_file"
fi

if [ "$mode" = "copy" ]; then
  cp "$source_file" "$target_file"
  chmod 755 "$target_file"
else
  ln -s "$source_file" "$target_file"
fi

echo "installed $target_file"
case ":$PATH:" in
  *":$target_dir:"*) ;;
  *) echo "add to PATH: export PATH=\"$target_dir:\$PATH\"" ;;
esac
