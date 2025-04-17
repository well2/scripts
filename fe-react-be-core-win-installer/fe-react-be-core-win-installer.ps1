# =============================
# CONFIGURATION
# =============================
$domain = "www.example.com"                   # your domain
$siteName = "MyApp"
$appPoolName = "MyAppPool"
$basePath = "C:\inetpub\myapp"
$frontendPath = "$basePath\frontend"
$backendPath = "$basePath\backend"
$backendVirtualPath = "/api"                  # virtual path for backend API
$winAcmePath = "C:\Tools\win-acme\wacs.exe"   # path to Win-ACME CLI

# =============================
# INSTALL IIS (if missing)
# =============================
if (-not (Get-WindowsFeature -Name Web-Server).Installed) {
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
}

Import-Module WebAdministration

# =============================
# CREATE APP POOL
# =============================
if (-not (Get-WebAppPoolState -Name $appPoolName -ErrorAction SilentlyContinue)) {
    New-WebAppPool -Name $appPoolName
    Set-ItemProperty IIS:\AppPools\$appPoolName -Name managedRuntimeVersion -Value ""  # No managed runtime (.NET Core)
}

# =============================
# CREATE WEBSITE (FRONTEND as main site)
# =============================
if (-not (Test-Path "IIS:\Sites\$siteName")) {
    New-Website -Name $siteName -Port 80 -HostHeader $domain -PhysicalPath $frontendPath -ApplicationPool $appPoolName
    Write-Host "✅ Created website '$siteName' with domain $domain (frontend as main site)"
}

# =============================
# CREATE BACKEND API APP (/api)
# =============================
if (-not (Test-Path "IIS:\Sites\$siteName$backendVirtualPath")) {
    New-WebApplication -Site $siteName -Name "api" -PhysicalPath $backendPath -ApplicationPool $appPoolName
    Write-Host "✅ Created backend API web app at /api"
}

# =============================
# ADD MIME TYPES FOR REACT
# =============================
$mimeTypes = @{
    ".json" = "application/json"
    ".webmanifest" = "application/manifest+json"
    ".wasm" = "application/wasm"
    ".js" = "application/javascript"
    ".css" = "text/css"
    ".svg" = "image/svg+xml"
    ".map" = "application/json"
}
foreach ($ext in $mimeTypes.Keys) {
    if (-not (Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/staticContent/mimeMap[@fileExtension='$ext']" -name "." -ErrorAction SilentlyContinue)) {
        Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/staticContent" -name "." -value @{fileExtension=$ext; mimeType=$mimeTypes[$ext]}
    }
}

# =============================
# CREATE HOSTS FILE ENTRY (Optional for local use)
# =============================
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$entry = "127.0.0.1`t$domain"
if (-not (Select-String -Path $hostsPath -Pattern $domain -Quiet)) {
    Add-Content -Path $hostsPath -Value $entry
    Write-Host "✅ Added domain to hosts file: $domain"
}

# =============================
# SETUP HTTP BINDING
# =============================
if (-not (Get-WebBinding -Name $siteName -Protocol "http" | Where-Object { $_.bindingInformation -like "*:80:$domain" })) {
    New-WebBinding -Name $siteName -Protocol "http" -Port 80 -HostHeader $domain
    Write-Host "✅ Added HTTP binding for $domain"
}

# =============================
# WIN-ACME SSL CERTIFICATE SETUP
# =============================
if (-not (Test-Path $winAcmePath)) {
    Write-Error "❌ Win-ACME CLI not found at $winAcmePath. Download it from https://www.win-acme.com/ and extract it to the correct location."
    exit 1
}

Write-Host "🔐 Requesting SSL certificate via Win-ACME..."

& $winAcmePath --target iis --host $domain --siteid (Get-Website -Name $siteName).id --installation iis --validation http-01 --validationmode http-01 --accepttos --notaskscheduler --emailaddress "admin@$domain"

# =============================
# SETUP HTTPS BINDING
# =============================
$certThumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My |
    Where-Object { $_.Subject -like "*$domain*" } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1).Thumbprint

if ($certThumbprint) {
    if (-not (Get-WebBinding -Name $siteName -Protocol "https" | Where-Object { $_.bindingInformation -like "*:443:$domain" })) {
        New-WebBinding -Name $siteName -Protocol "https" -Port 443 -HostHeader $domain
        Push-Location IIS:\SslBindings
        New-Item "0.0.0.0!443!$domain" -Thumbprint $certThumbprint -SSLFlags 1
        Pop-Location
        Write-Host "✅ HTTPS binding added for $domain"
    } else {
        Write-Host "ℹ️ HTTPS binding for $domain already exists."
    }
} else {
    Write-Error "❌ Could not find SSL certificate for $domain"
}

Write-Host "🎉 Deployment complete. Your app is live at:"
Write-Host "🔗 Frontend: https://$domain/"
Write-Host "🔗 Backend API: https://$domain/api/"
