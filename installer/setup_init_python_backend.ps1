# Define target script directory
$scriptDir = "$HOME\Scripts"
$scriptPath = "$scriptDir\init_python_backend.ps1"

# 1. Create script directory if it doesn't exist
if (!(Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir | Out-Null
    Write-Host "Created $scriptDir"
}

# 2. Create init_python_backend.ps1
@'
Write-Host "Initializing Python backend in: $(Get-Location)"

# Step 1: Create venv if not exists
if (!(Test-Path "venv")) {
    Write-Host "Creating virtual environment..."
    python -m venv venv
} else {
    Write-Host "Virtual environment already exists."
}

# Step 2: Create requirements.txt if not exists
if (!(Test-Path "requirements.txt")) {
    "# Add your dependencies here" | Out-File "requirements.txt" -Encoding utf8
    Write-Host "Created requirements.txt"
} else {
    Write-Host "requirements.txt already exists."
}

# Step 3: Activate venv and install packages
& ".\venv\Scripts\activate.ps1"
pip install -r requirements.txt
Write-Host "Dependencies installed."

# Step 4: Create .gitignore if not exists
if (!(Test-Path ".gitignore")) {
@"
venv/
__pycache__/
*.pyc
.vscode/
.env
"@ | Out-File ".gitignore" -Encoding utf8
    Write-Host "Created .gitignore"
} else {
    Write-Host ".gitignore already exists."
}

# Step 5: Create .env if not exists
if (!(Test-Path ".env")) {
@"
# Example environment variables
ENV=development
PORT=8000
DEBUG=True
DATABASE_URL=sqlite:///./app.db
"@ | Out-File ".env" -Encoding utf8
    Write-Host "Created .env file"
} else {
    Write-Host ".env file already exists."
}

Write-Host ""
Write-Host "Python backend is ready. Virtual environment is activated."
Write-Host "You can now start working in this environment."
'@ | Out-File $scriptPath -Encoding utf8

Write-Host "Created script at $scriptPath"

# 3. Add the script folder to PATH (user scope)
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if ($existingPath -notlike "*$scriptDir*") {
    $newPath = "$existingPath;$scriptDir"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added $scriptDir to User PATH"
} else {
    Write-Host "$scriptDir already in PATH"
}

Write-Host "Setup complete! You can now run 'init_python_backend.ps1' from any folder."
Write-Host "Please restart your terminal or VS Code to use the new PATH."

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")