#!/bin/bash

# Setup colors for nice terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== OpsHunt AI - macOS Cron Automation Setup ===${NC}"

# 1. Get absolute directory path of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo -e "Directory identified: ${YELLOW}$DIR${NC}"

# 2. Detect python3 executable
PYTHON_PATH=$(which python3)
if [ -z "$PYTHON_PATH" ]; then
    echo -e "${RED}[Error] python3 could not be found in your PATH. Please install Python3 before running this script.${NC}"
    exit 1
fi
echo -e "Python3 executable identified: ${YELLOW}$PYTHON_PATH${NC}"

# Check for digest.py existence
if [ ! -f "$DIR/digest.py" ]; then
    echo -e "${RED}[Error] digest.py not found in this folder. Make sure you run this script inside the ops_hunt_python_digest directory.${NC}"
    exit 1
fi

# 3. Create cron expressions
CRON_WEEKDAYS="30 11 * * 1-5 cd \"$DIR\" && \"$PYTHON_PATH\" digest.py >> \"$DIR/digest.log\" 2>&1"
CRON_SATURDAY="0 10 * * 6 cd \"$DIR\" && \"$PYTHON_PATH\" digest.py >> \"$DIR/digest.log\" 2>&1"

# 4. Read existing crontab
TMP_CRON=$(mktemp)
crontab -l > "$TMP_CRON" 2>/dev/null

# Remove any old entries referencing this folder to prevent duplicates
# Handles both macOS sed and GNU sed compatibility
sed -i '' "\#$DIR#d" "$TMP_CRON" 2>/dev/null || sed -i "\#$DIR#d" "$TMP_CRON" 2>/dev/null

# 5. Append new cron jobs
echo "" >> "$TMP_CRON"
echo "# OpsHunt AI Daily Digest Schedule" >> "$TMP_CRON"
echo "$CRON_WEEKDAYS" >> "$TMP_CRON"
echo "$CRON_SATURDAY" >> "$TMP_CRON"

# 6. Apply new crontab
crontab "$TMP_CRON"
rm "$TMP_CRON"

echo -e "\n${GREEN}[Success] Cron jobs successfully scheduled!${NC}"
echo -e "${YELLOW}Scheduled jobs list:${NC}"
crontab -l | grep "$DIR"

echo -e "\n${BLUE}================================================${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT CONFIGURATION FOR macOS: ⚠️${NC}"
echo -e "Starting with macOS Mojave, macOS blocks 'cron' from writing to disk folders by default."
echo -e "You MUST grant Full Disk Access to the cron daemon for this to execute successfully:"
echo -e "  1. Open ${BLUE}System Settings -> Privacy & Security -> Full Disk Access${NC}."
echo -e "  2. Click the '+' button."
echo -e "  3. Press ${BLUE}Cmd + Shift + G${NC}, type ${YELLOW}/usr/sbin/cron${NC}, and press Enter."
echo -e "  4. Ensure the toggle for ${BLUE}cron${NC} is turned ${GREEN}ON${NC}."
echo -e "${BLUE}================================================${NC}"
