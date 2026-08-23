terraform {
  required_version = ">= 1.6.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2026.5"
    }
  }
}

provider "authentik" {
  url = "https://authentik.innokentii-kozlov.com"
  # token is read from the AUTHENTIK_TOKEN environment variable
}
