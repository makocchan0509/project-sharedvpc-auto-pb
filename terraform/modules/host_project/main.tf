
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

resource "google_compute_network" "main" {
  project                 = google_project.main.name
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_project_service" "main" {
  for_each = toset(var.enable_api_services)


  project = google_project.main.id
  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_dns_managed_zone" "main" {
  name       = var.zone_name
  dns_name   = var.dns_name
  visibility = var.dns_visibility
  project    = google_project.main.name

  private_visibility_config {
    networks {
      network_url = google_compute_network.main.self_link
    }
  }
}

resource "google_dns_record_set" "main" {
  for_each = { for v in var.dns_records : v.name => v }

  name         = "${each.key}.${google_dns_managed_zone.main.dns_name}"
  managed_zone = google_dns_managed_zone.main.name
  type         = each.value.type
  ttl          = each.value.ttl
  project      = google_project.main.name
  rrdatas      = each.value.rrdatas

}
