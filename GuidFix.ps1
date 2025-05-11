# This script was created because when we took domains out of microsoft it would frequently change many users principle names to a random GUID format string. And when working with tools like BitTitan to migrate mailboxes, literally anything that WASNT a GUID was easy to work with.

#Change the domain on line 19
#Connect-mggraph -contextscope process -scopes "user.readwrite.all", "directory.readwrite.all"

# Retrieve all users from Microsoft Graph and select specific properties
Get-MgUser -all | Select-Object DisplayName, Id, UserPrincipalName | ForEach-Object {

    # Extract the prefix of the UPN
    $upnPrefix = $_.UserPrincipalName -split '@'[0]

    # Define the GUID string
    $guidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

    # Check if the UPN prefix matches the GUID pattern
    if ($upnPrefix -match $guidPattern) {

        # Take the accounts displayname and replace all spaces, parentheses and hyphens with dots and add the .onmicrosoft domain
        $newUPN = ((($_).DisplayName -replace '[\s,()-]+', '.') + '@domain.onmicrosoft.com').ToLower()

        # Update the user's UserPrincipalName in Microsoft Graph
        Update-MgUser -UserId $_.Id -UserPrincipalName $newUPN

        Write-Output "Updated UPN of $($_.Displayname), $($_.UserPrincipalName) to $newUPN"
    }
    else {
        Write-Output "No GUID found in UPN of ID: $($_.Id), DisplayName: $($_.Displayname)"
        return
    }
}