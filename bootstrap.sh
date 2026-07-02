#!/usr/bin/env sh
set -eu

repo_raw="${DOCKEROP_RAW_URL:-https://raw.githubusercontent.com/previraza/dockerop/main}"
target_dir="${DOCKEROP_INSTALL_DIR:-$HOME/.local/bin}"
target_file="$target_dir/dockerop"

mkdir -p "$target_dir"

tmp_file=$(mktemp)
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT INT TERM

curl -fsSL "$repo_raw/dockerop" -o "$tmp_file"
chmod 755 "$tmp_file"
mv "$tmp_file" "$target_file"
trap - EXIT INT TERM

echo "installed $target_file"
case ":$PATH:" in
  *":$target_dir:"*) ;;
  *) echo "add to PATH: export PATH=\"$target_dir:\$PATH\"" ;;
esac
