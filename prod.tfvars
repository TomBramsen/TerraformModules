environment = "prod"


 tags = {
    environment  = "Prod"
    owner        = "LH"
    autodelete   = "false"
  } 


// Remove this block, when ready to scale back to S0
databases =  [
      {
   name                     = "kvsatest329d95xlx"
      size                     = 50
      retention_enabled        = false
      sku_name                 = "S1"
      backup_interval_in_hours = 24
      monthly_retention        = "P3M"
      week_of_year             = 1
      weekly_retention         = "P4W"
      yearly_retention         = "PT0S"
      }
]
