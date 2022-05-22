using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$body = $Request.Body # Saving request body into variable
$params = $Request.Params # Saving route parameter into variable

Write-Output "StartTime: $($body.StartTime)"
Write-Output "RunbookName: $($params.RunbookName)"

# Connecting to Azure with service principal
Write-Output "Creating the credential object for the service principal: $($env:APP_ID)"
$Credential = New-Object System.Management.Automation.PSCredential `
    -ArgumentList $env:SP_APP_ID, `
    (ConvertTo-SecureString $env:SP_APP_SECRET -AsPlainText -Force)

Write-Output "Connecting to Azure with service principal"
Connect-AzAccount -ServicePrincipal -TenantId $env:TENANT_ID -Credential $Credential


# Checking if the runbook exists
Write-Output "Checking that Runbook exists"
try {
    $Runbook = Get-AzAutomationRunbook `
        -ResourceGroupName $env:RESOURCE_GROUP `
        -AutomationAccountName $env:AUTOMATION_ACCOUNT `
        -Name $params.RunbookName
    Write-Output "Runbook found!"
}
catch {
    $Runbook = $false
}


# If the runbook exists, then create a new schedule
if($Runbook -ne $false) {
    # Scheduling the PowerShell Runbook in Azure
    # To Find your timezone you can use: ([System.TimeZoneInfo]::Local).Id
    $TimeZone = "Romance Standard Time" # Set the timezone for your environment
    $ScheduleId = "automation-" + (New-Guid).Guid.split("-")[0] #  Gives an id looking like: automation-b0736aa1

    try {
        Write-Output "Creating Runbook schedule with id: $($ScheduleId)"
        $output = New-AzAutomationSchedule `
            -AutomationAccountName $env:AUTOMATION_ACCOUNT `
            -Name $ScheduleId `
            -StartTime (Get-Date $body.StartTime) `
            -Description $body.Description `
            -OneTime `
            -ResourceGroupName $env:RESOURCE_GROUP `
            -TimeZone $TimeZone
        
        Write-Output "Registering the new schedule with a runbook"
        $Registration = Register-AzAutomationScheduledRunbook `
            -AutomationAccountName $env:AUTOMATION_ACCOUNT `
            -Parameters $body.Parameters `
            -RunbookName $Runbook.Name `
            -ScheduleName $ScheduleId `
            -ResourceGroupName $env:RESOURCE_GROUP
    }
    catch {
        Write-Error -Message "$($_)"
    }
}
else {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = 404 # If the runbook doesn't exists then provide a 404 error
        Body = "404 - Runbook: $($body.RunbookName), was not found"
    })
}


if($Registration) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = 201 # if the schedule was created then provide a 201 status code
        Body = $output | ConvertTo-Json
    })
}
else {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = 500 # if the creation of the schedule failed, then provide a 500 error
        Body = "$($Error[0])"
    })
}