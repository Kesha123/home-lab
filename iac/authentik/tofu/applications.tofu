resource "authentik_application" "forgejo" {
  name               = "forgejo"
  slug               = "forgejo"
  protocol_provider  = authentik_provider_oauth2.forgejo.id
  policy_engine_mode = "any"
}

resource "authentik_application" "grafana" {
  name               = "grafana"
  slug               = "grafana"
  protocol_provider  = authentik_provider_oauth2.grafana.id
  policy_engine_mode = "any"
}

resource "authentik_application" "zot" {
  name               = "zot"
  slug               = "zot"
  protocol_provider  = authentik_provider_oauth2.zot.id
  policy_engine_mode = "any"
}

resource "authentik_application" "transmission" {
  name               = "transmission"
  slug               = "transmission"
  protocol_provider  = authentik_provider_proxy.transmission.id
  policy_engine_mode = "any"
}

resource "authentik_application" "sonarr" {
  name               = "sonarr"
  slug               = "sonarr"
  protocol_provider  = authentik_provider_proxy.sonarr.id
  policy_engine_mode = "any"
}

resource "authentik_application" "radarr" {
  name               = "radarr"
  slug               = "radarr"
  protocol_provider  = authentik_provider_proxy.radarr.id
  policy_engine_mode = "any"
}

resource "authentik_application" "prowlarr" {
  name               = "prowlarr"
  slug               = "prowlarr"
  protocol_provider  = authentik_provider_proxy.prowlarr.id
  policy_engine_mode = "any"
}

resource "authentik_application" "bazarr" {
  name               = "bazarr"
  slug               = "bazarr"
  protocol_provider  = authentik_provider_proxy.bazarr.id
  policy_engine_mode = "any"
}

resource "authentik_application" "seerr" {
  name               = "seerr"
  slug               = "seerr"
  protocol_provider  = authentik_provider_proxy.seerr.id
  policy_engine_mode = "any"
}

# Proxy providers are only served when explicitly attached to the outpost:
# the outpost API filters by the service account's object permissions, so an
# outpost with no attached providers fetches an empty provider list.
data "authentik_outpost" "embedded" {
  name = "authentik Embedded Outpost"
}

resource "authentik_outpost_provider_attachment" "transmission" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.transmission.id
}

resource "authentik_outpost_provider_attachment" "sonarr" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.sonarr.id
}

resource "authentik_outpost_provider_attachment" "radarr" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.radarr.id
}

resource "authentik_outpost_provider_attachment" "prowlarr" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.prowlarr.id
}

resource "authentik_outpost_provider_attachment" "bazarr" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.bazarr.id
}

resource "authentik_outpost_provider_attachment" "seerr" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.seerr.id
}

resource "authentik_application_entitlement" "forgejo_gituser" {
  name        = "gituser"
  application = authentik_application.forgejo.uuid
}

resource "authentik_application_entitlement" "forgejo_gitadmin" {
  name        = "gitadmin"
  application = authentik_application.forgejo.uuid
}

resource "authentik_application_entitlement" "forgejo_gitrestricte" {
  name        = "gitrestricted"
  application = authentik_application.forgejo.uuid
}

resource "authentik_application_entitlement" "grafana_admins" {
  name        = "Grafana Admins"
  application = authentik_application.grafana.uuid
}
