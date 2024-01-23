#!/bin/bash

#colors:
R='\033[1;31m' # RED
G='\033[0;32m' # GREEN
Y='\033[0;33m' # YELLOW
B='\033[0;34m' # BLUE
M='\033[0;35m' # MAGENTA
W='\033[0;37m' # WHITE
BOLD='\033[1m'
D='\033[0m' # NO COLOR
CHM="\xE2\x9C\x94" # ✔ 
CRM="\xE2\x9D\x8C" # ❌

DATETIME=$(date +%y%m%d_%H%M)
GITLEAKS_VERSION="8.18.1"
GITLEAKS_CURRENT_VERSION=$(./gitleaks version)
PRECOMMIT_URL="https://raw.githubusercontent.com/sbazanov/Week8_task1_gitleaks/main/pre-commit.sh"
HOOKS_DIR=".git/hooks"
ENABLE=$(git config --bool hooks.gitleaks-enable)

if [ -f gitleaks ]; then
    echo -e "Gitleaks alredy installing. \nGitleaks version: ${W}${BOLD}${GITLEAKS_CURRENT_VERSION}${D}";
    # read -p "Do you want to continue? (y/n): " response
    # if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    #     echo -e >&2 "${R}Installation aborted.${D}"
    #     exit 1
    # fi
 fi

# Determine the operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="darwin"
else
    echo -e "${R}Unsupported operating system.${D}"
    exit 1
fi
echo -e "${M}Operating System: $OS${D}"

GITLEAKS_URL=https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION/gitleaks_"$GITLEAKS_VERSION"_"$OS"_x64.tar.gz

# Install the gitleaks
echo -e "${G}Downloading and installing gitleaks... ${D}";

curl -sSfL "$GITLEAKS_URL" -o gitleaks.tar.gz
tar -xf gitleaks.tar.gz
chmod +x gitleaks
rm gitleaks.tar.gz LICENSE
git restore README.md
GITLEAKS_CURRENT_VERSION=$(./gitleaks version)

echo -e "${G}$DATETIME Gitleaks installed.\n${M}Gitleaks version: ${W}${BOLD}${GITLEAKS_CURRENT_VERSION}${D}";

# Install the pre-commit hook
mkdir -p "$HOOKS_DIR"
echo -e "${B}Downloading pre-commit hook...${D}"
curl -sSfL "$PRECOMMIT_URL" -o "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

if [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo -e "${G}${CHM} Pre-commit hook script installed successfully!${D}"
else
    echo -e "${R}${CRM} An error occurred while installing the pre-commit hook script.${D}"
fi

echo -e "${G}${CHM} Enable Gitleaks
Use ${W}git config hooks.gitleaks-enable disable ${G}for disable
Or ${W}git config --unset hooks.gitleaks-enable ${G}for unset ${D}"
git config hooks.gitleaks-enable true
