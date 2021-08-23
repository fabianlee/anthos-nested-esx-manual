#!/bin/bash
#
# creates self-signed cert

# makes sure apt is healthy
set -ex
sudo apt update -y
set +ex

# install libssl
# older ubuntu versions
sudo apt-get install libssl1.0.0 -y
# newer like Ubuntu20 focal
sudo apt-get install libssl1.1 -y

certs="$1"
if [ -z "$certs" ]; then
  certs="anthos.home.lab"
fi
echo "going to create certs: $certs"

for FQDN in $certs;  do 

  if [ -f $FQDN.key ]; then
    echo "WARNING already have a self-signed key for $FQDN in this directory, delete it first if you want it recreated"
    exit 3
  fi

  # create self-signed cert
  sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout $FQDN.key -out $FQDN.crt \
  -subj "/C=US/ST=CA/L=SFO/O=myorg/CN=$FQDN"

  sudo chown $USER ${certs}.*

  # create pem which contains key and cert
  cat $FQDN.crt $FQDN.key | sudo tee -a $FQDN.pem

  # smoke test, view CN
  openssl x509 -noout -subject -in $FQDN.crt
done



