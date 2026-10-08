variable "idsec_username" {
  description = "Service user that the Terraform pipeline logs in as."
  type        = string
}

variable "idsec_secret" {
  description = "Secret for the service user. The pipeline supplies it at run time."
  type        = string
  sensitive   = true
}

variable "pam_admins_group" {
  description = "Privilege Cloud group that manages the safes."
  type        = string
  default     = "PAM Admins"
}

variable "app_team_group" {
  description = "Privilege Cloud group for the reporting app team. It may add accounts, not read them."
  type        = string
  default     = "Reporting App Team"
}

variable "db_addresses" {
  description = "Database host for each environment."
  type        = map(string)
  default = {
    dev  = "reporting-db.dev.srs-energy.internal"
    prod = "reporting-db.prod.srs-energy.internal"
  }
}

variable "initial_passwords" {
  description = "The current, hard-coded password for each environment. Used once, then rotated."
  type        = map(string)
  sensitive   = true
}

variable "pcloud_url" {
  description = "Privilege Cloud base URL, for the rotate-now API call."
  type        = string
}

variable "pcloud_token" {
  description = "Privilege Cloud API token for the rotate-now call. The pipeline supplies it at run time."
  type        = string
  sensitive   = true
}
