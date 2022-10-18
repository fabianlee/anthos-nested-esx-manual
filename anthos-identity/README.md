
# creates 'kubectl-anthos-config.yaml'
gcloud anthos create-login-config --kubeconfig=$KUBECONFIG

# ldap login
gcloud anthos auth login --cluster user1 --login-config kubectl-anthos-config.yaml

