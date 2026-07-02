#!/usr/bin/env sh
set -eu

repo_raw="${DOCKEROP_RAW_URL:-https://raw.githubusercontent.com/previraza/dockerop/main}"
target_dir="${DOCKEROP_INSTALL_DIR:-$HOME/.local/bin}"
target_file="$target_dir/dockerop"
version_url="$repo_raw/VERSION"

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

profile_file=""
if [ "${DOCKEROP_UPDATE_PATH:-1}" = "1" ]; then
  case ":$PATH:" in
    *":$target_dir:"*) ;;
    *)
      for candidate in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$candidate" ]; then
          profile_file="$candidate"
          break
        fi
      done
      if [ -z "$profile_file" ]; then
        profile_file="$HOME/.profile"
        mkdir -p "$(dirname "$profile_file")"
        touch "$profile_file"
      fi
      if ! grep -F "$target_dir" "$profile_file" >/dev/null 2>&1; then
        {
          echo ""
          echo "# dockerop"
          echo "export PATH=\"$target_dir:\$PATH\""
        } >> "$profile_file"
      fi
      ;;
  esac
fi

version=$(curl -fsSL "$version_url" 2>/dev/null || echo unknown)
cat <<EOF

  _            _
 | |          | |
 __| | ___   ___| | _____ _ __ ___  _ __
 / _\` |/ _ \\ / __| |/ / _ \\ '__/ _ \\| '_ \\
| (_| | (_) | (__|   <  __/ | | (_) | |_) |
 \\__,_|\\___/ \\___|_|\\_\\___|_|  \\___/| .__/
                                     | |
                                     |_|

dockerop installed
version: $version
binary:  $target_file
EOF

if [ -n "$profile_file" ]; then
  echo "path:    added $target_dir to $profile_file"
  echo "next:    restart your shell or run: . \"$profile_file\""
else
  echo "path:    already available"
fi

echo "try:     dockerop --version"
