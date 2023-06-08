
resource "google_service_account" "main" {
  project    = var.project_id
  account_id = var.member
}

resource "google_project_iam_member" "main" {
  for_each = toset(var.assign_roles)

  project = var.project_id
  role    = each.value
  member  = google_service_account.main.member
}

resource "google_organization_iam_member" "main" {
  for_each = toset(var.organization_roles)

  org_id = var.org_id
  role   = each.value
  member = google_service_account.main.member
}
