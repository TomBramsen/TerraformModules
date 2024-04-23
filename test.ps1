
$ARM_SUBSCRIPTION_ID="ca91e8c9-d124-43fc-afe8-dfad04dcbd93" 
$ARM_TENANT_ID="1b3b25cd-2fb6-4f73-a6f7-c2fc0178ce5d" 

## Create storage account for manual Terraform deployments
$TerraformStorageSub = $ARM_SUBSCRIPTION_ID
$TerraformStorageRSG = "TerraformShared"
$TerraformStorageName="terraformtbr0001"
$TerraformStorageContainer =  "terraform"

az login --tenant  $ARM_TENANT_ID
az account set --subscription $TerraformStorageSub 

# Create resource group
az group create --name $TerraformStorageRSG --location "North Europe"

# Create storage account
az storage account create --resource-group $TerraformStorageRSG --name $TerraformStorageName --sku Standard_LRS --encryption-services blob

# Get storage account key
$ACCOUNT_KEY=$(az storage account keys list --resource-group $TerraformStorageRSG --account-name $TerraformStorageName --query [0].value -o tsv)

#
write-host "Set up backend.tf/azurerm with "
write-host "  resource_group_name:" $TerraformStorageRSG
write-host "  storage_account_name:" $TerraformStorageName
write-host "  container_name:" $TerraformStorageContainer
write-host "  key:" $ACCOUNT_KEY




## SP for ACR, Management
$ServicePrincipalName = "acr-management-pull-SP"
az ad sp create-for-rbac --name $ServicePrincipalName --years 150 --role acrpull --scopes /subscriptions/$ARM_SUBSCRIPTION_ID
$ServicePrincipalName = "acr-management-push-SP"
#az ad sp create-for-rbac --name $ServicePrincipalName --years 150 --role acrpush --scopes /subscriptions/$ARM_SUBSCRIPTION_ID/rg-mgmt-management-neu/providers/Microsoft.ContainerRegistry/registries/lhacrmgmtneu

# SP For Keyvault, Management
$ServicePrincipalName = "kv-management-read-SP"
$kv_mgmt = (az ad sp create-for-rbac --name $ServicePrincipalName )


##  Create service principal and give it Contributor on subscription
$subscriptionName = "Cluster-Dev"
$ServicePrincipalName = "sub-"+$subscriptionName+"-SP"
$sub = az account list --query "[?name=='${subscriptionName}'].{id:id}"  
$sub_id = ($sub | convertfrom-json).id

$sp = (az ad sp create-for-rbac --name $ServicePrincipalName --years 150 --role Contributor --scopes /subscriptions/$sub_id)
$sp_id = ($sp | convertfrom-json).appId


az role assignment create --assignee-object-id "${sp_id}"  --assignee-principal-type "ServicePrincipal" `
  --role "Contributor"   --scope "/subscriptions/${sub_id}"

write-host "Service principal on $subscriptionName created: `n " 
$sp


$scope = "/subscriptions/ca91e8c9-d124-43fc-afe8-dfad04dcbd93"
$ServicePrincipalName = "github-SP"
$servicePrincipal = (az ad sp create-for-rbac --name $ServicePrincipalName --years 150 --role owner --scopes $scope) | ConvertFrom-Json