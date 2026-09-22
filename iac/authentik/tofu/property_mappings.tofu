resource "authentik_property_mapping_provider_scope" "forgejo" {
  name       = "authentik forgejo OAuth Mapping: OpenID 'forgejo'"
  scope_name = "forgejo"
  expression = <<EOF
entitlement_names = {
    entitlement.name
    for entitlement in request.user.app_entitlements(provider.application)
}
forgejo_claims = {}

if "gituser" in entitlement_names:
    forgejo_claims["forgejo"] = "user"
if "gitadmin" in entitlement_names:
    forgejo_claims["forgejo"] = "admin"
if "gitrestricted" in entitlement_names:
    forgejo_claims["forgejo"] = "restricted"

return forgejo_claims
EOF
}

# zot resolves group names from the OIDC 'groups' claim (defaultGroupsClaim)
# and matches them against accessControl policies (e.g. groups: ["zot-ci"]).
resource "authentik_property_mapping_provider_scope" "zot_groups" {
  name        = "authentik zot OAuth Mapping: OpenID 'groups'"
  scope_name  = "groups"
  description = "Group memberships for zot accessControl policies"
  expression  = <<EOF
groups = [
    group.name
    for group in request.user.groups.all()
]
return {"groups": groups}
EOF
}

resource "authentik_property_mapping_provider_scope" "jellyfin_groups" {
  name        = "authentik jellyfin OAuth Mapping: OpenID 'groups'"
  scope_name  = "groups"
  description = "Group memberships for JellyfinSecurity SSO allowlists"
  expression  = <<EOF
groups = [
    group.name
    for group in request.user.groups.all()
]
return {"groups": groups}
EOF
}
