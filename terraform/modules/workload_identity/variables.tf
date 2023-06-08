variable "project_id" {
  type = string
}

variable "wid_pool_id" {
  type = string
}

variable "pool_display_name" {
  type = string
}

variable "pool_describe" {
  type = string
}

variable "disabled" {
  type = bool
}

variable "wid_provider_id" {
  type = string
}

variable "provider_display_name" {
  type = string
}

variable "provider_describe" {
  type = string
}

variable "service_accounts" {
  type = list(string)
}

variable "github_repository" {
  type = string
}
