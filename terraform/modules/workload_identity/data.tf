
data "google_service_account" "main" {
  for_each = toset(var.service_accounts)

  account_id = each.value
}
