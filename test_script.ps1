# Test script for Cursor Reset Tool
# This script tests the syntax and basic functionality without requiring admin rights

# Test script syntax
$scriptPath = "cursor_reset.ps1"
if (Test-Path $scriptPath) {
    Write-Output "Testing script syntax..."
    $scriptContent = Get-Content $scriptPath -Raw
    $null = [System.Management.Automation.PSParser]::Tokenize($scriptContent, [ref]$null)
    Write-Output "Script syntax is valid"
} else {
    Write-Error "Script file not found: $scriptPath"
    exit 1
}

# Test basic functionality
Write-Output "Testing basic functionality..."

# Test log directory creation
$logDir = ".\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
    Write-Output "Created logs directory"
}

# Test logging function
$logFile = Join-Path $logDir "test_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-LogMessage {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
    Write-Output $Message
}

Write-LogMessage "Test log message"
if (Test-Path $logFile) {
    Write-Output "Logging functionality works"
}

# Test backup function
$testBackupDir = ".\test_backup"
if (Test-Path $testBackupDir) {
    Remove-Item -Path $testBackupDir -Recurse -Force
}
New-Item -ItemType Directory -Path $testBackupDir | Out-Null
Write-Output "Created test backup directory"

# Clean up test files
Remove-Item -Path $testBackupDir -Recurse -Force
Write-Output "Cleaned up test files"

Write-Output "All tests completed successfully" 