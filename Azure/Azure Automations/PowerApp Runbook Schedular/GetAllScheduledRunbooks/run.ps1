using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Connecting to Azure with service principal
Write-Output "Creating the credential object for the service principal: $($env:APP_ID)"
$Credential = New-Object System.Management.Automation.PSCredential `
    -ArgumentList $env:SP_APP_ID, `
    (ConvertTo-SecureString $env:SP_APP_SECRET -AsPlainText -Force)

Write-Output "Connecting to Azure with service principal"
Connect-AzAccount -ServicePrincipal -TenantId $env:TENANT_ID -Credential $Credential

try {
    $Schedules = Get-AzAutomationSchedule `
        -ResourceGroupName "rg-test-automation" `
        -AutomationAccountName "aa-test-automation" | `
        Where-Object {$null -ne $_.NextRun} | `
        Select-Object Name, CreationTime, NextRun, TimeZone, Description | `
        ConvertTo-Json

        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = 200 # If the runbook doesn't exists then provide a 404 error
            Body = $Schedules
        })
}
catch {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = 500 # if the creation of the schedule failed, then provide a 500 error
        Body = "$($Error[0])"
    })
}