# Registering Sonarr/Radarr as applications makes Prowlarr full-sync its
# indexers into them and keep them up to date (synced indexers authenticate
# with Prowlarr's own API key).
resource "prowlarr_application_sonarr" "sonarr" {
  name         = "Sonarr"
  sync_level   = "fullSync"
  base_url     = "http://sonarr:8989"
  prowlarr_url = "http://prowlarr:9696"
  api_key      = var.sonarr_api_key
}

resource "prowlarr_application_radarr" "radarr" {
  name         = "Radarr"
  sync_level   = "fullSync"
  base_url     = "http://radarr:7878"
  prowlarr_url = "http://prowlarr:9696"
  api_key      = var.radarr_api_key
}

# FlareSolverr-compatible proxy backed by the Byparr container, for
# Cloudflare-protected indexers (e.g. RuTracker). Indexers opt in by
# carrying the same tag as the proxy.
resource "prowlarr_tag" "cf_bypass" {
  label = "cf-bypass"
}

resource "prowlarr_indexer_proxy_flaresolverr" "byparr" {
  name            = "byparr"
  host            = "http://byparr:8191"
  request_timeout = 120
  tags            = [prowlarr_tag.cf_bypass.id]
}
