
$scope = "/subscriptions/0d7ee0d7-f9e4-4089-bcc1-f0cfeacb104c"
$ServicePrincipalName = "github-SP"
$servicePrincipal = (az ad sp create-for-rbac --name $ServicePrincipalName --years 150 --role owner --scopes $scope) | ConvertFrom-Json