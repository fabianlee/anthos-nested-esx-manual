#!/bin/bash

set -x
rm download.zip
rm -fr certs
curl -k https://vcenter.home.lab/certs/download.zip --output download.zip
unzip download.zip
openssl x509 -in certs/win/139b6ea5.0.crt -text -noout
cp certs/win/139b6ea5.0.crt vcenter.ca.pem

