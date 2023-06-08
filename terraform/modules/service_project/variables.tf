
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

variable "host_project_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "project_labels" {
  type = map(string)
}

variable "subnet_name" {
  type = string
}

variable "subnet_cidr_range" {
  type = string
}

variable "subnet_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "secondary_ip_ranges" {
  type = list(map(string))
}

variable "assign_nw_user_members" {
  type = list(string)
}
