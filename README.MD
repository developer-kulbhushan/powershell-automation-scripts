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
```

---

### ✅ `pipadd.ps1`

Installs Python packages and automatically adds them to `requirements.txt`:

- Works just like `pip install`
- Avoids duplicates in the file
- Handles multiple packages
- Appends cleanly without extra line breaks

#### Optional One-Time Installer

Use `setup_pipadd_script.ps1` to make `pipadd` available globally:

```powershell
# Run this once
.\setup_pipadd_script.ps1

# Then use like this from any folder
pipadd pandas requests
```

---

### ✅ `pipremove.ps1`

Uninstalls Python packages and removes them from `requirements.txt`:

- Works just like `pip uninstall`
- Cleans up the exact dependency entry (e.g., `pandas==x.y.z`)
- Leaves other lines (comments or unrelated packages) intact

#### Optional One-Time Installer

Use `setup_pipremove_script.ps1` to make `pipremove` available globally:

```powershell
# Run this once
.\setup_pipremove_script.ps1

# Then use like this from any folder
pipremove pandas requests
```