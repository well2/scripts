# Frontend React & Backend Core Installer

This PowerShell script automates the setup of an IIS environment for hosting a React frontend application with a backend API. It handles the complete configuration process including IIS installation, website creation, SSL certificate setup, and proper MIME type configuration.

## Overview

The `fe-react-be-core-installer.ps1` script performs the following tasks:

1. Installs IIS if not already installed
2. Creates an application pool for your application
3. Creates a website with the specified domain using the frontend as the main site
4. Sets up a backend API application under a virtual path
5. Configures MIME types required for React applications
6. Adds a local hosts file entry for development
7. Sets up HTTP binding
8. Obtains and installs an SSL certificate using Win-ACME
9. Configures HTTPS binding with the certificate

## Prerequisites

- Windows Server or Windows 10/11 with administrator privileges
- [Win-ACME](https://www.win-acme.com/) downloaded and extracted (for SSL certificate generation)
- Internet connection (for SSL certificate validation)

## Configuration

Before running the script, modify the following variables at the top of the script to match your requirements:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `$domain` | Your website domain name | www.example.com |
| `$siteName` | Name of the IIS website | MyApp |
| `$appPoolName` | Name of the IIS application pool | MyAppPool |
| `$basePath` | Base physical path for your application | C:\inetpub\myapp |
| `$frontendPath` | Physical path for frontend files | $basePath\frontend |
| `$backendPath` | Physical path for backend files | $basePath\backend |
| `$backendVirtualPath` | Virtual path for backend API application | /api |
| `$winAcmePath` | Path to Win-ACME executable | C:\Tools\win-acme\wacs.exe |

## Usage

1. Ensure you have administrator privileges
2. Edit the configuration section at the top of the script
3. Create the necessary directories for your application
4. Run the script in PowerShell:

```powershell
.\fe-react-be-core-installer.ps1
```

## Directory Structure

The script expects the following directory structure:

```
C:\inetpub\myapp\           # Or your custom $basePath
├── frontend\               # React application files
└── backend\                # Backend API files
```

## MIME Types

The script configures the following MIME types required for modern web applications:

- `.json` - application/json
- `.webmanifest` - application/manifest+json
- `.wasm` - application/wasm
- `.js` - application/javascript
- `.css` - text/css
- `.svg` - image/svg+xml
- `.map` - application/json

## SSL Certificate

The script uses Win-ACME to obtain a free Let's Encrypt SSL certificate. Make sure:

1. Your domain is publicly accessible for domain validation
2. Win-ACME is downloaded and extracted to the path specified in `$winAcmePath`
3. Port 80 is open for HTTP validation

## After Installation

After successful execution, your application will be accessible at:

- Frontend: https://yourdomain.com/
- Backend API: https://yourdomain.com/api/

## Troubleshooting

- **Win-ACME not found**: Ensure the path in `$winAcmePath` is correct
- **SSL certificate failure**: Check that your domain is publicly accessible and port 80 is open
- **Permission issues**: Make sure you're running PowerShell as Administrator
- **IIS module not found**: If you see errors about missing IIS modules, ensure IIS is properly installed

## Notes

- For local development, the script adds an entry to your hosts file
- The script is idempotent - it can be run multiple times without causing issues
- Existing configurations will not be modified if they already exist
