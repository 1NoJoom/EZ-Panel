#!/bin/bash
CYAN='\e[1;36m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
NC='\e[0m'

EZ_PATHS=(
    "/usr/local/bin/EZ-Panel"
    "/usr/local/bin/ez-panel"
    "/usr/bin/ez-panel"
    "/usr/bin/EZ-Panel"
    "/opt/ez-panel/ez-panel"
    "/opt/ez-panel/start.sh"
    "/usr/local/bin/ezpanel"
)

FOUND_PATH=""
for p in "${EZ_PATHS[@]}"; do
    if [ -x "$p" ]; then
        FOUND_PATH="$p"
        break
    fi
done

if [ -n "$FOUND_PATH" ]; then
    printf "${YELLOW}[!] EZ-Panel is already installed (${FOUND_PATH}). Launching...${NC}\n"
    "$FOUND_PATH"
    exit 0
fi

RELEASE_JSON=$(curl -s https://api.github.com/repos/1NoJoom/EZ-Panel/releases/latest)
LATEST_VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name":' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')
[ -z "$LATEST_VERSION" ] && LATEST_VERSION="latest"


DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep '"browser_download_url":' | grep -i "ez-panel" | head -n1 | sed -E 's/.*"(https[^"]+)".*/\1/')
if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://github.com/1NoJoom/EZ-Panel/releases/latest/download/EZ-Panel"
fi

curl -sL "$DOWNLOAD_URL" -o "/tmp/EZ-Panel" &
PID=$!
SPIN='-\|/'
i=0
while kill -0 $PID 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${CYAN}Downloading EZ-Panel ($LATEST_VERSION)... ${SPIN:$i:1}${NC}"
    sleep 0.1
done
printf "\r${GREEN}Downloading EZ-Panel ($LATEST_VERSION)... Done!  ${NC}\n"

# بررسی سلامت فایل دانلودشده قبل از اجرا؛ جلوگیری از اجرای صفحه خطای 404 به‌عنوان اسکریپت
if [ ! -s "/tmp/EZ-Panel" ] || head -c 20 "/tmp/EZ-Panel" | grep -qi "^404\|not found\|<html"; then
    printf "${RED}[-] Download failed — the file at the release URL is not a valid binary.${NC}\n"
    printf "${RED}    Check the asset name on: https://github.com/1NoJoom/EZ-Panel/releases/latest${NC}\n"
    rm -f "/tmp/EZ-Panel"
    exit 1
fi

mv "/tmp/EZ-Panel" "/usr/local/bin/EZ-Panel"
chmod +x "/usr/local/bin/EZ-Panel"
EZ-Panel
