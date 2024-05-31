output "AADGroup_Read_access_all" {
  value        = "61717ace-f72c-42ea-a077-d31c6958571"
  sensitive    = true
}

## Use ranges <> /31,/32
output "IP_Whitelist" { 
  value        = [  "5.186.57.8/30",
                    "20.242.182.32/28"
  ]
  sensitive    = false
}

output "parameter_2" {
  value        = "value_2"
  sensitive    = true
}
