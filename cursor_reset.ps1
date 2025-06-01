# Cursor Trial Reset Tool
# This script helps reset the Cursor trial by removing relevant registry entries and files

# Function to check and request admin rights
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Self-elevate the script if required
if (-not (Test-Admin)) {
    Write-Output "Requesting administrator privileges..."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Create logs directory if it doesn't exist
$logDir = ".\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Setup logging
$logFile = Join-Path $logDir "cursor_reset_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-LogMessage {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
    Write-Output $Message
}

# Detect OS
$isWindows = $true  # Since we know this is running on Windows
$isMacOS = $false

Write-LogMessage "Starting Cursor reset process..."
Write-LogMessage "Operating System: Windows"

# Create backup function
function Backup-CursorData {
    param($Paths)
    $backupDir = ".\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-LogMessage "Creating backup in: $backupDir"

    foreach ($path in $Paths) {
        if (Test-Path $path) {
            $backupPath = Join-Path $backupDir (Split-Path $path -Leaf)
            Copy-Item -Path $path -Destination $backupPath -Recurse -Force
            Write-LogMessage "Backed up: $path"
        }
    }
    return $backupDir
}

try {
    # Define paths to backup
    $pathsToBackup = @(
        "$env:LOCALAPPDATA\Cursor",
        "HKCU:\Software\Cursor"
    )
    
    # Create backup
    $backupDir = Backup-CursorData -Paths $pathsToBackup

    # Stop Cursor processes with progress
    Write-LogMessage "Stopping Cursor processes..."
    $processes = Get-Process | Where-Object { $_.Name -like "*cursor*" }
    if ($processes) {
        $processes | ForEach-Object {
            Write-Progress -Activity "Stopping Cursor processes" -Status $_.Name
            $_ | Stop-Process -Force
            Write-LogMessage "Stopped process: $($_.Name)"
        }
    }

    # Remove registry entries
    Write-LogMessage "Removing registry entries..."
    $regPaths = @(
        "HKCU:\Software\Cursor",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Cursor"
    )

    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            Write-LogMessage "Removed: $path"
        }
    }

    # Remove local app data
    $appDataPath = "$env:LOCALAPPDATA\Cursor"
    if (Test-Path $appDataPath) {
        Write-LogMessage "Removing Cursor app data..."
        Remove-Item -Path $appDataPath -Recurse -Force
        Write-LogMessage "Removed app data from: $appDataPath"
    }

    # Clear Windows cache
    Write-LogMessage "Clearing Windows cache..."
    Remove-Item -Path "$env:TEMP\Cursor*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:TEMP\cursor*" -Recurse -Force -ErrorAction SilentlyContinue

    # Verify cleanup
    Write-LogMessage "`nVerifying cleanup..."
    $verificationFailed = $false
    
    if (Test-Path "$env:LOCALAPPDATA\Cursor") {
        Write-LogMessage "Warning: Some Cursor data still exists"
        $verificationFailed = $true
    }

    if (-not $verificationFailed) {
        Write-LogMessage "`nCursor trial has been reset successfully!"
        Write-LogMessage "Backup created in: $backupDir"
        Write-LogMessage "You can now start Cursor again with a fresh trial."
    }
    else {
        Write-LogMessage "`nSome cleanup operations may have failed. Please check the log file for details."
        Write-LogMessage "Log file location: $logFile"
    }
}
catch {
    Write-LogMessage "An error occurred: $_"
    Write-LogMessage "Stack Trace: $($_.ScriptStackTrace)"
    Write-LogMessage "Please check the log file for details: $logFile"
    exit 1
}
finally {
    Write-Progress -Activity "Cursor Reset" -Completed
}

# Keep the window open
Write-Output "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 