# Cursor Trial Reset Tool

A tool to reset the Cursor trial period for both Windows and macOS.

## Features

- Creates backup of Cursor data before making changes
- Progress bars for visual feedback
- Detailed logging of all operations
- Verification of cleanup operations
- Error handling and recovery
- Immediate effect (no restart required)

## Usage

### Windows

#### Easy Method (Recommended)
1. Double-click `run_as_admin.bat`
2. Click "Yes" when the UAC prompt appears
3. The script will:
   - Create a backup of your Cursor data
   - Stop any running Cursor processes
   - Remove Cursor registry entries
   - Remove Cursor app data
   - Clear Cursor cache
   - Verify the cleanup
4. You can start Cursor immediately after the script completes

#### Manual Method
1. Right-click on `cursor_reset.ps1` and select "Run with PowerShell as Administrator"
2. The script will perform the same operations as above

### macOS

#### Easy Method (Recommended)
1. Open Terminal
2. Navigate to the script directory
3. Make the script executable:
   ```bash
   chmod +x cursor_reset_mac.sh
   ```
4. Run the script:
   ```bash
   ./cursor_reset_mac.sh
   ```
5. The script will:
   - Create a backup of your Cursor data
   - Stop any running Cursor processes
   - Remove Cursor application data
   - Remove Cursor preferences and cache
   - Verify the cleanup
6. You can start Cursor immediately after the script completes

## Troubleshooting

### Windows
- If you get a security error, try running `run_as_admin.bat` instead
- If PowerShell execution is blocked, run this command in an admin PowerShell:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### macOS
- If you get a permission error, make sure the script is executable:
  ```bash
  chmod +x cursor_reset_mac.sh
  ```
- If you get a "command not found" error, make sure you're in the correct directory

## Logs and Backups

- Logs are stored in the `logs` directory
- Backups are stored in a timestamped directory (e.g., `backup_20240315_123456`)
- Check the logs if you encounter any issues

## Requirements

### Windows
- Windows 10 or later
- Administrator privileges

### macOS
- macOS 10.13 or later
- Terminal access

## Note

This tool is provided for educational purposes only. Please use responsibly and in accordance with Cursor's terms of service. 