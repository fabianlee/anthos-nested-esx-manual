#!/bin/bash
#
# Evaluates health of admin cluster and user cluster
#
# wait for admin workstation to be availble for ssh
# Then does wait for admin cluster readiness
# then does wait for user cluster readiness
#

function check_port() {
  server=$1
  port=$2
  nc -w 1 -vz $server $port
}

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

function banner() {
  msg="$1"
  echo -e "${GREEN}===== $msg =======${NC}"
}


###### MAIN ###########################################3

banner "ensure admin workstation is ready for ssh"
admin_ws_ready=0
while [ $admin_ws_ready -eq 0 ]; do
  check_port 192.168.140.221 22
  retVal=$?
  if [ $retVal -eq 0 ]; then
    admin_ws_ready=1
    echo "OK admin workstation ready for ssh"
  else
    echo admin ws not ready yet, port 22 not available
    sleep 30
  fi
done

banner "wait for all admin cluster vms to be powered on and ready for ssh"
for node in 192.168.141.222 192.168.141.223 192.168.141.224 192.168.141.225; do
  node_ready=0
  while [ $node_ready -eq 0 ]; do
    check_port $node 22

    retVal=$?
    if [ $retVal -eq 0 ]; then
      echo "OK user node $node ready"
      node_ready=1
    else
      echo "user node $node not ready"
      sleep 30
    fi

  done
done

banner "wait for admin cluster kubeapi endpoint"
admin_api_ready=0
while [ $admin_api_ready -eq 0 ]; do
  check_port 192.168.141.249 443
  retVal=$?
  if [ $retVal -eq 0 ]; then
    echo "OK admin kubectl api ready"
    admin_api_ready=1
  else
    echo "admin kubectl api not ready"
    sleep 30
  fi
done


[ -f gke-admin-workstation ] || { echo "ERROR did not find admin ws private key gke-admin-workstation"; exit 2; }

banner "check for admin cluster pod readiness from inside admin workstation"
admin_cluster_pods_ready=0
while [ $admin_cluster_pods_ready -eq 0 ]; do
  outstr=$(ssh -i gke-admin-workstation ubuntu@192.168.140.221 "kubectl --kubeconfig kubeconfig get pods -A | grep -v Running | grep -v stackdriver | grep -v vsphere-metrics")
  echo "$outstr"
  nlines=$(echo "$outstr" | grep "" -c)
  if [ $nlines -le 1 ]; then
    admin_cluster_pods_ready=1
    echo "OK admin cluster pods ready"
  else
    echo "Admin cluster not ready, still has $nlines pods not ready"
    sleep 30
  fi
done


banner "wait for user cluster kubeapi endpoint"
user_api_ready=0
while [ $user_api_ready -eq 0 ]; do
  check_port 192.168.141.245 443
  retVal=$?
  if [ $retVal -eq 0 ]; then
    echo "OK user kubectl api ready"
    user_api_ready=1
  else
    echo "user kubectl api not ready"
    sleep 30
  fi
done


# if user cluster vms not powered on, kubeapi endpoint on admin cluster will still return healthy pod definitions
# so first we check if user cluster VMs are ready
banner "wait for all user cluster vms to be powered on and ready for ssh"
for node in 192.168.142.230 192.168.142.231 192.168.142.232; do
  node_ready=0
  while [ $node_ready -eq 0 ]; do
    check_port $node 22

    retVal=$?
    if [ $retVal -eq 0 ]; then
      echo "OK user node $node ready"
      node_ready=1
    else
      echo "user node $node not ready"
      sleep 30
    fi

  done
done


banner "check for user cluster pod readiness from inside admin workstation"
user_cluster_pods_ready=0
while [ $user_cluster_pods_ready -eq 0 ]; do
  outstr=$(ssh -i gke-admin-workstation ubuntu@192.168.140.221 "kubectl --kubeconfig user1-kubeconfig get pods -A | grep -v Running | grep -v stackdriver | grep -v vsphere-metrics")
  echo "$outstr"
  nlines=$(echo "$outstr" | grep "" -c)
  if [ $nlines -le 1 ]; then
    user_cluster_pods_ready=1
    echo "OK user cluster pods ready"
  else
    echo "user cluster not ready, still has $nlines pods not ready"
    sleep 30
  fi
done


banner "DONE all ready"
