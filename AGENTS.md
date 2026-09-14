# AGENTS.md

## Repo shape

- Infra-as-code home lab (no app code): podman quadlet bundles + node configs, opentofu. No tests, linters, or typecheck — verification is `make build` in the relevant subdirectory.
- Root `Makefile` has no build targets — always run `make` inside a subdirectory.
- Nodes: `dell-optiplex-3000` (x86_64) and `raspberrypi-5` (aarch64), SSH user `admin`, key at `~/.ssh/<node>`.

## Commands

- Bundles: from `bundles/`, `make build` / `make publish` (all) or `build-sub/<quadlets|configs>` (one group). Single bundle: `make -C bundles/quadlets/caddy build|publish`. Output goes to `target/` (gitignored).
- Node deploy: `make -C nodes/<node> sync-container-stack` — SSHes to the node and installs bundles from `deployment-stack.yaml`. Requires `yq` and the remote helper (`make -C nodes/<node>/scripts install` pushes it to `~/.local/bin/`).
- IaC: `make -C iac/authentik plan|apply` (opentofu; needs `AUTHENTIK_TOKEN`, `TF_VAR_admin_password`, `TF_VAR_innokentii_password`).

## Bundles

- OCI artifacts pushed with `oras` to `zot.innokentii-kozlov.com/bundles/{quadlets,configs}/<name>`. Node-specific configs are separate bundles: `bundles/configs/<name>/<node>/`.
- Versions are manual: bump `BUILD_TAG_MAJOR/MINOR/PATCH` in the bundle's own `Makefile` (everything is `0.0.0` right now).
- `bundle/metadata` is a template; `__NAME__`/`__VERSION__` are sed-replaced at build time.
- The tar is built reproducibly (fixed mtime/owner, pax timestamps stripped). Keep those tar flags intact or digests churn for every bundle.

## Zot mirror convention (critical)

- Container images in quadlet files must reference the zot mirror, not upstream: `Image=zot.innokentii-kozlov.com/<docker|ghcr|quay|gcr|forgejo|codeberg>/<path>:<tag>`.
- Renovate uses regex managers mapping these paths back to upstream registries; a direct upstream reference (except explicit `ghcr.io`) will silently get no update PRs. Renovate groups all image updates into one PR, limit 1 concurrent.

## Release flow

- CI is Forgejo Actions (`.forgejo/workflows/`), not GitHub Actions.
- `bundle-release` runs on every PR: `make -C bundles build publish` republishes **all** bundles to zot. Builds are reproducible, so unaffected bundles keep their digest.
- `nodes/<node>/deployment-stack.yaml` pins each bundle by `version` + `digest`. These are **not** updated by CI — after merging, manually update the digest of changed bundles, then run `sync-container-stack` on the affected nodes.
