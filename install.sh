#!/bin/bash
CYAN='\e[1;36m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
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

LATEST_VERSION=$(curl -s https://api.github.com/repos/1NoJoom/EZ-Panel/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
[ -z "$LATEST_VERSION" ] && LATEST_VERSION="latest"
curl -sL "https://github.com/1NoJoom/EZ-Panel/releases/latest/download/EZ-Panel" -o "/tmp/EZ-Panel" &
PID=$!
SPIN='-\|/'
i=0
while kill -0 $PID 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${CYAN}Downloading EZ-Panel ($LATEST_VERSION)... ${SPIN:$i:1}${NC}"
    sleep 0.1
done
printf "\r${GREEN}Downloading EZ-Panel ($LATEST_VERSION)... Done!  ${NC}\n"
mv "/tmp/EZ-Panel" "/usr/local/bin/EZ-Panel"
chmod +x "/usr/local/bin/EZ-Panel"
EZ-Panel
