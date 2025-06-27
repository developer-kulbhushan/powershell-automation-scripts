# Define script directory and pipremove.ps1 path
$scriptDir = "$HOME\Scripts"
$pipremovePath = "$scriptDir\pipremove.ps1"

# 1. Create the script directory if it doesn't exist
if (!(Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
}

# 2. Write pipremove.ps1 to the script folder
@'
if ($args.Count -eq 0) {
    Write-Error "Please provide at least one package name to uninstall"
    exit 1
}

# Step 1: Uninstall all requested packages
pip uninstall @args -y

# Step 2: Setup requirements.txt path
$reqPath = "requirements.txt"

if (!(Test-Path $reqPath)) {
    Write-Host "requirements.txt does not exist. Nothing to update."
    exit 0
}

# Step 3: Normalize package names
$toRemove = $args | ForEach-Object { ($_ -split '[=<>!]')[0].ToLower() }

# Step 4: Read and filter requirements.txt
$lines = Get-Content $reqPath
$filteredLines = @()

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ($trimmed -eq "" -or $trimmed.StartsWith("#")) {
        $filteredLines += $line
        continue
    }

    $pkgName = ($trimmed -split '[=<>!]')[0].ToLower()
    if ($toRemove -contains $pkgName) {
        Write-Host "Removed from requirements.txt: $trimmed"
    } else {
        $filteredLines += $line
    }
}

# Step 5: Overwrite requirements.txt with filtered lines
Set-Content -Path $reqPath -Value $filteredLines -Encoding UTF8
'@ | Out-File -FilePath $pipremovePath -Encoding UTF8 -Force

Write-Host "Created pipremove.ps1 at $pipremovePath"

# 3. Add $scriptDir to PATH (user scope), replacing if already exists
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$paths = $existingPath -split ';' | Where-Object { $_ -and ($_ -ne $scriptDir) }
$paths += $scriptDir
$newPath = ($paths -join ';').TrimEnd(';')
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "Updated user PATH to include $scriptDir"

# 4. Add or replace pipremove function in PowerShell profile
$profilePath = $PROFILE
if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# Remove previous pipremove function if it exists
$content = Get-Content $profilePath -Raw
$content = $content -replace 'function pipremove\s*\{[^}]+\}', ''

# Append new function definition
$content += @"
function pipremove {
    & '$pipremovePath' @args
}
"@

Set-Content -Path $profilePath -Value $content -Encoding UTF8

Write-Host "Updated PowerShell profile at $profilePath"
Write-Host "Setup complete. Restart your terminal or run `. $PROFILE` to use 'pipremove'."
