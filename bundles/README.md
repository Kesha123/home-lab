# Bundles

Application config and Podman Quadlet systemd units, packaged as OCI artifacts and published via oras.

Bundles are split so the same quadlet bundle can be reused on multiple nodes with different configs:

- `quadlets/<name>/` — quadlet units (`.container`, `.volume`, `.network`)
- `configs/<name>/` — application config files; node-specific configs live in `configs/<name>/<node>/` (e.g. `configs/caddy/raspberrypi-5/`)

## Bundle Structure

Each bundle directory contains:

- `bundle/` — the payload: `containers/systemd/` for quadlet units, `config/` for app configs, plus a `metadata` template whose `__NAME__`/`__VERSION__` placeholders are sed-replaced at build time
- `Makefile` — tars `bundle/` into `target/<name>-v<tag>.tar.gz` and pushes it as an OCI artifact
- `target/` — build output (gitignored)

The bundle `metadata` `name:` is informational; install dirs on the node come from `stacks[].name` in `nodes/<node>/deployment-stack.yaml`: `~/.config/containers/systemd/<stack>/` and `~/.config/config/<stack>/`.

## Registry paths

- Quadlets: `zot.innokentii-kozlov.com/bundles/quadlets/<name>`
- Configs: `zot.innokentii-kozlov.com/bundles/configs/<name>`
- Node-specific configs: `zot.innokentii-kozlov.com/bundles/configs/<name>/<node>`

## Commands

From `bundles/`:

- `make build` — build all quadlet and config bundles
- `make build-sub/<quadlets|configs>` — build one group
- `make publish` — publish all bundles to the registry
- `make publish-sub/<quadlets|configs>` — publish one group

From a bundle subdirectory (e.g. `bundles/quadlets/caddy/` or `bundles/configs/caddy/raspberrypi-5/`):

- `make build` — build this bundle
- `make publish` — publish this bundle

Versions are manual: bump `BUILD_TAG_MAJOR/MINOR/PATCH` in the bundle's Makefile.
