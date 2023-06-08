
resource "google_compute_shared_vpc_host_project" "main" {
  project = var.host_project_id
}

resource "google_compute_shared_vpc_service_project" "main" {
  for_each = var.service_project_ids

  host_project    = google_compute_shared_vpc_host_project.main.id
  service_project = each.key
}
