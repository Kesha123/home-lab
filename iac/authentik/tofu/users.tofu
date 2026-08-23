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
