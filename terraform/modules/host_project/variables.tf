variable "display_name" {
  type = string
}

variable "folder_parent" {
  type = string
}

variable "assign_roles_members" {
}

variable "project_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "project_labels" {
  type = map(string)
}

variable "vpc_name" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "dns_visibility" {
  type = string
}

variable "dns_records" {
}

variable "enable_api_services" {
  type = list(string)
}
