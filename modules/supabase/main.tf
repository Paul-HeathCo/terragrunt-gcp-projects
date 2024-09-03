
resource "random_password" "supabase_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "supabase_project" "project" {
  organization_id   = "mxzqkcbcgndyeoclxbxp"
  name              = "heathco-supplychain-${var.environment}"
  database_password = random_password.supabase_password.result
  region            = "us-east-2"
  lifecycle {
    ignore_changes = [database_password]
  }
}
