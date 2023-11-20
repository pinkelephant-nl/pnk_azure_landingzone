$domain = Get-ADDomain
$Customerroot = "OU=" + $domain.NetBIOSName + "," + $domain.DistinguishedName
$ouprotection = $false
$exist = Test-Path "AD:$Customerroot"

if (!($exist)){

    New-ADOrganizationalUnit -name $domain.NetBIOSName  -ProtectedFromAccidentalDeletion:$ouprotection

    $Domainroot = (GET-ADOrganizationalUnit -filter {name -like $domain.NetBIOSName}).DistinguishedName
    $searchroot = [adsi]"LDAP://$Domainroot"

    $RootOus = @("Accounts","AdminLevel","Contacts","Groups","Servers")
    $AccountsOUs = @("Disabled Users","Shared Mailbox","Standard Users","Test Users")
    $adminLevelOUs=  @("Admin Groups","Admin Users")
    $adminLevelUserOUs =  @("Admin Accounts","Service Accounts","Storage Accounts","Support Accounts")
    $adminAccountOUS = @("BeyondTrust")
    $supportAccountOUS = @("BeyondTrust")
    $GroupsOUs = @("Application Groups","Distribution Groups","FileSecurity Groups","License Groups","Mailbox Groups","Printer Groups","RBAC Groups","Security Groups")
    $ServersOUs = @("Application Servers","AVD Servers","Database Servers","File Servers","Management Servers","Print Servers","Security Servers")
    $AVDServersOUs = @("Prod","Test")


    foreach ($ou in $RootOus){
     New-ADOrganizationalUnit -name $ou -Path $Domainroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
     }

    $DomainAccountsroot  = (GET-ADOrganizationalUnit -filter {name -like "Accounts"} -SearchBase $Domainroot ).DistinguishedName
    $DomainAdminlevelroot  = (GET-ADOrganizationalUnit -filter {name -like "AdminLevel"} -SearchBase $Domainroot ).DistinguishedName
    $DomainComputersroot = (GET-ADOrganizationalUnit -filter {name -like "Computers"} -SearchBase $Domainroot ).DistinguishedName
    $DomainGroupsroot    = (GET-ADOrganizationalUnit -filter {name -like "Groups"} -SearchBase $Domainroot ).DistinguishedName
    $DomainServersroot   = (GET-ADOrganizationalUnit -filter {name -like "Servers"} -SearchBase $Domainroot ).DistinguishedName


    foreach ($ou in $AccountsOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainAccountsroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
     }

    foreach ($ou in $adminLevelOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainAdminlevelroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
     }

    foreach ($ou in $ComputersOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainComputersroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
     }

    foreach ($ou in $GroupsOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainGroupsroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
     }

    foreach ($ou in $ServersOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainServersroot -Confirm:$false  -ProtectedFromAccidentalDeletion:$ouprotection
     }

    $DomainAdminlevelUserroot  = (GET-ADOrganizationalUnit -filter {name -like "Admin Users"} -SearchBase $Domainroot ).DistinguishedName

    foreach ($ou in $adminLevelUserOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainAdminlevelUserroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
     }

    $DomainAdminlevelAccountsroot = (GET-ADOrganizationalUnit -filter {name -like "Admin Accounts"} -SearchBase $Domainroot ).DistinguishedName

    foreach ($ou in $adminAccountOUS){
     New-ADOrganizationalUnit -name $ou -Path $DomainAdminlevelAccountsroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
    }

    $DomainAdminlevelSupportAccountsroot = (GET-ADOrganizationalUnit -filter {name -like "Support Accounts"} -SearchBase $Domainroot ).DistinguishedName

    foreach ($ou in $supportAccountOUS){
     New-ADOrganizationalUnit -name $ou -Path $DomainAdminlevelSupportAccountsroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
    }

    $DomainAVDServersroot = (GET-ADOrganizationalUnit -filter {name -like "AVD Servers"} -SearchBase $Domainroot ).DistinguishedName

    foreach ($ou in $AVDServersOUs){
     New-ADOrganizationalUnit -name $ou -Path $DomainAVDServersroot -Confirm:$false -ProtectedFromAccidentalDeletion:$ouprotection
    }

}

else {

    $message = "OU folder " + $domain.NetBIOSName + " bestaat al. Het is niet mogelijk de structuur te maken"
    Write-host $message
    }




 <#

## Remove proctection on OU Folders 

$OUs = (Get-ADOrganizationalUnit -SearchBase "OU=in2aZUre,DC=intern,DC=in2azure,DC=nl" -Filter *)
foreach ($OU in $OUs) {
 Set-ADObject $OU -ProtectedFromAccidentalDeletion:$false -PassThru 
}

#>
