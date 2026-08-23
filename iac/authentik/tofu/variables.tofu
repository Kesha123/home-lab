variable "admin_email" {
  type        = string
  description = "Email for the 'admin' user (member of 'authentik Admins' => superuser)."
  default     = "admin@innokentii-kozlov.com"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Initial password for the 'admin' user. Provide via TF_VAR_admin_password."
}

variable "innokentii_email" {
  type        = string
  description = "Email for the 'innokentii-kozlov' user."
  default     = "innokentiikozlov@gmail.com"
}

variable "innokentii_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Initial password for the 'innokentii-kozlov' user. Provide via TF_VAR_innokentii_password."
}
