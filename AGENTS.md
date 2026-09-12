# AGENTS.md

Homelab infra repo: OpenTofu IaC (Authentik IAM) + Podman Quadlet container stacks, packaged as OCI artifacts and deployed to nodes over SSH. No tests, lint, or CI — verification is `make validate` under `iac/authentik/`.

## Layout

The root `Makefile` defines no targets — all actions run via subdirectory Makefiles:

- `iac/authentik/` — OpenTofu for Authentik. Targets: `init plan apply destroy fmt validate`. Requires env: `AUTHENTIK_TOKEN` (use the `AUTHENTIK_BOOTSTRAP_TOKEN` value), `TF_VAR_admin_password`, `TF_VAR_innokentii_password`. State is local and gitignored.
- `bundles/quadlets/<name>/` — quadlet bundles: `bundle/containers/systemd/*.container|*.volume|*.network` plus a `bundle/metadata` template whose `__NAME__`/`__VERSION__` placeholders are sed-replaced at build time.
- `bundles/configs/<name>/` — config bundles: `bundle/config/` plus `bundle/metadata`. Node-specific configs live in `bundles/configs/<name>/<node>/` (e.g. `configs/caddy/raspberrypi-5/`); their metadata still renders `name: <name>` (e.g. `caddy`), only the registry path carries the node.
- `nodes/<node>/` — `deployment-stack.yaml` (per-node `stacks:` list; each stack has a name and an ordered `bundles:` list of name/version/digest) plus helper scripts rsynced to the node (`make install` in `scripts/`).

## Bundles: build & publish

From `bundles/`: `make build`, `make publish`; or run `make build`/`make publish` inside a bundle dir (e.g. `bundles/quadlets/caddy/`, `bundles/configs/caddy/raspberrypi-5/`). Group-level targets exist too: `make build-sub/<quadlets|configs>`.

- Quadlets publish to `zot.innokentii-kozlov.com/bundles/quadlets/<name>`; configs to `zot.innokentii-kozlov.com/bundles/configs/<name>`; node-specific configs to `zot.innokentii-kozlov.com/bundles/configs/<name>/<node>`.
- The bundle `metadata` `name:` is informational; install dirs on the node come from `stacks[].name` in `nodes/<node>/deployment-stack.yaml` (`~/.config/containers/systemd/<stack>/` and `~/.config/config/<stack>/`).
- Versions are manual: bump `BUILD_TAG_MAJOR/MINOR/PATCH` in the bundle's Makefile.
- All `target/` dirs are gitignored build output.

## Deploying to nodes

Flow for any bundle change:

1. Bump `BUILD_TAG_*`, then `make build` and `make publish` in the bundle dir.
2. Update `nodes/<node>/deployment-stack.yaml` (`stacks[].bundles[]`): set `version` to the new tag and `digest` to the published artifact digest, under the stack(s) that consume the bundle.
3. From `nodes/<node>/`: `make sync-container-stack` — reads `deployment-stack.yaml`, flattens it to `stack bundle version digest` rows, SSHes to `admin@<node>.innokentii-kozlov.com`, and the remote `deployment-stack sync-container-stack <stack> <bundle> <version> <digest>` pulls the bundle, verifies the digest (fails on mismatch), and installs its files into dirs named after the stack (quadlet units into `~/.config/containers/systemd/<stack>/`, configs into `~/.config/config/<stack>/`, whichever trees the bundle contains). Bundles within a stack are applied in list order, so later bundles can add/overwrite files from earlier ones.
4. After script changes under `nodes/<node>/scripts/`: `make install` there to rsync them to the node.

Requires SSH access to the node and `yq` locally.

## Helpers

- `scripts/zot-setup generate-oidc-credentials` — renders Authentik tofu outputs to `scripts/target/oidc-credentials.json`; requires applied tofu state (`make apply` in `iac/authentik/` first).

## Conventions

- Container credentials never live in the repo: Quadlet files reference Podman secrets (`Secret=...`), and Authentik users/groups/apps are managed only via tofu under `iac/authentik/`.
