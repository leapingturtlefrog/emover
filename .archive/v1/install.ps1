#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Emover Installation Script for Windows/PowerShell

.DESCRIPTION
    Installs emover to your system. Can be run locally or via web install.

.EXAMPLE
    .\install.ps1
    Run locally

.EXAMPLE
    iwr -useb https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.ps1 | iex
    Install from GitHub
#>

$ErrorActionPreference = 'Stop'

$GITHUB_RAW_URL = "https://raw.githubusercontent.com/leapingturtlefrog/emover/main/emover.ps1"

# Determine installation directory
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    $INSTALL_DIR = "$env:LOCALAPPDATA\Programs\emover"
} elseif ($IsMacOS -or $IsLinux) {
    $INSTALL_DIR = "$HOME/.local/bin"
} else {
    $INSTALL_DIR = "$HOME/.local/bin"
}

Write-Host "Emover Installation" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation directory: $INSTALL_DIR"
Write-Host ""

# Create installation directory if it doesn't exist
if (-not (Test-Path $INSTALL_DIR)) {
    Write-Host "Creating directory: $INSTALL_DIR"
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}

Write-Host "Installing emover..."

# Check if we have the script locally
$scriptPath = if ($PSScriptRoot) { Join-Path $PSScriptRoot "emover.ps1" } else { "" }

if ($scriptPath -and (Test-Path $scriptPath)) {
    # Local installation
    Copy-Item -Path $scriptPath -Destination (Join-Path $INSTALL_DIR "emover.ps1") -Force
    Write-Host "Installed from local directory"
} else {
    # Download from GitHub
    Write-Host "Downloading from GitHub..."
    try {
        $destination = Join-Path $INSTALL_DIR "emover.ps1"
        Invoke-WebRequest -Uri $GITHUB_RAW_URL -OutFile $destination -UseBasicParsing
        Write-Host "Downloaded from GitHub"
    } catch {
        Write-Host "✗ Download failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

$installedScript = Join-Path $INSTALL_DIR "emover.ps1"
if (Test-Path $installedScript) {
    Write-Host "✓ Successfully installed emover to $INSTALL_DIR" -ForegroundColor Green
} else {
    Write-Host "✗ Installation failed" -ForegroundColor Red
    exit 1
}

# Check if install directory is in PATH
$pathVariable = if ($IsWindows -or $env:OS -eq "Windows_NT") { $env:Path } else { $env:PATH }
if ($pathVariable -notlike "*$INSTALL_DIR*") {
    Write-Host ""
    Write-Host "⚠ Warning: $INSTALL_DIR is not in your PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Add it to your PATH:"
    Write-Host ""

    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        Write-Host "  [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$INSTALL_DIR', 'User')" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or add it manually in System Properties > Environment Variables"
    } else {
        Write-Host "  export PATH=`"`$PATH:$INSTALL_DIR`"" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Add the above line to your shell config (~/.bashrc, ~/.zshrc, etc.)"
    }
} else {
    Write-Host ""
    Write-Host "You can now run:" -ForegroundColor Green
    Write-Host "  emover.ps1 -Help"
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Cyan
Write-Host "  .\emover.ps1                    # Process current directory"
Write-Host "  .\emover.ps1 -Directory ./src   # Process src directory"
Write-Host "  .\emover.ps1 -DryRun            # Preview changes"
Write-Host "  .\emover.ps1 -Help              # Show help"
