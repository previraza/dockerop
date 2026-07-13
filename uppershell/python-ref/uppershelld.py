#!/usr/bin/env python3
"""Reference prototype uppershelld (daemon) for development/testing.

Behavior (prototype):
- Listens on a Unix domain socket (path passed as first arg or env UPPERSHELL_SOCKET)
- Receives a single JSON request per connection:
  {"cwd": "/path", "command": ["pnpm","install"], "environment": {}, "meta": {"container": "name"}}
- Validates the requested binary against a simple allowlist (permissions file path provided via env or default .dockerop/state/uppershell/permissions.yaml)
- Executes the command using subprocess (no shell), captures stdout/stderr and exit code
- Sends back a JSON response with exitCode, stdout, stderr

This is a minimal reference implementation for testing integration with dockerop. It is NOT production hardened.
"""

import json
import os
import socket
import sys
import traceback
from pathlib import Path
from subprocess import Popen, PIPE, CalledProcessError

DEFAULT_SOCKET_PER_PROJECT = "./.dockerop/state/uppershelld.sock"
DEFAULT_PERMISSIONS = "./.dockerop/state/uppershell/permissions.yaml"


def load_permissions(path: Path):
    # Minimal parser for YAML-like allowlist (very small subset). If file missing, use builtin defaults.
    if not path.exists():
        return {
            "groups": {
                "deploy": ["pnpm", "npm", "bun"],
                "infrastructure": ["docker", "systemctl"],
            },
            "containers": {},
        }
    try:
        import yaml
    except Exception:
        # fallback simple parser for lines like "group: pnpm,npm"
        content = path.read_text(encoding="utf-8")
        groups = {}
        containers = {}
        for line in content.splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if ":" in line:
                k, v = line.split(":", 1)
                k = k.strip()
                v = v.strip()
                if k.startswith("containers"):
                    # ignore
                    continue
                groups[k] = [p.strip() for p in v.split(",") if p.strip()]
        return {"groups": groups, "containers": containers}
    else:
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        return data


def send_json(conn: socket.socket, obj):
    b = json.dumps(obj).encode("utf-8")
    # prefix length
    conn.sendall(len(b).to_bytes(8, "big") + b)


def recv_json(conn: socket.socket):
    # read 8-byte length prefix
    header = conn.recv(8)
    if len(header) < 8:
        raise ConnectionError("incomplete header")
    size = int.from_bytes(header, "big")
    data = b""
    while len(data) < size:
        chunk = conn.recv(min(4096, size - len(data)))
        if not chunk:
            raise ConnectionError("connection closed")
        data += chunk
    return json.loads(data.decode("utf-8"))


def validate_command(cmd, permissions, container_name=None):
    # cmd is list, first element binary
    if not cmd:
        return False, "empty command"
    binary = cmd[0]
    # check containers mapping -> groups
    allowed = set()
    containers = permissions.get("containers", {}) or {}
    groups = permissions.get("groups", {}) or {}
    if container_name and container_name in containers:
        for g in containers[container_name].get("permissions", []):
            for b in groups.get(g, []):
                allowed.add(b)
    else:
        # if no mapping, allow any in groups by default? For prototype, allow deploy and infra
        for g in ["deploy", "infrastructure"]:
            for b in groups.get(g, []):
                allowed.add(b)
    if binary in allowed:
        return True, "ok"
    return False, f"binary '{binary}' not in allowed list ({', '.join(sorted(allowed))})"


def handle_request(req, permissions):
    cwd = req.get("cwd") or os.getcwd()
    cmd = req.get("command")
    env = req.get("environment") or {}
    meta = req.get("meta") or {}
    container = meta.get("container")
    ok, reason = validate_command(cmd, permissions, container)
    if not ok:
        return {"exitCode": 126, "stdout": "", "stderr": "Command not permitted: %s" % reason}
    try:
        p = Popen(cmd, cwd=cwd, env={**os.environ, **env}, stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        return {"exitCode": p.returncode, "stdout": out.decode("utf-8", errors="replace"), "stderr": err.decode("utf-8", errors="replace")}
    except FileNotFoundError as e:
        return {"exitCode": 127, "stdout": "", "stderr": str(e)}
    except Exception as e:
        tb = traceback.format_exc()
        return {"exitCode": 1, "stdout": "", "stderr": tb}


def serve(socket_path: str, permissions_path: str):
    sock_path = Path(socket_path)
    if sock_path.exists():
        try:
            sock_path.unlink()
        except Exception:
            pass
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(str(sock_path))
    server.listen(5)
    print(f"uppershelld listening on {sock_path}")
    permissions = load_permissions(Path(permissions_path))
    try:
        while True:
            conn, _ = server.accept()
            try:
                req = recv_json(conn)
                resp = handle_request(req, permissions)
                send_json(conn, resp)
            except Exception as e:
                try:
                    send_json(conn, {"exitCode": 1, "stdout": "", "stderr": str(e)})
                except Exception:
                    pass
            finally:
                conn.close()
    finally:
        try:
            server.close()
        except Exception:
            pass
        try:
            if sock_path.exists():
                sock_path.unlink()
        except Exception:
            pass


def main():
    socket_path = os.environ.get("UPPERSHELL_SOCKET") or DEFAULT_SOCKET_PER_PROJECT
    permissions_path = os.environ.get("UPPERSHELL_PERMISSIONS") or DEFAULT_PERMISSIONS
    serve(socket_path, permissions_path)


if __name__ == "__main__":
    main()
