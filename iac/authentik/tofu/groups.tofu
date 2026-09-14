resource "authentik_group" "admin" {
  name = "admin"
}

resource "authentik_group" "family" {
  name = "family"
}

# Robot groups: consumed by bindings.tofu (app/entitlement access) and, for
# 'zot-ci', by zot's accessControl policies via the 'groups' OIDC claim.
resource "authentik_group" "zot_ci" {
  name = "zot-ci"
}

resource "authentik_group" "forgejo_bots" {
  name = "forgejo-bots"
}
