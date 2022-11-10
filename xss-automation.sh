#!/bin/bash

# XSS Automation on Dynamic Targets

domain=$1

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

echo "Crawling parameters on Target"
python3 paramspider --domain $domain --level high --subs True --exclude jpg,png,gif -o "$domain.txt"
echo -e "${GREEN}Crawling done using ParamSpider${ENDCOLOR}"

echo "Read Vulnerable Parameters and using KXSS + Dalfox"
cat output/"$domain.txt" | kxss | dalfox pipe
echo -e "${GREEN}Testing potential parameters using Dalfox and KXSS${ENDCOLOR}"

echo "Using DALFOX with custom XSS payloads to get live results"
dalfox file output/"$domain.txt" --custom-payload ../sectools/wordlists/xss-payloads.txt --debug --follow-redirects
echo -e "DALFOX with custom crafting XSS payloads ${GREEN}DONE"

echo -e "${RED} XSS Automation ${GREEN}DONE"
