# Arr stack

Automates the wiring between the `*arr` apps running on `dell-optiplex-3000`:

- **Sonarr / Radarr**: registers the Transmission download client
  (`transmission:9091`, categories `tv-sonarr` / `radarr`) and the root
  folders (`/downloads/series`, `/downloads/movies` on the shared
  `transmission-downloads` volume).
- **Prowlarr**: registers Sonarr and Radarr as applications with `fullSync`,
  so every indexer added in Prowlarr is pushed into them automatically
  (indexer selection itself stays manual in the Prowlarr UI).

Bazarr has no Terraform provider; its Sonarr/Radarr connections are configured
once through its web UI (first-run wizard or Settings).

## Providers

[devopsarr/sonarr](https://registry.terraform.io/providers/devopsarr/sonarr),
[devopsarr/radarr](https://registry.terraform.io/providers/devopsarr/radarr),
[devopsarr/prowlarr](https://registry.terraform.io/providers/devopsarr/prowlarr)
from `registry.terraform.io` (not mirrored on `registry.opentofu.org`).

## Reachability and auth model

The apps are reached through Caddy at `https://<app>.innokentii-kozlov.com`:

- UI paths: authentik forward auth (admin group only).
- `/api/*`: exempt from forward auth in Caddy and protected by the apps'
  `X-Api-Key` enforcement — this is what the providers use.
  The *arr apps enforce X-Api-Key on /api/* themselves, so those paths skip
  forward auth and can be driven by tofu/scripts; UI paths stay authentik-only.

## Prowlarr & Byparr

  FlareSolverr-compatible proxy backed by the [Byparr](https://github.com/ThePhaseless/Byparr/) container, for Cloudflare-protected indexers.
  Indexers opt in by carrying the same tag as the proxy.

## Required environment variables

| Variable | Provenance |
| --- | --- |
| `TF_VAR_sonarr_api_key` | podman secret `sonarr-SONARR__AUTH__APIKEY` on the node |
| `TF_VAR_radarr_api_key` | podman secret `radarr-RADARR__AUTH__APIKEY` on the node |
| `TF_VAR_prowlarr_api_key` | podman secret `prowlarr-PROWLARR__AUTH__APIKEY` on the node |
| `TF_VAR_transmission_username` | podman secret `transmission-USER` on the node |
| `TF_VAR_transmission_password` | podman secret `transmission-PASS` on the node |

Read secret values on the node with
`podman secret inspect --showsecret --format "{{.SecretData}}" <name>`
(plain `--showsecret` prints the JSON envelope instead of the value).

## Usage

```sh
make -C iac/arr init
make -C iac/arr plan
make -C iac/arr apply
```
