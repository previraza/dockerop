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
version: $(cat "$script_dir/VERSION" 2>/dev/null || echo unknown)
binary:  $target_file
EOF

if [ -n "$profile_file" ]; then
  echo "path:    added $target_dir to $profile_file"
  echo "next:    restart your shell or run: . \"$profile_file\""
else
  echo "path:    already available"
fi

echo "try:     dockerop --version"
