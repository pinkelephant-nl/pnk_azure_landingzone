Function AVD_Prepare
{
az account set --subscription $($parameter.subscriptionidlz.value)
$hostPoolName               = ($parameter.customerid.value) +'-RemoteAppHP'
$workSpaceName              = "ws-avd-prod-001"

function InstallProvider($Provider)
{
if ((az provider show --namespace $provider --query "registrationState =='Registered'") -eq $false) {write-host Installing $provider ; az provider register --namespace $provider --wait }
}

function HostPool
{
<# Creating RG  #>
    write-host check "Creating RG" ; az group create --name $hostpoolRG --location $location --output none

   while (!(az group show --name $hostpoolRG --query "[provisioningState =='Succeeded']")) {
     write-host -n "."
     start-sleep 2

}
write-host check "Creating Hostpool" ; az desktopvirtualization hostpool create --name $hostPoolName  --host-pool-type $pooltype --load-balancer-type $LoadbalanceType --max-session-limit 999999 --resource-group $hostpoolRG --location $location --personal-desktop-assignment-type "Automatic" --output none

while (!(az desktopvirtualization hostpool show --name $hostPoolName --resource-group $hostpoolRG --query "[name =='$hostPoolName']")) {
    write-host -n "."
    start-sleep 2
}

$armpath = (az desktopvirtualization hostpool show --name $hostPoolName  --resource-group $hostpoolRG --query "[id]")[1].trim()
write-host check "Creating Hostpool Applicationgroup" ;az desktopvirtualization applicationgroup create  --location $location --application-group-type desktop   --name ($($parameter.customerid.value.ToLower()) +'-RemoteAppHP-DAG') --resource-group $hostpoolRG --host-pool-arm-path $armpath --friendly-name ($($parameter.customerid.value.ToLower()) +'RemoteApp') --output none
write-host check "Creating Hostpool Applicationgroup" ;az desktopvirtualization applicationgroup create  --location $location --application-group-type remoteApp --name ($($parameter.customerid.value.ToLower()) +'-RemoteAppHP-AG' ) --resource-group $hostpoolRG --host-pool-arm-path $armpath --friendly-name ($($parameter.customerid.value.ToLower()) +'Desktop'  ) --output none
}

function ConfigureRequirements
{

<# Register VirtualMachineTemplatePreview under VirtualMachineImages ProviderFeature #>
    write-host "Installing Microsoft.VirtualMachineTemplate" ; az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview --output none

   while (!(az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview --query "[properties.state =='Registered']")) {
     write-host -n "."
     start-sleep 2

}

}

function create_AVDworkspace
{
$hostpoolRG                 = $($parameter.customerid.value.ToLower()) +'-lz-' +$($parameter.customerid.value.ToLower()) +'-avd-prd-001'

az desktopvirtualization workspace create --name $workSpaceName `
                                          --resource-group (($parameter.customerid.value) +'-lz' +'-' +($parameter.customerid.value)  +'-avd' +'-prd-001') `
                                          --application-group-references (az desktopvirtualization hostpool show --name $hostPoolName  --resource-group $hostpoolRG  | ConvertFrom-Json).applicationGroupReferences `
                                          --friendly-name ('Workspace ' +$($parameter.customerFullName.value)) `
                                          --location $location                                          
                                   
}

HostPool
ConfigureRequirements

<# Register Provider Feature(s) #>
InstallProvider -Provider Microsoft.Network
InstallProvider -Provider Microsoft.VirtualMachineImages
az provider register -n Microsoft.VirtualMachineImages
InstallProvider -Provider Microsoft.Storage
InstallProvider -Provider Microsoft.Compute
InstallProvider -Provider Microsoft.Keyvault

create_AVDworkspace

}
