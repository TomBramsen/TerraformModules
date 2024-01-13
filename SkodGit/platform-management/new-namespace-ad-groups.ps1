$experience="hamlet"

$grp1="cluster-ns-lh-${experience}-prod-view"
$grp2="cluster-ns-lh-${experience}-prod-edit"
$grp3="cluster-ns-lh-${experience}-dev-view"
$grp4="cluster-ns-lh-${experience}-dev-edit"

$desc="Group for namespace ${experience}"

$neticOperationTeam="bb8ba447-0fb9-4df7-b8ad-3675bcec1d21"
$trifork="65250d01-dc78-46f6-a232-9966bffac561"


az ad group create --display-name $grp1 --mail-nickname $grp1 --description $desc
az ad group member add --group $grp1 --member-id $trifork

az ad group create --display-name $grp2 --mail-nickname $grp2 --description $desc
az ad group member add --group $grp2 --member-id $neticOperationTeam

az ad group create --display-name $grp3 --mail-nickname $grp3 --description $desc

az ad group create --display-name $grp4 --mail-nickname $grp4 --description $desc
az ad group member add --group $grp1 --member-id $neticOperationTeam
az ad group member add --group $grp1 --member-id $trifork


az ad group list --query "[?contains(displayName,'cluster-ns-lh-${experience}')].{displayName:displayName,id:id}"