# Stacks

Podman Quadlet systemd unit configurations for containers, packaged as OCI artifacts and published via oras.

## Stack Structure

Each subdirectory is a stack:

- `stack/` — quadlet files (`.container`, `.volume`) and `config/` for application configs
- `Makefile` — tars `stack/` into `target/<name>-stack-v<tag>.tar.gz` and pushes it as an OCI artifact
- `target/` — build output (gitignored)

## Commands

From `stacks/`:

- `make build` — build all stacks
- `make build-sub/<name>` — build one stack
- `make publish` — publish all stacks to the registry
- `make publish-sub/<name>` — publish one stack

From a stack subdirectory:

- `make build` — build this stack
- `make publish` — publish this stack
