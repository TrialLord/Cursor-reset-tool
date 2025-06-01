@echo off
echo Starting Cursor Reset Tool...
echo.

:: Check if PowerShell is available
where powershell >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: PowerShell is not installed or not in PATH
    pause
    exit /b 1
)

:: Check if the PowerShell script exists
if not exist "%~dp0cursor_reset.ps1" (
    echo Error: cursor_reset.ps1 not found in the current directory
    pause
    exit /b 1
)

:: Run PowerShell script with admin privileges
echo Requesting administrator privileges...
powershell -NoExit -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -NoExit -File ""%~dp0cursor_reset.ps1""' -Verb RunAs -Wait"

:: Check if the PowerShell command was successful
if %ERRORLEVEL% neq 0 (
    echo.
    echo Error: Failed to run the script with administrator privileges
    echo Please try running PowerShell as administrator manually and execute:
    echo Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    echo.
    pause
    exit /b 1
)

echo.
echo Script execution completed.
pause 