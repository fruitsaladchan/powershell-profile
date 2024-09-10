# Function to install a package via winget or chocolatey if it's missing
function Install-PackageIfMissing {
    param (
        [string]$packageName,
        [string]$chocoPackageName = $packageName
    )

    if (-not (Get-Command $packageName -ErrorAction SilentlyContinue)) {
        Write-Host "$packageName is not installed. Installing $packageName..."
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install $packageName -e --silent
        } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install $chocoPackageName -y
        } else {
            Write-Error "Neither winget nor chocolatey is installed. Please install one of them."
        }
    } else {
        Write-Host "$packageName is already installed."
    }
}

# Ensure PowerShell 7 is installed
$pwsh7 = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwsh7) {
    Write-Host "PowerShell 7 is not installed. Installing PowerShell 7..."
    $installerUrl = "https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7.3.8-win-x64.msi"
    $msiPath = "$env:TEMP\pwsh7.msi"
    Invoke-WebRequest -Uri $installerUrl -OutFile $msiPath
    Start-Process msiexec.exe -ArgumentList "/i", $msiPath, "/quiet", "/norestart" -Wait
    Remove-Item $msiPath
    Write-Host "PowerShell 7 installed successfully."
} else {
    Write-Host "PowerShell 7 is already installed."
}

# Install the required dependencies
Write-Host "Installing required dependencies..."

# Install bat (a replacement for cat with syntax highlighting)
Install-PackageIfMissing -packageName "bat" -chocoPackageName "bat"

# Install fzf (fuzzy finder for interactive command-line filtering)
Install-PackageIfMissing -packageName "fzf" -chocoPackageName "fzf"

# Install zoxide (smarter cd command)
Install-PackageIfMissing -packageName "zoxide" -chocoPackageName "zoxide"

# Install oh-my-posh (prompt theme engine)
Install-PackageIfMissing -packageName "oh-my-posh" -chocoPackageName "oh-my-posh"

# Install eza (improved ls command)
Install-PackageIfMissing -packageName "eza" -chocoPackageName "eza"

# Install ripgrep (used for alias grep)
Install-PackageIfMissing -packageName "rg" -chocoPackageName "ripgrep"

# Install neovim (as the v and vim alias)
Install-PackageIfMissing -packageName "nvim" -chocoPackageName "neovim"

# Set PowerShell 7 as the default shell
$profilePath = "$HOME\Documents\WindowsPowerShell\profile.ps1"
if (-not (Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force
}

# Add pwsh to profile if it's not already set as the default
if (-not (Get-Content $profilePath | Select-String "pwsh")) {
    Add-Content -Path $profilePath -Value "Invoke-Expression '& pwsh'"
    Write-Host "Added PowerShell 7 as the default in your profile."
} else {
    Write-Host "PowerShell 7 is already set as the default shell."
}

# Initialize zoxide
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# Oh-my-posh configuration setup
$poshConfigPath = "$env:POSH_THEMES_PATH\catppuccin_mocha.omp.json"
if (Test-Path $poshConfigPath) {
    oh-my-posh init pwsh --config $poshConfigPath | Invoke-Expression
} else {
    Write-Warning "Oh My Posh configuration file not found: $poshConfigPath"
}

Write-Host "All dependencies have been installed and PowerShell 7 is now the default."
