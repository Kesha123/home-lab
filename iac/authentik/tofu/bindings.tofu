# Application access: only the 'admin' group can see/use each application.
resource "authentik_policy_binding" "forgejo_access" {
  target = authentik_application.forgejo.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "grafana_access" {
  target = authentik_application.grafana.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "zot_access" {
  target = authentik_application.zot.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "transmission_access" {
  target = authentik_application.transmission.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "sonarr_access" {
  target = authentik_application.sonarr.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "radarr_access" {
  target = authentik_application.radarr.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "prowlarr_access" {
  target = authentik_application.prowlarr.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "bazarr_access" {
  target = authentik_application.bazarr.uuid
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "zot_ci_access" {
  target = authentik_application.zot.uuid
  group  = authentik_group.zot_ci.id
  order  = 1
}

resource "authentik_policy_binding" "forgejo_bots_access" {
  target = authentik_application.forgejo.uuid
  group  = authentik_group.forgejo_bots.id
  order  = 1
}

resource "authentik_policy_binding" "forgejo_gituser_bots" {
  target = authentik_application_entitlement.forgejo_gituser.id
  group  = authentik_group.forgejo_bots.id
  order  = 1
}

resource "authentik_policy_binding" "forgejo_gitadmin" {
  target = authentik_application_entitlement.forgejo_gitadmin.id
  group  = authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "grafana_admins" {
  target = authentik_application_entitlement.grafana_admins.id
  group  = authentik_group.admin.id
  order  = 0
}
