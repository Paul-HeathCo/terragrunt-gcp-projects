output "supabase_db_password" {
  value = random_password.supabase_password.result
  sensitive = true
}

output "supabase_project_id" {
  value = supabase_project.project.id
 
}