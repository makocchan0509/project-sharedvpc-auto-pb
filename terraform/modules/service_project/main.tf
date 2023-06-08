
resource "google_folder" "main" {
  display_name = var.display_name
  parent       = var.folder_parent
}

resource "google_folder_iam_binding" "main" {
  for_each = { for i, v in var.assign_roles_members : i => v }

  folder  = google_folder.main.name
  role    = each.value.role
  members = each.value.members
}

resource "google_project" "main" {
  name                = var.project_name
  project_id          = var.project_id
  folder_id           = google_folder.main.name
  billing_account     = var.billing_account
  auto_create_network = false
  skip_delete         = true
  labels              = var.project_labels
}

resource "google_compute_subnetwork" "main" {
  name                     = var.subnet_name
  project                  = var.host_project_id
  ip_cidr_range            = var.subnet_cidr_range
  region                   = var.subnet_region
  network                  = var.vpc_id
  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ip_ranges

    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.cidr_range
    }
  }
}

resource "google_compute_subnetwork_iam_binding" "main" {
  region     = var.subnet_region
  subnetwork = google_compute_subnetwork.main.name
  project    = var.host_project_id
  role       = "roles/compute.networkUser"
  members    = var.assign_nw_user_members
}



