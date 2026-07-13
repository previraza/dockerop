# UpperShell systemd installation and configuration

This document describes how to install and run the UpperShell daemon in production using systemd/socket activation, and how to configure safe permissions for its socket and optional sudoers entries.

WARNING: These steps are performed manually by the system administrator. DockerOP will not start daemons automatically.

1) Create a dedicated user and group

Choose a system user to run the daemon (recommended: `uppershell`). Run as root:

```sh
# create group and user (system accounts)
sudo groupadd --system uppershell || true
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --gid uppershell --comment "UpperShell daemon" uppershell || true
```

2) Install the daemon binary

Place the production daemon binary at `/usr/local/bin/uppershelld` (or use the path you prefer). Ensure it is owned by root and executable:

```sh
sudo install -m 0755 ./uppershelld /usr/local/bin/uppershelld
```

The daemon will be configured with a permissions file such as `/etc/uppershelld/permissions.yaml`.

3) Create runtime directory

Create a runtime directory for the socket and set ownership:

```sh
sudo mkdir -p /run/uppershelld
sudo chown root:uppershell /run/uppershelld
sudo chmod 0750 /run/uppershelld
```

4) Systemd unit and socket (examples)

Copy the following into `/etc/systemd/system/uppershelld.socket`:

```ini
[Unit]
Description=UpperShell socket

[Socket]
ListenStream=/run/uppershelld.sock
SocketMode=0660
SocketUser=root
SocketGroup=uppershell

[Install]
WantedBy=sockets.target
```

And this into `/etc/systemd/system/uppershelld.service`:

```ini
[Unit]
Description=UpperShell daemon for DockerOP
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/uppershelld --socket /run/uppershelld.sock --permissions /etc/uppershelld/permissions.yaml
User=root
Group=uppershell
RuntimeDirectory=uppershelld
RuntimeDirectoryMode=0750

[Install]
WantedBy=multi-user.target
```

Notes:
- We run the service as root (User=root) only in this example because some allowed commands may require root privileges (e.g. systemctl, docker). If you want least privilege, run as a non‑root user and configure sudoers for specific commands.
- The socket file `/run/uppershelld.sock` will be owned by root:uppershell with mode 0660 so only the uppershell group and root can access it.

5) Optional sudoers example (COMMENTED)

If you choose to run the daemon as a non‑root user and allow specific privileged commands, configure `/etc/sudoers.d/uppershelld` (edit with `visudo -f /etc/sudoers.d/uppershelld`) and add carefully the allowed commands. Example (commented — DO NOT ENABLE WIDELY):

```text
# Allow the uppershell user to restart nginx and run docker compose without password
# NOTE: replace paths with exact binaries on your system and restrict to specific subcommands
# uppershell ALL=(root) NOPASSWD: /bin/systemctl restart nginx, /usr/bin/docker compose
```

6) Enable and start

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now uppershelld.socket
sudo systemctl start uppershelld.service
sudo systemctl status uppershelld.service
```

7) Permissions file

Create `/etc/uppershelld/permissions.yaml` with groups mapping and container permissions. Example:

```yaml
groups:
  deploy:
    - pnpm
    - npm
    - bun
  infrastructure:
    - docker
    - systemctl
containers: {}
```

8) DockerOP integration

Once the system socket `/run/uppershelld.sock` exists and is reachable, DockerOP can mount it into containers for services that have `uppershell.enabled: true` in the project config. DockerOP will not enable or start daemons automatically.

9) Security reminders

- Keep `/etc/uppershelld/permissions.yaml` as the source of truth and avoid using overly broad allowlists.
- Prefer giving very narrow sudoers entries (exact path and subcommand patterns) if you must allow privileged commands.
- Audit logs should be enabled and rotated; do not keep unbounded logs.

