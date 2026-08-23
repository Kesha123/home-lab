locals {
  forgejo_redirect = "https://forgejo.innokentii-kozlov.com/user/oauth2/authentik/callback"
  grafana_redirect = "https://grafana.innokentii-kozlov.com/login/generic_oauth"
  zot_redirect     = "https://zot.innokentii-kozlov.com/zot/auth/callback/oidc"

  base_scopes = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
  ]
}

resource "authentik_provider_oauth2" "forgejo" {
  name                       = "forgejo"
  client_id                  = "forgejo"
  client_type                = "confidential"
  authorization_flow         = data.authentik_flow.authorization_explicit_consent.id
  invalidation_flow          = data.authentik_flow.invalidation.id
  signing_key                = data.authentik_certificate_key_pair.self_signed.id
  access_code_validity       = "minutes=1"
  access_token_validity      = "minutes=5"
  refresh_token_validity     = "days=30"
  sub_mode                   = "hashed_user_id"
  issuer_mode                = "per_provider"
  include_claims_in_id_token = true
  logout_method              = "backchannel"
  grant_types                = ["authorization_code", "refresh_token"]

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = local.forgejo_redirect
    }
  ]

  property_mappings = concat(local.base_scopes, [
    data.authentik_property_mapping_provider_scope.entitlements.id,
    authentik_property_mapping_provider_scope.forgejo.id,
  ])
}

resource "authentik_provider_oauth2" "grafana" {
  name                       = "grafana"
  client_id                  = "grafana"
  client_type                = "public"
  authorization_flow         = data.authentik_flow.authorization_explicit_consent.id
  invalidation_flow          = data.authentik_flow.invalidation.id
  signing_key                = data.authentik_certificate_key_pair.self_signed.id
  access_code_validity       = "minutes=1"
  access_token_validity      = "minutes=5"
  refresh_token_validity     = "days=30"
  sub_mode                   = "hashed_user_id"
  issuer_mode                = "per_provider"
  include_claims_in_id_token = true
  logout_method              = "frontchannel"
  logout_uri                 = "https://grafana.innokentii-kozlov.com/logout"
  grant_types                = ["authorization_code", "refresh_token"]

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = local.grafana_redirect
    }
  ]

  property_mappings = concat(local.base_scopes, [
    data.authentik_property_mapping_provider_scope.entitlements.id,
  ])
}

resource "authentik_provider_oauth2" "zot" {
  name                       = "zot"
  client_id                  = "zot"
  client_type                = "confidential"
  authorization_flow         = data.authentik_flow.authorization_explicit_consent.id
  invalidation_flow          = data.authentik_flow.invalidation.id
  signing_key                = data.authentik_certificate_key_pair.self_signed.id
  access_code_validity       = "minutes=1"
  access_token_validity      = "minutes=5"
  refresh_token_validity     = "days=30"
  sub_mode                   = "hashed_user_id"
  issuer_mode                = "per_provider"
  include_claims_in_id_token = true
  logout_method              = "backchannel"
  grant_types                = ["authorization_code", "refresh_token"]

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = local.zot_redirect
    }
  ]

  property_mappings = local.base_scopes
}
