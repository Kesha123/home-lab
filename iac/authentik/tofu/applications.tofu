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
