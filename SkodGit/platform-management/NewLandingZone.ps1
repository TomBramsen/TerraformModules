## Create new subscription etc for new Experience
## https://legohouse.atlassian.net/wiki/spaces/LHTR/pages/240582685/New+Landing+Zone+New+Experience

$subscriptionName = "ExperienceHub-Prod"
$managementGroup  = "2dacdfd3-3ed7-4397-a7d5-b79e5a1e0af3"  # Prod
$terraformStorageNumber = "002" # Must be unique so look for existing storages in the portal and set number accordingly

## Find name from displayname with
## az account management-group list --query "[?contains(displayName,'Dev')].{name:name,displayName:displayname}"


##
## Take first subscription with displayname = XSP...
## Rename subscription and place in correct Management Group
##
$sub=(az account list  --refresh  --query "[?contains(name,'XSP')].{id:id, name:name}[0].{id:id, name:name}" --all)| ConvertFrom-Json 

if($sub.Count -gt 0) {
    write-host "Renaming in 10 secs..."
    write-host $sub.id
    write-host $sub.name
    start-sleep 10
    az account subscription rename --subscription-id $sub.id --name $subscriptionName
    az account management-group subscription add --name $managementGroup --subscription $sub.id
}

##
## Create AD Groups and assign to Subscription
##
$GroupReader      = "Sub-"+$subscriptionName +"-Reader"
$GroupContributor = "Sub-"+$subscriptionName +"-Contributor"
 
$Desc = "Gives access to the Subscription '"  + $sub + "' in Azure"

$grp_reader      = (az ad group create --display-name $GroupReader --mail-nickname $GroupReader --description $Desc) | convertfrom-json
$grp_contributor = (az ad group create --display-name $GroupContributor --mail-nickname $GroupContributor --description $Desc) | ConvertFrom-Json 

## Needs a little time to get groups created...
Start-Sleep 15

$scope = "/subscriptions/" +$sub.id
az role assignment create --assignee-object-id $grp_reader.Id --role "Reader" --assignee-principal-type Group --scope $scope  
az role assignment create --assignee-object-id $grp_contributor.Id --role "Contributor" --assignee-principal-type Group --scope $scope


## 
## Create service principal and assign it contributor
## Create container in management and give this SP access
##

# Create SP for subscription.  To be used for Github Actions   
# - - To do : import secrets into Github Action Secrets
$ServicePrincipalName = "sub-"+$subscriptionName+"-dev-SP"
$servicePrincipal = (az ad sp create-for-rbac --name $ServicePrincipalName --years 150 --role Contributor --scopes $scope) | ConvertFrom-Json

$SecretName = $ServicePrincipalName+"-id"
az keyvault secret set --vault-name "keyvault-management-neu" --name $SecretName --value $servicePrincipal.appId
$SecretName = $ServicePrincipalName+"-secret"
az keyvault secret set --vault-name "keyvault-management-neu" --name $SecretName --value $servicePrincipal.password

# Add SP to the AAD group for all subscriptions SP : sub-All-experience-SP
# The id we pull here, is not the same as appid on the $servicePrincipal variable!
$principal_id = (az ad sp list --display-name $ServicePrincipalName --query [].id ) | convertfrom-json
az ad group member add --group "sub-All-experience-SP" --member-id $principal_id


# Create terraform container in management subscription
$TerraformStorageSub = "b2b43e30-7abd-4d22-80be-cbf9bebd9ac1"  ## Management
$TerraformStorageRSG = "TerraformShared"
$TerraformStorageName="terraformlh"+$terraformStorageNumber
$TerraformStorageContainer =  $subscriptionName.ToLower()

az account set --subscription  $TerraformStorageSub

$ACCOUNT_KEY=$(az storage account keys list --resource-group $TerraformStorageRSG --account-name $TerraformStorageName --query [0].value -o tsv)
az storage container create --name $TerraformStorageContainer --account-name $TerraformStorageName --account-key $ACCOUNT_KEY

# Assign 'Storage Account Key Operator Service Role' to Storage account for new subscription, so it can use it as Terraform Storage
$StorageAcc = "/subscriptions/b2b43e30-7abd-4d22-80be-cbf9bebd9ac1/resourceGroups/TerraformShared/providers/Microsoft.Storage/storageAccounts/terraformlh002"
az role assignment create --assignee $servicePrincipal.appId --role "Storage Account Key Operator Service Role"  --scope $StorageAcc  
