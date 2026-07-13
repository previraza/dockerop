# Changelog

## 0.6.6

- Support splitting single command arguments containing spaces with `shlex.split`.

## 0.6.5

- Fix missing `socket` import that prevented daemon health check from working.
- Fix daemon log file always being empty (kept file handle open until daemon confirmed started).
- Handle stale socket directory artifacts with `shutil.rmtree`.

## 0.6.4

- Auto-start uppershelld daemon when -us/--uppershell flag is used.
- Fix daemon permissions: use YAML list format for allowlist groups.
- Daemon gracefully handles non-existent cwd from container.
- Fix --version flag not being consumed by subcommand arguments.
- Fix -- separator from argparse REMAINDER being passed as command arg.

## 0.6.3

- Embed uppershell client in dockerop script (no external file dependency).
- Fix compose mount paths (use relative paths for docker compose).
- Add run flags (-us, -v, --memory, --cpus, --gpu) to start and run subparsers.

## 0.6.2

- Auto-switch to install-script when uppershell is enabled with image method.
- Add uppershell method check in `dockerop doctor`.

## 0.6.1

- Version bump.

## 0.6.0

- Change default install method to `install-script` (includes python3 for uppershell support).

## 0.5.3

- Fix `run` command: parse quoted strings via `sh -c`.

## 0.5.2

- Add python3 to Dockerfile packages for uppershell support.
- Fix uppershell wrapper: use US_INIT consistently, fix quoted command parsing in run.

## 0.5.1

- Fix uppershell: create wrapper at runtime in /tmp to avoid bind mount permission issues.
- Fix bash fallback when container doesn't have bash installed.
- Fix quoted command handling in `dockerop run`.

## 0.5.0

- Add `dockerop logs` to view container logs (`-n`, `-f`).
- Add `dockerop run` to execute a command in the container without shell entrypoint.
- Add `-v`/`--volume` flag for extra bind mounts (repeatable).
- Add `--memory`, `--cpus` flags for container resource limits.
- Add `--gpu` flag for NVIDIA GPU passthrough.
- Add `dockerop completions bash|zsh|fish` for shell tab-completion.
- Remove `run` alias from `start` (now its own command).

## 0.4.3

- Fix uppershell permission denied: mount client directly as `/usr/local/bin/uppershell`.
- Add `dockerop mi` to show machine id, `dockerop mi reset` to regenerate it.

## 0.4.2

- Mount uppershell client and wrapper into container when using `-us`, so `uppershell <cmd>` works out of the box.

## 0.4.1

- Add `-us` / `--uppershell` flag to `dockerop shell`.

## 0.4.0

- Add `dockerop update` to self-update from GitHub.
- Add `dockerop reset machineId` to generate a new random machine id.
- Add `-us` / `--uppershell` flag to mount UpperShell socket into the container.

## 0.3.11

- Fix Windows startup by avoiding `os.getuid()` / `os.getgid()` when unavailable.
- Generate Docker Compose bind mounts with long syntax for Windows path compatibility.

## 0.3.10

- Add `dockerop sessions host|isolated` to share or isolate OpenCode host sessions.

## 0.3.9

- Make installers update PATH automatically when possible.
- Add branded success output to shell and PowerShell installers.
- Fix `dockerop shell` to bypass the OpenCode entrypoint and open a real container shell.

## 0.3.8

- Add timeouts to `dockerop netcheck` so blocked container egress fails quickly.
- Add `dockerop network auto` to try bridge first, then host networking on Linux.

## 0.3.7

- Add `dockerop netcheck` to test DNS and HTTPS from inside the container.
- Add `dockerop network bridge|host` to switch Docker network mode.

## 0.3.6

- Add `dockerop shell` / `dockerop sh` to open a shell in the same container workspace without launching OpenCode.

## 0.3.5

- Add `dockerop -s <session>` and `dockerop start -s <session>` to launch OpenCode with a session id.

## 0.3.4

- Regenerate Compose on every `dockerop start` so `/workspace` always points to the directory where `dockerop` is launched.
- Update stored `project_root` automatically when a project directory is moved.

## 0.3.3

- Mount the project root into `/workspace` with an absolute host path.
- Force `docker compose run` to use `/workspace` as working directory.

## 0.3.2

- Add `dockerop use <method>` to switch between `image`, `npm` and `install-script` without changing `machine_id` or deleting state.
- Document that `apt-get update` logs only happen in local build modes, not in the default image mode.
- Add `bootstrap.sh` for direct installation from `previraza/dockerop`.
- Add npm/pnpm GitHub installation metadata.
- Add Windows PowerShell installer.

## 0.3.1

- Use the official OpenCode image by default to avoid local build steps.
- Keep isolated machine identity through `.dockerop/state/machine-id:/etc/machine-id:ro`.
- Keep local build methods available through `dockerop init --method install-script` and `dockerop init --method npm`.

## 0.3.0

- Default to a dockerop-controlled image built with the official OpenCode install script.
- Keep `--method image` available, but not as the default, because dockerop prioritizes an isolated machine identity.
- Add `DOCKEROP_INSTALL_METHOD` to generated Compose environments.

## 0.2.0

- Add lifecycle commands: `build`, `stop`, `reset`, `destroy`, `doctor`, `config`, `version`.
- Add global installation through `dockerop install`.
- Add launch banner with version, project, machine id, workspace and state path.
- Remove `apt-get update` from the generated Dockerfile.
- Generate `.dockerop/.gitignore` for local runtime state.

## 0.1.0

- Add initial `init` and `start` commands.
- Generate `.dockerop/` with Docker Compose, Dockerfile and isolated state.
