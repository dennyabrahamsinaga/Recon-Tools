#!/bin/bash

domain=$1

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

mkdir $domain &> /HasilHunting/$domain

echo "subfinder on"
subfinder -d $domain -all | tee first_result.txt
echo -e "${GREEN}subfinder done${ENDCOLOR}"

echo "assetfinder on"
assetfinder --subs-only $domain | tee second_result.txt
echo -e "${GREEN}assetfinder done${ENDCOLOR}"

echo "amass enum on" 
amass enum --passive -d $domain | tee third_result.txt
echo -e "${GREEN}amasss done${ENDCOLOR}"

echo -e "${RED} Sorting Subdomains${ENDCOLOR}" 
cat first_result.txt second_result.txt third_result.txt | sort -u | tee sorted_subdomain.txt
echo -e "${GREEN}sorting done${ENDCOLOR}"

echo -e "${RED} Filtering Live Subdomains${ENDCOLOR}"
cat sorted_subdomain.txt | httpx | tee live_subdomains.txt
echo -e "${GREEN}Filtering done${ENDCOLOR}"

echo -e "${RED} Find .git Folder in Subdomains${ENDCOLOR}"
httpx -l live_subdomains.txt -path /.git/ --silent | tee gitHTTPX.txt
echo -e "${GREEN} Find Git Folder Done${ENDCOLOR}"

echo -e "${RED} Nuclei INFO Template from Live Subdomains${ENDCOLOR}"
cat live_subdomains.txt | httpx | nuclei -t ~/nuclei-templates/ -es info | tee nucleiHTTPX.txt
echo -e "${GREEN} Nuclei DONE${ENDCOLOR}"

echo -e "${RED} Fetching Files GAU${ENDCOLOR}"
cat live_subdomains.txt | gau | tee gauJS.txt
echo "${GREEN} Fetching GAU done${ENDCOLOR}"

echo -e "${RED} Fetching Files from Waybackurls${ENDCOLOR}"
cat live_subdomains.txt | waybackurls | tee waybackJS.txt
echo "${GREEN} Fetching WAYBACKURLS done${ENDCOLOR}"

echo -e "${RED} Sorting Wayback and Gau${ENDCOLOR}"
cat gauJS.txt waybackJS.txt | sort -u | anew urlJS.txt
echo -e "${GREEN} Sorting done${ENDCOLOR}"

echo -e "${RED} GF Find AWS from JS${ENDCOLOR}"
cat urlJS.txt | gf .gf/aws-key.json | tee awsJS.txt
echo -e "${GREEN} GF AWS done${ENDCOLOR}"

echo -e "${RED} GF Find Firebase from JS${ENDCOLOR}"
cat urlJS.txt | gf .gf/firebase.json | tee firebaseJS.txt
echo -e "${GREEN} GF Firebase done${ENDCOLOR}"

echo -e "${RED} GF Find s3-buckets.json from JS${ENDCOLOR}"
cat urlJS.txt | gf .gf/s3-buckets.json | tee s3bucketJS.txt	
echo -e "${GREEN} GF s3-buckets done${ENDCOLOR}"

echo -e "${RED} GF Find Open Redirect from JS${ENDCOLOR}"
cat urlJS.txt | gf .gf/redirect.json | tee redirectJS.txt
echo -e "${GREEN} GF Open Redirect done${ENDCOLOR}"

echo -e "${RED} GF Find XSS Endpoints from JS${ENDCOLOR}"
cat urlJS.txt | gf .gf/xss.json | tee xssJS.txt
echo -e "${GREEN} GF XSS done${ENDCOLOR}"

echo -e "${RED} Sorting ALL GF Results${ENDCOLOR}"
cat awsJS.txt firebaseJS.txt s3bucketJS.txt redirectJS.txt xssJS.txt | tee finalGF.txt
echo -e "${GREEN} Final GF Done${ENDCOLOR}"

echo -e "\[96mSimple Recon done\e[0m"
