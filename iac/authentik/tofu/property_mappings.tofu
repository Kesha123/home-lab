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
