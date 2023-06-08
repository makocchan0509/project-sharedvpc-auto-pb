
resource "google_folder" "main" {
  display_name = var.display_name
  parent       = var.folder_parent
}

resource "google_folder_iam_binding" "main" {
  for_each = { for v in var.assign_roles_members : v.role => v }

  folder  = google_folder.main.name
  role    = each.key
  members = each.value.members
}
