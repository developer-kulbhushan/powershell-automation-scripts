# Define script folder and pipadd.ps1 path
$scriptDir = "$HOME\Scripts"
$pipaddPath = "$scriptDir\pipadd.ps1"

# Create script directory if it doesn't exist
if (!(Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
}

# Write pipadd.ps1 to the script folder
@'
if ($args.Count -eq 0) {
    Write-Error "Please provide at least one package name (e.g., pandas numpy)"
    exit 1
}

pip install @args

$reqPath = "requirements.txt"

if (!(Test-Path $reqPath)) {
    New-Item -ItemType File -Path $reqPath -Force | Out-Null
}

$lines = [System.IO.File]::ReadAllLines($reqPath)
$lines = $lines | ForEach-Object { $_.TrimEnd() }

$rawContent = Get-Content $reqPath -Raw
$hasTrailingNewline = $false
if ($rawContent) {
    $hasTrailingNewline = $rawContent.EndsWith("`r`n") -or $rawContent.EndsWith("`n")
}

$existingSet = @{}
foreach ($line in $lines) {
    if ($line -ne "") {
        $existingSet[$line.ToLower()] = $true
    }
}

$newEntries = @()
foreach ($pkg in $args) {
    $pkgName = ($pkg -split '[=<>!]')[0]
    $version = pip show $pkgName 2>$null | Where-Object { $_ -match '^Version:' } | ForEach-Object { ($_ -split ':\s*')[1] }

    if ($version) {
        $entry = "$pkgName==$version"
        if (-not $existingSet.ContainsKey($entry.ToLower())) {
            $newEntries += $entry
            Write-Host "Added to requirements.txt: $entry"
        } else {
            Write-Host "Already in requirements.txt: $entry"
        }
    } else {
        Write-Host "Package '$pkgName' not found or failed to install"
    }
}

$finalLines = @()
$finalLines += $lines
$finalLines += $newEntries

Set-Content -Path $reqPath -Value $finalLines -Encoding UTF8
'@ | Out-File -FilePath $pipaddPath -Encoding UTF8 -Force

Write-Host "Created pipadd.ps1 at $pipaddPath"

# Add $scriptDir to PATH (user scope), replace if already exists
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$paths = $existingPath -split ';' | Where-Object { $_ -and ($_ -ne $scriptDir) }
$paths += $scriptDir
$newPath = ($paths -join ';').TrimEnd(';')
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "Updated user PATH to include $scriptDir"

# Add or replace pipadd function in PowerShell profile
$profilePath = $PROFILE

if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# Remove previous pipadd definition if exists
$content = Get-Content $profilePath -Raw
$content = $content -replace 'function pipadd\s*\{[^}]+\}', ''

# Append new function definition
$content += @"
function pipadd {
    & '$pipaddPath' @args
}
"@

Set-Content -Path $profilePath -Value $content -Encoding UTF8

Write-Host "Updated PowerShell profile at $profilePath"
Write-Host "Setup complete. Restart your terminal or run `. $PROFILE` to use 'pipadd'."
