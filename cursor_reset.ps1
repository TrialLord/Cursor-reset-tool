# Cursor Trial Reset Tool
# This script helps reset the Cursor trial by removing relevant registry entries and files

# Create logs directory if it doesn't exist
$logDir = ".\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Setup logging
$logFile = Join-Path $logDir "cursor_reset_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
    Write-Host $Message
}

# Detect OS
$isWindows = $true  # Since we know this is running on Windows
$isMacOS = $false

Write-Log "Starting Cursor reset process..."
Write-Log "Operating System: Windows"

# Create backup function
function Backup-CursorData {
    param($Paths)
    $backupDir = ".\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Log "Creating backup in: $backupDir"

    foreach ($path in $Paths) {
        if (Test-Path $path) {
            $backupPath = Join-Path $backupDir (Split-Path $path -Leaf)
            Copy-Item -Path $path -Destination $backupPath -Recurse -Force
            Write-Log "Backed up: $path"
        }
    }
    return $backupDir
}

try {
    # Run as administrator check for Windows
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "Please run this script as Administrator" -ForegroundColor Red
        exit
    }

    # Define paths to backup
    $pathsToBackup = @(
        "$env:LOCALAPPDATA\Cursor",
        "HKCU:\Software\Cursor"
    )
    
    # Create backup
    $backupDir = Backup-CursorData -Paths $pathsToBackup

    # Stop Cursor processes with progress
    Write-Log "Stopping Cursor processes..."
    $processes = Get-Process | Where-Object { $_.Name -like "*cursor*" }
    if ($processes) {
        $processes | ForEach-Object {
            Write-Progress -Activity "Stopping Cursor processes" -Status $_.Name
            $_ | Stop-Process -Force
            Write-Log "Stopped process: $($_.Name)"
        }
    }

    # Remove registry entries
    Write-Log "Removing registry entries..."
    $regPaths = @(
        "HKCU:\Software\Cursor",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Cursor"
    )

    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            Write-Log "Removed: $path"
        }
    }

    # Remove local app data
    $appDataPath = "$env:LOCALAPPDATA\Cursor"
    if (Test-Path $appDataPath) {
        Write-Log "Removing Cursor app data..."
        Remove-Item -Path $appDataPath -Recurse -Force
        Write-Log "Removed app data from: $appDataPath"
    }

    # Clear Windows cache
    Write-Log "Clearing Windows cache..."
    Remove-Item -Path "$env:TEMP\Cursor*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:TEMP\cursor*" -Recurse -Force -ErrorAction SilentlyContinue

    # Verify cleanup
    Write-Log "`nVerifying cleanup..."
    $verificationFailed = $false
    
    if (Test-Path "$env:LOCALAPPDATA\Cursor") {
        Write-Log "Warning: Some Cursor data still exists" -ForegroundColor Yellow
        $verificationFailed = $true
    }

    if (-not $verificationFailed) {
        Write-Log "`nCursor trial has been reset successfully!" -ForegroundColor Green
        Write-Log "Backup created in: $backupDir" -ForegroundColor Cyan
        Write-Log "You can now start Cursor again with a fresh trial." -ForegroundColor Green
    }
    else {
        Write-Log "`nSome cleanup operations may have failed. Please check the log file for details." -ForegroundColor Yellow
        Write-Log "Log file location: $logFile" -ForegroundColor Cyan
    }
}
catch {
    Write-Log "An error occurred: $_" -ForegroundColor Red
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    Write-Log "Please check the log file for details: $logFile" -ForegroundColor Yellow
    exit 1
}
finally {
    Write-Progress -Activity "Cursor Reset" -Completed
}

# Keep the window open
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 