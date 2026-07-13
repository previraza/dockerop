#!/usr/bin/env python3
"""uppershell-client.py

Prototype client for UpperShell prototype daemon.

Usage (inside container after mounting the socket to /run/uppershelld.sock):

  ./uppershell-client.py pnpm install
  ./uppershell-client.py --cwd /workspace --env NODE_ENV=production pnpm build

Notes:
- Connects to UDS socket (env UPPERSHELL_SOCKET or /run/uppershelld.sock or ./.dockerop/state/uppershelld.sock)
- Sends a length-prefixed JSON request and waits for a length-prefixed JSON response.
- This is a development prototype; streaming is not implemented in this reference client.
"""

import argparse
import json
import os
import socket
import sys
from pathlib import Path

DEFAULT_SYSTEM_SOCKET = "/run/uppershelld.sock"
DEFAULT_PROJECT_SOCKET = "./.dockerop/state/uppershelld.sock"


def find_socket():
    # Env override
    env = os.environ.get("UPPERSHELL_SOCKET")
    if env:
        return env
    # Prefer system socket if exists
    if Path(DEFAULT_SYSTEM_SOCKET).exists():
        return DEFAULT_SYSTEM_SOCKET
    if Path(DEFAULT_PROJECT_SOCKET).exists():
        return DEFAULT_PROJECT_SOCKET
    # Default to system socket path (may not exist)
    return DEFAULT_SYSTEM_SOCKET


def send_request(sock_path: str, payload: dict) -> dict:
    b = json.dumps(payload).encode("utf-8")
    length = len(b).to_bytes(8, "big")
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(sock_path)
        s.sendall(length + b)
        # receive length-prefixed response
        header = s.recv(8)
        if len(header) < 8:
            raise ConnectionError("incomplete header from daemon")
        size = int.from_bytes(header, "big")
        data = b""
        while len(data) < size:
            chunk = s.recv(min(4096, size - len(data)))
            if not chunk:
                raise ConnectionError("connection closed")
            data += chunk
        return json.loads(data.decode("utf-8"))


def build_payload(args):
    env = {}
    if args.env:
        for item in args.env:
            if "=" in item:
                k, v = item.split("=", 1)
                env[k] = v
    return {
        "cwd": args.cwd or os.getcwd(),
        "command": args.command,
        "environment": env,
        "meta": {"container": os.environ.get("HOSTNAME")},
    }


def main():
    parser = argparse.ArgumentParser(prog="uppershell", description="UpperShell prototype client")
    parser.add_argument("command", nargs=argparse.REMAINDER, help="command to run on host (as argv list)")
    parser.add_argument("--cwd", help="working directory on host")
    parser.add_argument("--env", action="append", help="environment variable KEY=VALUE (can be repeated)")
    parser.add_argument("--socket", help="path to uppershelld socket (overrides default)")
    args = parser.parse_args()

    if not args.command:
        parser.error("no command provided")

    cmd = args.command
    if cmd[0] == "--":
        cmd = cmd[1:]

    payload = build_payload(argparse.Namespace(command=cmd, cwd=args.cwd, env=args.env))
    sock = args.socket or find_socket()

    try:
        resp = send_request(sock, payload)
    except Exception as e:
        print(f"Error communicating with uppershelld at {sock}: {e}", file=sys.stderr)
        sys.exit(2)

    # Print outputs
    out = resp.get("stdout") or ""
    err = resp.get("stderr") or ""
    exit_code = resp.get("exitCode")
    if out:
        sys.stdout.write(out)
    if err:
        sys.stderr.write(err)
    if exit_code is None:
        print("No exitCode returned", file=sys.stderr)
        sys.exit(1)
    sys.exit(int(exit_code))


if __name__ == "__main__":
    main()
