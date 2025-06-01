#!/bin/bash

# Cursor Trial Reset Tool for macOS
# This script helps reset the Cursor trial by removing relevant files and directories

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create logs directory if it doesn't exist
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

# Setup logging
LOG_FILE="$LOG_DIR/cursor_reset_$(date +%Y%m%d_%H%M%S).log"

function log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "$timestamp - $message" | tee -a "$LOG_FILE"
}

# Create backup function
function backup_cursor_data() {
    local backup_dir="./backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    log "Creating backup in: $backup_dir"

    local paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
        "$HOME/Library/Saved Application State/com.cursor.Cursor.savedState"
    )

    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            cp -R "$path" "$backup_dir/"
            log "Backed up: $path"
        fi
    done

    echo "$backup_dir"
}

echo -e "${CYAN}Starting Cursor reset process...${NC}"
log "Operating System: macOS"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please do not run this script as root${NC}"
    exit 1
fi

# Create backup
backup_dir=$(backup_cursor_data)

# Stop Cursor processes
echo -e "${YELLOW}Stopping Cursor processes...${NC}"
pkill -f "Cursor" || true

# Remove Cursor files and directories
paths=(
    "$HOME/Library/Application Support/Cursor"
    "$HOME/Library/Caches/Cursor"
    "$HOME/Library/Preferences/com.cursor.Cursor.plist"
    "$HOME/Library/Saved Application State/com.cursor.Cursor.savedState"
)

for path in "${paths[@]}"; do
    if [ -e "$path" ]; then
        echo -e "${YELLOW}Removing: $path${NC}"
        rm -rf "$path"
        log "Removed: $path"
    fi
done

# Clear cache
echo -e "${YELLOW}Clearing cache...${NC}"
rm -rf "$HOME/Library/Caches/com.cursor.Cursor" 2>/dev/null || true
rm -rf "/tmp/Cursor"* 2>/dev/null || true

# Verify cleanup
echo -e "\n${CYAN}Verifying cleanup...${NC}"
verification_failed=false

if [ -e "$HOME/Library/Application Support/Cursor" ]; then
    echo -e "${YELLOW}Warning: Some Cursor data still exists${NC}"
    verification_failed=true
fi

if [ "$verification_failed" = false ]; then
    echo -e "\n${GREEN}Cursor trial has been reset successfully!${NC}"
    echo -e "${CYAN}Backup created in: $backup_dir${NC}"
    echo -e "${GREEN}You can now start Cursor again with a fresh trial.${NC}"
else
    echo -e "\n${YELLOW}Some cleanup operations may have failed. Please check the log file for details.${NC}"
    echo -e "${CYAN}Log file location: $LOG_FILE${NC}"
fi

echo -e "\nPress any key to exit..."
read -n 1 -s 