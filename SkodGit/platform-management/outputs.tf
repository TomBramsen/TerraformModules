output "admin_password" {
  value = random_password.localAdmin.result
  sensitive = true
}
