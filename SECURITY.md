# UpperShell

This document explains the security model, risks and recommended deployment steps for UpperShell integration in DockerOP.

Design principles

- Disabled by default. No host execution is permitted from containers until an administrator explicitly enables UpperShell for a service and starts the UpperShell daemon.
- Principle of least privilege: the daemon validates every request against an explicit permissions policy. Commands are executed without a shell (execve), avoiding shell injection.
- No docker socket exposure: containers must not be given direct access to /var/run/docker.sock. To run docker commands on the host, use UpperShell policies that allow carefully scoped docker subcommands.
- Strong auditing: every request and result must be logged with metadata (container, user, command, cwd, timestamp, duration, exit code).

Daemon installation

- For production, install a single system daemon via systemd with socket activation. This avoids multiple daemons and centralizes policy.
- For development, a per‑project daemon can be started manually (NOT automatically) inside project folder. The daemon will listen on ./.dockerop/state/uppershelld.sock by default.

Systemd unit example

```ini
[Unit]
Description=UpperShell daemon for DockerOP
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/uppershelld --socket /run/uppershelld.sock --permissions /etc/uppershelld/permissions.yaml
User=uppershell
Group=uppershell
RuntimeDirectory=uppershelld
RuntimeDirectoryMode=0750

[Install]
WantedBy=multi-user.target
```

Socket unit example (optional)

```ini
[Unit]
Description=UpperShell socket

[Socket]
ListenStream=/run/uppershelld.sock
SocketMode=0660
SocketUser=uppershell
SocketGroup=uppershell

[Install]
WantedBy=sockets.target
```

Permissions & policy

- Global policy: /etc/uppershelld/permissions.yaml defines groups, allowed binaries and argument patterns.
- Project overrides: .dockerop/uppershell/permissions.yaml can add project-specific policy, but cannot broaden global policy.
- Container mapping: .dockerop/uppershell/containers.json maps container names to permission groups. The daemon verifies the client identity when possible (SO_PEERCRED and cgroup mapping) and enforces the mapping.
- Denylist: some commands are forbidden by default (rm -rf /, dd, shutdown, reboot). These are inbuilt additional checks.

Operational notes

- Socket ownership: the socket should be owned by a dedicated user/group (uppershell) with mode 0660. DockerOP will mount the socket into containers only when uppershell is enabled for that service.
- No auto-start: DockerOP will not start the daemon automatically. The admin must run the daemon (systemd or manual) before enabling uppershell for a service.
- Logging & retention: configure log rotation and retention for audit logs. Use SQLite for structured audit entries in production.

