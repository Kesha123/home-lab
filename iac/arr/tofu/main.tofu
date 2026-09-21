terraform {
  required_version = ">= 1.6.0"

  required_providers {
    sonarr = {
      source  = "registry.terraform.io/devopsarr/sonarr"
      version = "~> 3.5"
    }
    radarr = {
      source  = "registry.terraform.io/devopsarr/radarr"
      version = "~> 2.5"
    }
    prowlarr = {
      source  = "registry.terraform.io/devopsarr/prowlarr"
      version = "~> 3.2"
    }
  }
}

provider "sonarr" {
  url     = "https://sonarr.innokentii-kozlov.com"
  api_key = var.sonarr_api_key
}

provider "radarr" {
  url     = "https://radarr.innokentii-kozlov.com"
  api_key = var.radarr_api_key
}

provider "prowlarr" {
  url     = "https://prowlarr.innokentii-kozlov.com"
  api_key = var.prowlarr_api_key
}
