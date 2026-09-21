variable "sonarr_api_key" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Sonarr API key (podman secret sonarr-SONARR__AUTH__APIKEY on the node). Provide via TF_VAR_sonarr_api_key."
}

variable "radarr_api_key" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Radarr API key (podman secret radarr-RADARR__AUTH__APIKEY on the node). Provide via TF_VAR_radarr_api_key."
}

variable "prowlarr_api_key" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Prowlarr API key (podman secret prowlarr-PROWLARR__AUTH__APIKEY on the node). Provide via TF_VAR_prowlarr_api_key."
}

variable "transmission_username" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Transmission RPC username (podman secret transmission-USER on the node). Provide via TF_VAR_transmission_username."
}

variable "transmission_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Transmission RPC password (podman secret transmission-PASS on the node). Provide via TF_VAR_transmission_password."
}
