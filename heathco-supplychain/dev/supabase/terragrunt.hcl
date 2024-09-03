
terraform {
   source = "../../../modules/supabase" # use module locally
}

include {
  path = find_in_parent_folders()
}

inputs = {
    
}