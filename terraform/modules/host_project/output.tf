output "folder_id" {
  value = google_folder.main.id
}

output "project_id" {
  value = google_project.main.id
}

output "project_number" {
  value = google_project.main.number
}

output "vpc_id" {
  value = google_compute_network.main.id
}

output "vpc_self_link" {
  value = google_compute_network.main.self_link
}
