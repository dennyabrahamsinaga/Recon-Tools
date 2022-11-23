#!/bin/bash

domain=$1

gau --subs $domain | unfurl domains >> vuln1.txt
waybackurls $domain | unfurl domains >> vuln2.txt
subfinder -d $domain silent >> vuln3.txt

cat vuln1.txt vuln2.txt vuln3.txt | sort -u >> unique_sub.txt

gau --subs dnb.nl | grep "=" | sed 's/.*.?//' | sed 's/&/n\' | sed 's/=.*//' >> param1.txt
waybackurls dnb.nl | grep "=" | sed 's/.*.?//' | sed 's/&/n\' | sed 's/=.*// | sort -i >> param2.txt

cat param1.txt param2.txt | sort -u >> param.txt
