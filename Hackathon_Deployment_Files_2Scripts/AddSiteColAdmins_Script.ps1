
# -------------------------------------------------------------------------------
# Variable Section - IMPORTANT: Only modify values within this section
# -------------------------------------------------------------------------------
$tenantName       = Read-Host "Please enter the tenant name (e.g. MOD123456x)"
$admin            = Read-Host "Please enter the admin account (e.g. admin@MOD123456x.onmicrosoft.com)"
# -------------------------------------------------------------------------------
# END of Variable Section
# -------------------------------------------------------------------------------

# Setting initial values based on user input
$adminCenterURL   = "https://$tenantName-admin.sharepoint.com"

# Store credentials
$Global:cred = Get-Credential -UserName $admin -Message "Please, enter the password"

# Connecting to Azure
Write-Host "`nConnecting to Azure" -ForegroundColor Cyan
Write-Host "`tFetching users`n" -ForegroundColor Gray
Connect-AzureAD -Credential $Global:cred | Out-Null
$users = Get-AzureADUser -Filter "startswith(userPrincipalName,'user')" | Sort-Object -Property userPrincipalName | Select UserPrincipalName

# Connecting to SPO
Write-Host "`nConnecting to SPO" -ForegroundColor Cyan
Connect-SPOService -Url $adminCenterURL -Credential $Global:cred
$sites = Get-SPOSite -Filter {Url -like "sharepoint.com/sites/ContosoElectronics" } | Sort-Object -Property Url | Select Url

#If ($sites.count -eq $users.count){
    $index = 0
    Foreach($site in $sites){
        Write-Host "** Site Collection: '$($site.Url)'"
        $newAdmin = $users[$index].UserPrincipalName
        Write-Host "`tSetting user '$newAdmin' as site collection admin" -ForegroundColor Gray
        try
        {
            Set-SPOUser -Site $site.Url -LoginName $newAdmin -IsSiteCollectionAdmin $true | Out-Null
            Write-Host "`tSuccess!`n" -ForegroundColor Green
        }
        catch
        {
            write-host "`tError: $($_.Exception.Message)`n" -foregroundcolor Red
        }
        finally
        {
            $index++
        }
    }
#}


Disconnect-AzureAD
Disconnect-SPOService


