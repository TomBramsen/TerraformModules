output "AADGroup_Read_access_all" {
  value     = "da191597-aea6-4904-b1d6-13f50adb80ab"
  sensitive = true
}

output "IP_Whitelist" {
  value     = [ "3.3.3.3", "4.4.4.4", "5.186.57.10"]
  sensitive = false
}

output "parameter_2" {
  value     = "value_2"
  sensitive = true
}