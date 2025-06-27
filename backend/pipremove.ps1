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
