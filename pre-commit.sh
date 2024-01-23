#!/bin/bash

#colors:
R='\033[1;31m' # RED
G='\033[0;32m' # GREEN
Y='\033[0;33m' # YELLOW
B='\033[0;34m' # BLUE
M='\033[1;35m' # MAGENTA
W='\033[0;37m' # WHITE
D='\033[0m' # NO COLOR
CHM="\xE2\x9C\x94" # ✔ 
CRM="\xE2\x9D\x8C" # ❌

# Check if gitleaks is enabled in Git config
ENABLE=$(git config --bool hooks.gitleaks-enable)

if [ "$ENABLE" != "true" ]; then
    echo -e "Verify secret visibility. \nRun ${Y}git config hooks.gitleaks-enable true ${D}to enable the config option."
    exit 0
fi

echo -e "${G}Scanning for secrets using gitleaks...${D}"

# Check commits for the secrets
./gitleaks detect -v --redact --report-format json --report-path gitleaks-report.json

if [ "$?" != "0" ]; then

    echo -e "${CRM}${R}Secrets found. Review the commits. \nCheck the ${W}gitleaks-report.json${D} ${R}file for additional information ${D}"
    exit 1
else
    # Check files for the secrets
    ./gitleaks protect -v --redact --report-format json --report-path gitleaks-report.json 

    if [ "$?" != "0" ]; then
    echo -e "${CRM} ${M}Secrets found. Review the files. \nCheck the ${W}gitleaks-report.json${D} ${M}file for additional information ${D}"
    exit 1
    else 
    # Check staging area for the secrets
        ./gitleaks protect --staged -v --redact --report-format json --report-path gitleaks-report.json   
        if [ "$?" != "0" ]; then
        echo -e "${CRM} ${M}Secrets found in staging area. \nCheck the ${W}gitleaks-report.json${D} ${M}file for additional information ${D}"
        exit 1
        fi
    fi
fi

if [ "$?" -eq "0" ]; then
	echo -e "${CHM} ${G}Secrets check passed successfully.${D}"
fi

exit 0