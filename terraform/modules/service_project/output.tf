output "folder_id" {
  value = google_folder.main.id
}

output "folder_name" {
  value = google_folder.main.name
}

output "project_id" {
  value = google_project.main.id
}

output "project_number" {
  value = google_project.main.number
}

output "subnet_id" {
  value = google_compute_subnetwork.main.id
}

output "subnet_self_link" {
  value = google_compute_subnetwork.main.self_link
}
