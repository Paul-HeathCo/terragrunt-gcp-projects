# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  
  remote_backend_vars = read_terragrunt_config(find_in_parent_folders("backend.hcl"))
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Extract the variables we need for easy access
  gcp_region   = local.region_vars.locals.gcp_region
  project_id = local.project_vars.locals.project_id

  remote_backend_gcp_region = local.remote_backend_vars.locals.remote_backend_gcp_region
  remote_backend_project_id = local.remote_backend_vars.locals.remote_backend_project_id
  supabase_api_key = get_env("SUPABASE_API_KEY")
  cloudflare_api_key = get_env("CLOUDFLARE_API_KEY")
}

# Generate a GCP provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
      terraform {
      required_providers {
          supabase = {
            source = "supabase/supabase"
            version = "1.4.0"
          }
          cloudflare = {
            source  = "cloudflare/cloudflare"
            version = "~> 4.0"
          }
        }
      }
      provider "google" {
        region = "${local.gcp_region}"
        project = "${local.project_id}"
      }

      provider "supabase" {
         access_token = "${local.supabase_api_key}"
      }

      provider "cloudflare" {
         api_token = "${local.cloudflare_api_key}"
      }
EOF
}

# Configure Terragrunt to automatically store tfstate files in a GCS bucket

remote_state {
  backend = "gcs"

  config = {
    project  = local.remote_backend_project_id # The GCP project where the bucket will be created.
    location = local.remote_backend_gcp_region # The GCP location where the bucket will be created.
    bucket = "terragrunt-state-${local.remote_backend_project_id}" # (Required) The name of the GCS bucket. This name must be globally unique. For more information, see Bucket Naming Guidelines.
    prefix = "${path_relative_to_include()}/terraform.tfstate" #- (Optional) GCS prefix inside the bucket. Named states for workspaces are stored in an object called <prefix>/<name>.tfstate.
   }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(

  local.region_vars.locals,
  local.environment_vars.locals,
  local.project_vars.locals,
  
)