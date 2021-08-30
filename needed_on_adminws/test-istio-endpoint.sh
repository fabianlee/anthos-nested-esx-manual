#!/bin/bash

page="$1"
sleepsec="$2"
[ -n "$page" ] || page='https://anthos.home.lab/istio'
[ -n "$sleepsec" ] || sleepsec=5

echo "going to query $page ever $sleepsec seconds"

# flags used to make curl more scriptable
options='-k --fail --connect-timeout 2 --retry 0 -s -o /dev/null -w %{http_code}'

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

############# MAIN ######################

first=1
while [ 1==1 ]; do

  # make curl call, capture return exit code and stdout
  datestr=$(date '+%F +%T+%Z')
  outstr=$(curl $options $page)
  retVal=$?
  if [ "$outstr" -eq 200 ]; then
    if [ $first -eq 1 ]; then
      echo -e "${GREEN}$datestr OK${NC} pulling from $page, retVal=$retVal, http_code=$outstr"
      first=0
    else
      echo -en "${GREEN}.${NC}"
    fi
  else
    echo -e "${RED}$datestr ERROR${NC} pulling from $page, retVal=$retVal, http_code=$outstr"
    first=1
  fi

  sleep $sleepsec

done
