$ErrorActionPreference="Stop"
$repo="leapingturtlefrog/emover"
$arch=$env:PROCESSOR_ARCHITECTURE
if($arch -eq "AMD64"){$bin="emover-windows-x64.exe"}
else{Write-Host "Unsupported: $arch";exit 1}
$isAdmin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if($isAdmin){$dir="C:\Program Files\emover"}
else{$dir="$env:LOCALAPPDATA\emover"}
Write-Host "Installing emover to $dir..."
New-Item -ItemType Directory -Force -Path $dir|Out-Null
$url="https://github.com/$repo/releases/latest/download/$bin"
$dest=Join-Path $dir "emover.exe"
Invoke-WebRequest -Uri $url -OutFile $dest
$userPath=[Environment]::GetEnvironmentVariable("Path","User")
if($userPath -notlike "*$dir*"){
    [Environment]::SetEnvironmentVariable("Path","$userPath;$dir","User")
    $env:Path+=";$dir"
    Write-Host "Added to PATH"
}
Write-Host "Installed successfully!"
Write-Host ""
Write-Host "Usage:"
Write-Host "  emover                          # Remove emojis (asks confirmation)"
Write-Host "  emover -y .\src .\lib           # Auto-confirm, multiple dirs"
Write-Host "  emover file.txt src\ lib\test.rs # Specific files + directories"
