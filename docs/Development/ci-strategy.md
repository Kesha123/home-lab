# CI Strategy

This repository uses GitHub Actions with a single orchestration entrypoint and reusable workflows behind wrapper workflows.

## Implemented Workflow Map

- Orchestrator workflow
   - `ci-main.yml`
   - Central CI orchestration for builds and packaging on `main`, `workflow_dispatch`, and `workflow_call`.
- Wrapper workflows
   - Container wrappers: `wrapper-container-ansible-runner.yml`, `wrapper-container-mkdocs.yml`, `wrapper-container-pulumi-executor.yml`
   - Workflow wrappers: `wrapper-workflow-k3s-install.yml`, `wrapper-workflow-rpi-os-setup.yml`, `wrapper-workflow-software-install.yml`
   - Docs wrapper: `wrapper-docs.yml`
   - Wrappers are entrypoint adapters for manual runs and orchestration calls; they delegate execution to reusable workflows.
- Reusable workflows
   - `reusable-build-container.yml`
   - `reusable-build-workflow.yml`
   - `reusable-build-docs.yml`
   - Reusable workflows implement standardized build/package logic and artifact publication.
- Release orchestrators
   - `release-promotion.yml`: computes and pushes next semver tag.
   - `release.yml`: resolves release tag, runs release builds via wrappers, and creates/updates GitHub Release.

## Trigger Matrix

| Flow | PR | Push to `main` | Tag `X.Y.Z` | `workflow_dispatch` | `workflow_call` |
|---|---|---|---|---|---|
| `ci-main.yml` | No | Yes (path-scoped) | No | Yes | Yes |
| Container wrappers | No | No | No | Yes | Yes |
| Workflow wrappers | No | No | No | Yes | Yes |
| Docs wrapper | No | No | No | Yes | Yes |
| `release-promotion.yml` | No | No | No | Yes | No |
| `release.yml` | No | No | Yes | Yes | No |

## Permissions Model

- No top-level `permissions` block is used in wrappers/reusables/orchestrators.
- Every job declares only required permissions explicitly.
- Jobs calling container wrappers use `contents: read` and `packages: write`.
- Jobs calling workflow wrappers use `contents: read`.
- Jobs calling docs wrapper use `contents: read`, `pages: write`, and `id-token: write`.
- Release creation job uses `contents: write`.

## Make Targets Contract

CI and release workflows rely on `make` as the single execution contract:

- Container build targets: `build/container/<name>`
- Container publish targets: `push/container/<name>`
- Workflow packaging targets: `ci/workflow/<name>`
- Docs target: `ci/docs`

If a target is missing, CI should fail with an actionable error.

## Release Process

1. Run `release-promotion.yml` manually with `patch`, `minor`, or `major`.
2. Workflow creates and pushes a semver tag (`X.Y.Z`).
3. Tag push triggers `release.yml` (or run it manually with `release_tag`).
4. `release.yml` runs wrapper builds using the release tag, downloads artifacts, and updates GitHub Release.

## Troubleshooting Checklist

1. Validate expected make target exists:
   - `make -n ci/docs`
   - `make -n ci/workflow/k3s-install`
   - `make -n build/container/ansible-runner`
2. Verify workflow trigger scope:
   - Confirm event type matches the workflow trigger contract (orchestrators handle push/tag flows; wrappers are dispatch/call only).
3. Verify permissions-sensitive jobs:
   - Container publish needs `packages: write`.
   - GitHub Release job needs `contents: write`.
   - Pages deploy needs `pages: write` and `id-token: write`.
4. Check concurrency behavior:
   - Concurrency is configured only in top-level orchestrators (`ci-main.yml`, `release.yml`, `release-promotion.yml`).
5. Validate release tag format:
   - Tag must match `X.Y.Z`.
