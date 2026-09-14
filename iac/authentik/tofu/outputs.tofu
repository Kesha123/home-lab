output "grafana_client_id" {
  value = authentik_provider_oauth2.grafana.client_id
}

output "grafana_client_secret" {
  value     = authentik_provider_oauth2.grafana.client_secret
  sensitive = true
}

output "forgejo_client_id" {
  value = authentik_provider_oauth2.forgejo.client_id
}

output "forgejo_client_secret" {
  value     = authentik_provider_oauth2.forgejo.client_secret
  sensitive = true
}

output "zot_client_id" {
  value = authentik_provider_oauth2.zot.client_id
}

output "zot_client_secret" {
  value     = authentik_provider_oauth2.zot.client_secret
  sensitive = true
}

# Robot bootstrap passwords: needed once for interactive logins (zot UI to mint
# an API key as svc-zot-ci, Forgejo to link svc-renovate and mint a PAT).
output "svc_zot_ci_password" {
  value     = random_password.svc_zot_ci.result
  sensitive = true
}

output "svc_renovate_password" {
  value     = random_password.svc_renovate.result
  sensitive = true
}
