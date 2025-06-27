# ⚙️ powershell-automation-scripts

A growing collection of reusable PowerShell scripts to automate common development, environment setup, and system tasks on Windows.

This is your one-stop toolbox for fast, repeatable automation — whether you're bootstrapping a project, managing environments, or scripting repetitive tasks.

---

## 📦 Available Scripts

### ✅ `init_python_backend.ps1`

Bootstraps a new Python backend project in seconds:

- Creates a virtual environment (`venv/`)
- Adds `requirements.txt`, `.gitignore`, `.env` if missing
- Installs dependencies from `requirements.txt`
- Activates the environment

Use this when starting any new Python backend folder.

#### Optional One-Time Installer

Use `setup_init_python_backend.ps1` to install the script globally (adds to your PATH):

```powershell
# Run this once
.\setup_init_python_backend.ps1

# Then use from any folder
init_python_backend.ps1