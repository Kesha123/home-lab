resource "sonarr_download_client_transmission" "transmission" {
  name     = "transmission"
  enable   = true
  priority = 1

  host     = "transmission"
  port     = 9091
  url_base = "/transmission/"
  use_ssl  = false

  username = var.transmission_username
  password = var.transmission_password

  tv_category                = "tv-sonarr"
  remove_completed_downloads = false
  remove_failed_downloads    = false
}

resource "sonarr_root_folder" "series" {
  path = "/downloads/series"
}
