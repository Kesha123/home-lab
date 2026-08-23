data "authentik_flow" "authorization_explicit_consent" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_flow" "invalidation" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_certificate_key_pair" "self_signed" {
  name              = "authentik Self-signed Certificate"
  fetch_certificate = false
  fetch_key         = false
}

data "authentik_group" "authentik_admins" {
  name = "authentik Admins"
}

data "authentik_property_mapping_provider_scope" "openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_property_mapping_provider_scope" "email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

data "authentik_property_mapping_provider_scope" "profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_property_mapping_provider_scope" "entitlements" {
  managed = "goauthentik.io/providers/oauth2/scope-entitlements"
}
