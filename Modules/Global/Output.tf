output "AADGroup_Read_access_all" {
  value        = "da191597-aea6-4904-b1d6-13f50adb80ab"
  sensitive    = true
}

output "IP_Whitelist" {
  value        = [  "5.186.57.10/32",
                   "152.115.186.200/29", 
               "20.242.182.32/28",
               "20.59.41.72/29",
               "62.199.211.144/28",
               "77.66.82.112/30",
               "92.62.194.140/30",  
  ]
  sensitive    = false
}

output "parameter_2" {
  value        = "value_2"
  sensitive    = true
}