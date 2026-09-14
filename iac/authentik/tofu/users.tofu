resource "authentik_user" "admin" {
  username  = "admin"
  name      = "Administrator"
  email     = var.admin_email
  password  = var.admin_password
  groups    = [data.authentik_group.authentik_admins.id]
  type      = "internal"
  is_active = true
}

resource "authentik_user" "innokentii_kozlov" {
  username = "innokentii-kozlov"
  name     = "Innokentii Kozlov"
  email    = var.innokentii_email
  password = var.innokentii_password
  groups = [
    authentik_group.admin.id,
    authentik_group.family.id,
  ]
  type      = "internal"
  is_active = true
}

# Robot accounts. Passwords are generated and only needed for the one-time
# interactive bootstrap (zot UI login to mint an API key, Forgejo login to link
# the user); read them via `tofu output -raw <name>` and store nothing locally.

resource "random_password" "svc_zot_ci" {
  length  = 32
  special = false
}

resource "authentik_user" "svc_zot_ci" {
  username = "svc-zot-ci"
  name     = "svc-zot-ci (zot CI robot)"
  # email is the identity zot sees in accessControl policies (OIDC 'email' claim)
  email     = "svc-zot-ci@innokentii-kozlov.com"
  password  = random_password.svc_zot_ci.result
  groups    = [authentik_group.zot_ci.id]
  type      = "service_account"
  is_active = true
}

resource "random_password" "svc_renovate" {
  length  = 32
  special = false
}

resource "authentik_user" "svc_renovate" {
  username  = "svc-renovate"
  name      = "svc-renovate (renovate robot)"
  email     = "svc-renovate@innokentii-kozlov.com"
  password  = random_password.svc_renovate.result
  groups    = [authentik_group.forgejo_bots.id]
  type      = "service_account"
  is_active = true
}
