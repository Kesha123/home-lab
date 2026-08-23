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
