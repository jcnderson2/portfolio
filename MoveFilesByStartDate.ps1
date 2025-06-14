
# WHAT THIS DOES
# This takes a start date and moves all files out of the users OneDrive(while keeping folder/file structure) if the files' modified by date is equal to or newer than the specified start date into a folder on their OneDrive Desktop called "MovedFiles"
# If you dont want to crawl the entire onedrive you can change line 21 to crawl a specific folder

# Define your start date
$startDate = Get-Date "2025-06-08"
$endDate = Get-Date

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Define source and destination paths using environment variables
$oneDrivePath = $env:OneDrive
if (-not $oneDrivePath) {
    Write-Error "OneDriveCommercial environment variable not found. Exiting script."
    exit
}

# Use entire OneDrive or specific subfolder
$sourcePath = $oneDrivePath
$destinationPath = Join-Path -Path $env:OneDrive -ChildPath "Desktop\MovedFiles"

# Make sure the destination exists
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}

# Step 1: Crawl folders with progress indicator
Write-Host "Scanning OneDrive..."
$directories = Get-ChildItem -Path $sourcePath -Recurse -Directory -Force

$totalDirs = $directories.Count
$currentDir = 0
$allFiles = @()

foreach ($dir in $directories) {
    $currentDir++
    $progressPercent = [math]::Round(($currentDir / $totalDirs) * 100)
    Write-Progress -Activity "Scanning Directories" -Status "Processing directory $currentDir of $totalDirs ($progressPercent%)" -PercentComplete $progressPercent

    # Get files in this directory
    $files = Get-ChildItem -Path $dir.FullName -File -Force | Where-Object {
        $_.LastWriteTime.Date -ge $startDate.Date -and $_.LastWriteTime.Date -le $endDate.Date
    }
    $allFiles += $files
}

Write-Host "File enumeration complete. Total matching files: $($allFiles.Count)."

# Step 2: Move files
$totalFiles = $allFiles.Count

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Substring($sourcePath.Length).TrimStart("\")
    $destinationFile = Join-Path -Path $destinationPath -ChildPath $relativePath
    $destinationDir = Split-Path -Path $destinationFile -Parent

    if (!(Test-Path -Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }
    try {
        Move-Item -Path $file.FullName -Destination $destinationFile -Force
    }
    catch {
        Write-Warning "Failed to move file: $($file.FullName). Error: $_"
    }
}

Write-Host "Move operation completed. Total files moved: $totalFiles."

