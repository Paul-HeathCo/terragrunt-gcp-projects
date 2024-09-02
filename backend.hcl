# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  remote_backend_gcp_region = "us-central1"
  remote_backend_project_id = "heathco-supplychain-bootstrap"
}
