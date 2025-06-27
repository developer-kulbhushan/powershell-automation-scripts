if ($args.Count -eq 0) {
    Write-Error "Please provide at least one package name (e.g., pandas numpy)"
    exit 1
}

# Step 1: Install the packages
pip install @args

# Step 2: Setup requirements.txt path
$reqPath = "requirements.txt"

# Create file if it doesn't exist
if (!(Test-Path $reqPath)) {
    New-Item -ItemType File -Path $reqPath -Force | Out-Null
}

# Step 3: Read existing lines safely
$lines = [System.IO.File]::ReadAllLines($reqPath)
$lines = $lines | ForEach-Object { $_.TrimEnd() }

# Step 4: Detect if the file ends with a newline
$rawContent = Get-Content $reqPath -Raw
$hasTrailingNewline = $false
if ($rawContent) {
    $hasTrailingNewline = $rawContent.EndsWith("`r`n") -or $rawContent.EndsWith("`n")
}

# Step 5: Build case-insensitive hashset of existing entries
$existingSet = @{}
foreach ($line in $lines) {
    if ($line -ne "") {
        $existingSet[$line.ToLower()] = $true
    }
}

# Step 6: Collect new entries
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

# Step 7: Combine all lines
$finalLines = @()
$finalLines += $lines
$finalLines += $newEntries

# Step 8: Write clean output (1 line per entry, no gaps, no trailing blank lines)
Set-Content -Path $reqPath -Value $finalLines -Encoding UTF8