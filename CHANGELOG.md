# Changelog

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
