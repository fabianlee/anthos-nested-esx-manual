#!/bin/bash

# flags used to make curl more scriptable
options='-k --fail --connect-timeout 3 --retry 0 -s -o /dev/null -w %{http_code}'
page='https://anthos.home.lab/istio'


while [ 1==1 ]; do

  # make curl call, capture return exit code and stdout
  datestr=$(date '+%F +%T+%Z')
  outstr=$(curl $options $page)
  retVal=$?
  if [ "$outstr" -eq 200 ]; then
    echo "$datestr OK pulling from $page, retVal=$retVal, http_code=$outstr"
  else
    echo "$datestr ERROR pulling from $page, retVal=$retVal, http_code=$outstr"
  fi

  sleep 5

done
