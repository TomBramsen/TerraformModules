output "AADGroup_Read_access_all" {
  value        = "da191597-aea6-4904-b1d6-13f50adb80ab"
  sensitive    = true
}

## Use ranges <> /31,/32
output "IP_Whitelist" { 
  value        = [  "5.186.57.10/30",
                    "20.242.182.32/28"
  ]
  sensitive    = false
}

output "parameter_2" {
  value        = "value_2"
  sensitive    = true
}