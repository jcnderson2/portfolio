#What this does: This script obtains ALL like domain addresses, inserts them all into one single variable, then runs a foreach loop to check against a CSV of UPNs you provide to see if they already exist. If they do, it exports them to a new CSV.
#We needed this script because we had an on-prem AD server as the source of truth(for entra) for users inside an ERP system. Entra will tell you if the users already exist, but not if you have to create the users in on-prem first :)

#CSV file should have a column named UPN with pyebarkerfs.com domain UPNs you wish to check in that columns rows
$importPath = "C:\path\to\users.csv"
$exportPath = "C:\path\to\existingaddresses.csv"
$domain = "domain.com" #Domain to filter for
$loginEmail = "your.email@domain.com" #Login email for Exchange Online

#Connect to Exchange Online and Microsoft Graph
try {
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
    Connect-ExchangeOnline -UserPrincipalName "$loginEmail" -ShowBanner:$false -ErrorAction Stop
} catch {
    Write-Error "Failed to connect: $_" -foregroundcolor red
    exit
}
Write-Host "Connected!" -ForegroundColor Green   

#Variable to hold CSV of UPNs to check with error handling
$sheet = Import-Csv -Path $importPath
if (-not ($sheet | Get-Member -Name "UPN" -MemberType NoteProperty)) {
    Write-Error "CSV must have a 'UPN' column."
    exit
}

#One HashSet variable to hold all like domain addresses
$ALLADDRESSES = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::CurrentCultureIgnoreCase)

#Fetch, filter and add all like domains to $ALLADDRESSES. Replacing any SMTP: or SIP: prefixes with nothing before adding.
$start = Get-Date
Write-Host "Fetching and filtering Exchange recipients with the specified domain (this may take a few minutes)..." -ForegroundColor Yellow
Get-Recipient -ResultSize Unlimited -ErrorAction Inquire | 
ForEach-Object {
    foreach ($address in $_.EmailAddresses) {
        if ($address -like "*@$domain") {
            $ALLADDRESSES.Add(($address.ToString() -replace "^([Ss][Mm][Tt][Pp]:|[Ss][Ii][Pp]:)", "")) | Out-Null
        }
    }
}
Write-Host "Completed fetch and filter in " -NoNewLine
Write-Host "$([math]::Round(((Get-Date) - $start).TotalSeconds, 2)) " -NoNewLine -ForegroundColor Green
Write-Host "seconds" -ForegroundColor Green

#Check CSV UPNs against $ALLADDRESSES
$existingUsers = New-Object System.Collections.ArrayList
$total = $sheet.Count
$i = 0
Write-Host "Checking for existing addresses..." -ForegroundColor Yellow

foreach ($row in $sheet) {
    $i++
    Write-Progress -Activity "Checking..." -Status "$i of $total" -PercentComplete (($i/$total)*100)
    if ($ALLADDRESSES.Contains($row.UPN)) {
        [void]$existingUsers.Add([PSCustomObject]@{
            UPN = "$row.UPN"
            Exists = "Yes"
        })
    }
}
Write-Progress -Activity "Checking..." -Completed

#Export list of already existing UPNs to CSV(if any exist) with error handling
try {
    if ($existingUsers.Count -gt 0) {
        $existingUsers | Export-Csv -Path $exportPath -NoTypeInformation
        Write-Host "$($existingUsers.Count) existing UPNs exported to $exportPath." -ForegroundColor Yellow
    }
    else {
        Write-Host "No existing UPNs found! :)" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to export CSV: $_"
} finally {
    Write-Host "Disconnecting from Exchange" -ForegroundColor Cyan
    Disconnect-ExchangeOnline -Confirm:$false
}
