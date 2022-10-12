# Powershell script that creates ADFS 2019 Application Group for OIDC
# Anthos Identity Service can use this for authentication
# https://cloud.google.com/anthos/identity/setup/provider
#
# originally based on: https://github.com/mikefoley/ADFS-cmdlets/blob/master/GitHub-ADFS-Add-App-Group.ps1
#
# 'ClientRoleIdentifier' name of ADFS application group
param([String]$ClientRoleIdentifier="anthos",[String]$relyingPartyName="anthos-rp",[String]$relyingPartyID="token-groups-claim")

if (get-adfsapplicationgroup -Name $ClientRoleIdentifier) {
  write-host "SKIP New-AdfsApplicationGroup '$ClientRoleIdentifier'"
}else {	
  # Create the new Application Group in ADFS
  New-AdfsApplicationGroup -Name $ClientRoleIdentifier -ApplicationGroupIdentifier $ClientRoleIdentifier
}

#Create the ADFS Server Application and generate the client secret.
$ADFSApp = Get-AdfsServerApplication -Name "$ClientRoleIdentifier - Server app"
if ($ADFSApp) {
  write-host "SKIP New-AdfsApplicationGroup '$ClientRoleIdentifier - Server app'"
  $identifier = $ADFSApp.identifier
}else {	
  # Creates a new GUID for use by the application group
  $identifier = (New-Guid).Guid
  $ADFSApp = Add-AdfsServerApplication -Name "$ClientRoleIdentifier - Server app" -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri @("https://console.cloud.google.com/kubernetes/oidc","http://localhost:3001/callback") -Identifier $identifier -GenerateClientSecret
}  
write-host "client_id = $identifier"

if (Get-AdfsRelyingPartyTrust -Name $relyingPartyName) {
	write-host "SKIP Add-AdfsRelyingPartyTrust '$relyingPartyName'"
}else {
  #Create the relying party trust
  Add-AdfsRelyingPartyTrust -Name $relyingPartyName -Identifier @($relyingPartyID)
}  


$transformrule = @"
@RuleTemplate = "LdapClaims"
@RuleName = "groups"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/claims/Group"), query = ";tokenGroups(domainQualifiedName);{0}", param = c.Value);
"@

# Write out the tranform rules file
$transformrule |Out-File -FilePath .\issueancetransformrules.tmp -force -Encoding ascii
$relativePath = Get-Item .\issueancetransformrules.tmp
Set-AdfsRelyingPartyTrust -Name $relyingPartyName -TargetIdentifier $relyingPartyID -IssuanceTransformRulesFile $relativePath
Remove-Item $relativePath

# Grant permission to application
Grant-ADFSApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $relyingPartyID -ScopeName "allatclaims", "openid"

Write-Host ""
$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
Write-Host "OpenID URL: " $openidurl.FullUrl.OriginalString
Write-Host "client_id: $identifier"
if ([string]::IsNullOrEmpty($ADFSApp.ClientSecret)) {
  Write-Host "<cannot fetch, recreate if necessary>"
}else {
  Write-Host -ForegroundColor Yellow "client_secret: "$($ADFSApp.ClientSecret)
}  

