
locals {
  region          = "asia-northeast1"
  env             = "develop"
  organization_id = "YOUR_ORGANIZATION_ID"

  enable_api_services = [
    "bigquery.googleapis.com",
    "stackdriver.googleapis.com",
    "storage.googleapis.com",
    "storage-component.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "iap.googleapis.com",
    "iam.googleapis.com",
    "dns.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "cloudidentity.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigquerystorage.googleapis.com",
    "composer.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "admin.googleapis.com",
    "vpcaccess.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "osconfig.googleapis.com",
    "containeranalysis.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]

  departments = var.departments

  host_projects = [
    {
      name = join("-", ["HOST_PROJECT_ID", local.env])

      folder_name = "common-network"
      assign_roles_members = [
        {
          role = "roles/owner"
          members = [
            "serviceAccount:github-terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com"
          ]
        }
      ]

      project_id      = join("-", ["HOST_PROJECT_ID", local.env])
      billing_account = "YOUR_BILLING_ID"
      labels = {
        "managed-by" : "terraform"
      }

      network = {
        vpc_name = "shared-network"

        private_google_access = {
          zone_name      = "private-google-access"
          dns_name       = "googleapis.com."
          dns_visibility = "private"

          records = [
            {
              name = "*"
              type = "CNAME"
              ttl  = 300
              rrdatas = [
                "private.googleapis.com."
              ]
            },
            {
              name = "private"
              type = "A"
              ttl  = 300
              rrdatas = [
                "199.36.153.8",
                "199.36.153.9",
                "199.36.153.10",
                "199.36.153.11"
              ]
            }
          ]
        }
      }
    }
  ]
  service_projects = var.service_projects

}

resource "google_folder" "main" {
  display_name = local.env
  parent       = local.organization_id
}

module "departments" {
  source   = "../../modules/department"
  for_each = { for v in local.departments : v.name => v }

  display_name         = each.value.folder_name
  folder_parent        = resource.google_folder.main.id
  assign_roles_members = each.value.assign_roles_members
}

module "host_projects" {
  source   = "../../modules/host_project"
  for_each = { for v in local.host_projects : v.name => v }

  display_name         = each.value.folder_name
  folder_parent        = resource.google_folder.main.id
  assign_roles_members = each.value.assign_roles_members
  project_name         = each.value.project_id
  project_id           = each.value.project_id
  billing_account      = each.value.billing_account
  project_labels       = each.value.labels
  enable_api_services  = local.enable_api_services
  vpc_name             = each.value.network.vpc_name
  zone_name            = each.value.network.private_google_access.zone_name
  dns_name             = each.value.network.private_google_access.dns_name
  dns_visibility       = each.value.network.private_google_access.dns_visibility
  dns_records          = each.value.network.private_google_access.records
}

module "service_projects" {
  source = "../../modules/service_project"

  for_each = { for v in local.service_projects : "${v.name}-${local.env}" => v }

  display_name           = each.value.folder_name
  folder_parent          = module.departments[each.value.department].folder_id
  assign_roles_members   = each.value.assign_roles_members
  project_name           = "${each.value.project_id}-${local.env}"
  project_id             = "${each.value.project_id}-${local.env}"
  host_project_id        = "${each.value.host_project_name}-${local.env}"
  billing_account        = each.value.billing_account
  project_labels         = each.value.labels
  subnet_name            = each.value.network.subnet_name
  subnet_cidr_range      = each.value.network.subnet_cidr_range
  subnet_region          = local.region
  vpc_id                 = module.host_projects["${each.value.host_project_name}-${local.env}"].vpc_id
  secondary_ip_ranges    = each.value.network.secondary_ip_ranges
  assign_nw_user_members = each.value.network.assign_nw_user_members

  depends_on = [module.host_projects]
}

module "shared_vpc" {
  source   = "../../modules/shared_vpc"
  for_each = { for v in local.host_projects : v.name => v }

  host_project_id     = each.value.project_id
  service_project_ids = { for v in local.service_projects : "${v.project_id}-${local.env}" => true if "${v.host_project_name}-${local.env}" == each.key }

  depends_on = [module.service_projects]
}

