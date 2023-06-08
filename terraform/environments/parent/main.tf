
locals {
  region          = "asia-northeast1"
  organization_id = "YOUR_ORGANIZATION_ID(not organization/)"
  project_id      = "YOUR_PROJECT_ID"

  enable_api_services = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com"
  ]

  service_accounts = [
    {
      member = "github-terraform"
      assign_roles = [
        "roles/owner"
      ]
      organization_roles = [
        "roles/compute.xpnAdmin",
        "roles/resourcemanager.folderAdmin",
        "roles/resourcemanager.projectCreator",
        "roles/resourcemanager.projectDeleter",
        "roles/resourcemanager.projectIamAdmin",
        "roles/resourcemanager.lienModifier",
        "roles/billing.projectManager",
        "roles/billing.user"
      ]
    }
  ]

  workload_identity = [
    {
      pool_id               = "github-pool"
      pool_display_name     = "github-pool"
      pool_describe         = "github actions"
      disabled              = false
      provider_id           = "github-provider"
      provider_display_name = "github-provider"
      provider_describe     = "github actions"
      github_repository     = "YOUR_GITHUB_REPOSITORY"

      service_accounts = [
        "github-terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com"
      ]
    }
  ]
}

resource "google_project_service" "main" {
  for_each = toset(local.enable_api_services)

  project = local.project_id
  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

module "service_account" {
  source   = "../../modules/service_account"
  for_each = { for v in local.service_accounts : v.member => v }

  project_id         = local.project_id
  assign_roles       = each.value.assign_roles
  member             = each.key
  org_id             = local.organization_id
  organization_roles = each.value.organization_roles
}

module "workload_identity" {
  source   = "../../modules/workload_identity"
  for_each = { for v in local.workload_identity : v.pool_id => v }

  project_id            = local.project_id
  wid_pool_id           = each.key
  pool_display_name     = each.value.pool_display_name
  pool_describe         = each.value.pool_describe
  disabled              = each.value.disabled
  wid_provider_id       = each.value.provider_id
  provider_display_name = each.value.provider_display_name
  provider_describe     = each.value.provider_describe
  service_accounts      = each.value.service_accounts
  github_repository     = each.value.github_repository

  depends_on = [
    google_project_service.main,
    module.service_account
  ]
}

