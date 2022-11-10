#!/bin/bash

target=$1

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

echo -e "${GREEN}Finding DOM XSS using Nuclei Templates${ENDCOLOR}"
subfinder -d $target | httpx | nuclei -t nuclei-templates/vulnerabilities/other/keycloak-xss.yaml
echo -e "${RED}Fetching results done${ENDCOLOR}"

 

