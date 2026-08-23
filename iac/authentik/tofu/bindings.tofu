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

# Entitlement bindings: the 'admin' group receives the admin-tier entitlements.
# forgejo 'gitadmin' => forgejo admin role; 'gituser'/'gitrestricted' are left
# unbound for future assignment (e.g. to the 'family' group).
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
