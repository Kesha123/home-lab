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

# Robot access: 'zot-ci' may use the zot app (identity for zot API keys);
# 'forgejo-bots' may use the forgejo app with the 'gituser' entitlement only
# (Forgejo 'user' role via the forgejo scope property mapping — not admin).
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

# Entitlement bindings: the 'admin' group receives the admin-tier entitlements.
# forgejo 'gitadmin' => forgejo admin role; 'gituser' => 'forgejo-bots' robots;
# 'gitrestricted' is left unbound for future assignment (e.g. to 'family').
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
