# Monitoring Recommendations for `stack/`

Scope: `dell-optiplex-3000` rootless podman stack. Existing: Prometheus + Grafana + node-exporter; blocky, zot, prometheus already scraped.

## Tools

| Tool | Status | Role | Justification |
|---|---|---|---|
| **Prometheus** | have | Metrics pull | Pull model fits rootless podman; no in-app agents, already integrated. |
| **Grafana** | have | Dashboards + alerting | Provisioned as code, SSO via authentik. Use built-in alerting — no Alertmanager needed. |
| **Blackbox exporter** | new | HTTPS/TCP probes | Replaces homepage `ping`; one place for uptime/SLO of all `*.innokentii-kozlov.com` sites + cert expiry. |
| **postgres_exporter** | new | PostgreSQL metrics | Only DB in stack (authentik); needed for conn/tx/disk health. |
| **smartctl_exporter** | new | Disk SMART + temps | Covers README TODO (temperatures); node-exporter is blind to SMART. |
| **Loki + Promtail** | new | Logs | Native Grafana integration, low overhead; correlates logs with metrics during incidents. |

## Per-service

| Service | What to monitor | How | Why |
|---|---|---|---|
| **dell-optiplex-3000** (host) | CPU, RAM, disk, net | node-exporter (have) | Single host = single failure domain; core README TODO. |
| Host temps | CPU/package temp | node-exporter `--collector.thermal_zone` | Quick win for TODO; reads `/sys/class/thermal`. |
| Disks | SMART attrs, disk temp, failures | smartctl_exporter | Predict disk failure; node-exporter can't read SMART. |
| **caddy** | req count, latency, 5xx, upstream errors, cert expiry | Add caddy to `backend.network`, set `admin :2019`, scrape `caddy:2019/metrics` | Edge proxy = first hop for every incident; cert expiry = outage (DNS-01 certs need renewal tracking). |
| **authentik** server/worker | logins, flows, exceptions, workers | `AUTHENTIK_LISTEN__METRICS=0.0.0.0:9300`, scrape `authentik-server:9300/metrics` (already on backend net) | SSO = auth for grafana/zot/ezbookkeeping; its failure cascades. |
| **authentik-postgresql** | conns, tx, cache hit, DB size | postgres_exporter -> authentik-postgresql:5432, scrape :9187 | Only stateful store; conn exhaustion / disk = authentik down. |
| **blocky** (have) | queries, blocked ratio, upstream latency | already scraped | DNS resolves everything; block ratio = ad-filter health. |
| **zot** (have) | pushes/pulls, sync lag, CVE scans, storage | already scraped; enrich dashboard with sync + CVE metrics | Registry hosts all images incl. monitoring stack; sync lag = stale images. |
| **ezbookkeeping** | uptime, latency, HTTP status | blackbox exporter (HTTPS); logs via Loki | No native metrics; SQLite data at risk → watch uptime + verify backups. |
| **homepage** | uptime | blackbox exporter | No metrics; only need "dashboard up". |
| **All public sites** | cert expiry, 2xx/5xx, latency | blackbox `http_2xx` prober | Catches TLS/route53 + proxy outages centrally. |
| **prometheus** (have) | scrape duration, ingest rate, WAL | already self-scraped | Confirm monitoring itself is healthy. |
| **grafana** | uptime | blackbox exporter | Dashboards must be reachable during incidents. |

## Alerts (Grafana alerting)

- **Host:** CPU > 90% (5m), disk > 85%, RAM > 90%, temp > 80°C, SMART degraded.
- **caddy:** 5xx rate > 1%, TLS cert < 14d to expiry.
- **authentik-pg:** conns > 80% max, DB size growth spike.
- **blocky:** upstream error rate > 5%.
- **blackbox:** any probe failing > 1m.
- **prometheus:** scrape failures, ingest behind.

## Constraints

- **Network isolation:** scrape only what shares `backend.network` or is reachable over public HTTPS (existing zot/blocky pattern). caddy + authentik get direct scrape via backend net; ezbookkeeping/homepage stay frontend-only → blackbox over HTTPS. Adding caddy to backend.net makes it a tier bridge — acceptable, it is the edge.
- Retention `365d/10GB` (have) is ample for a single host.
- Consider rotating plaintext secrets in `ezbookkeeping.ini` / `grafana.ini` before shipping logs to Loki.
