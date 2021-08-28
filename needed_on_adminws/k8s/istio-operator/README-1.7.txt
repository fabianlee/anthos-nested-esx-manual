f#
# To remove the OOTB istio that comes with Anthos 1.4 and replace with a full 1.7.5 istio operator
# and then canary upgrade up
#

# remove my istio components
cd ~/k8s
kubectl delete -f istio-ootb/my-istio-virtualservice.yaml
kubectl delete -f istio-ootb/istio-autogenerated-k8s-ingress.yaml
kubectl delete -f istio/my-service-for-istio.yaml

# remove ootb istio components
cd ~/k8s/istio-ootb
./delete-istio-ootb-components.sh

# create tls key/cert, k8s TLS secret, istio gateway using secret
cd ~/k8s/istio
./make-self-signed-cert.sh


#
# installing 1.7.5
#
# https://istio.io/v1.7/docs/setup/upgrade/
# https://banzaicloud.com/blog/istio-canary-upgrade/

cd ~/k8s
export istiover=1.7.5
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$istiover sh -

istio-$istiover/bin/istioctl x precheck

istio-$istiover/bin/istioctl operator init --revision 1-7-5

$ kubectl get deployments -n istio-operator
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
istio-operator-1-7-5   1/1     1            1           91s

$ kubectl get mutatingwebhookconfiguration
NAME                           CREATED AT
istio-sidecar-injector-1-7-5   2021-08-27T00:18:35Z

# create istio-system which does not exist yet
kubectl get all -n istio-operator
kubectl create ns istio-system

kubectl apply -f istio-operator/istio-operator-1.7.5.yaml

# until you see "Addons installed"
istio-operator/show-istio-operator-logs.sh

# then wait for all components to be 'Running'
watch -n2 kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-6bdd7687b6-86cls   1/1     Running   0          2m22s
istiod-1-7-5-649b69468-ptjrj            1/1     Running   0          2m34s

# 'istio-ingressgateway' will be on EXTERNAL-IP
kubectl get services -n istio-system

# apply namespace label istio.io/rev
istio-operator/namespace-labels-for-1.x.sh 1-7-5

# control plane (either command works)
$ kubectl get -n istio-system iop
$ kubectl get istiooperators.install.istio.io -n istio-system istio-control-plane
NAME                  REVISION   STATUS        AGE
istio-control-plane   1-7-5      RECONCILING   8h


$ kubectl describe -n istio-system deployment/istio-ingressgateway | grep Labels -A10
  Labels:           app=istio-ingressgateway
                    chart=gateways
                    heritage=Tiller
                    istio=ingressgateway
                    release=istio
                    service.istio.io/canonical-name=istio-ingressgateway
                    service.istio.io/canonical-revision=1-7-5
Image:       docker.io/istio/proxyv2:1.7.5


# rolling deployment restart
kubectl rollout restart -n default deployment/my-istio-deployment
# to do entire namespace!
# kubectl rollout restart deployment -n default

# envoy proxy now at new version
$ kubectl describe pod -lapp=my-istio-deployment | grep 'Image:'
    Image:         docker.io/istio/proxyv2:1.7.5
    Image:          gcr.io/google-samples/hello-app:1.0
    Image:         docker.io/istio/proxyv2:1.7.5
    Image:         docker.io/istio/proxyv2:1.7.5
    Image:          gcr.io/google-samples/hello-app:1.0
    Image:         docker.io/istio/proxyv2:1.7.5

$ kubectl get deployments -n istio-system
istio-ingressgateway   1/1     1            1           35m
istiod-1-7-5           1/1     1            1           35m

$ kubectl get services -n istio-system
istio-ingressgateway   LoadBalancer   10.96.233.110   192.168.142.253   15021:30048/TCP,80:32600/TCP,443:32601/TCP,31400:31969/TCP,15443:32167/TCP   35m
istiod-1-7-5           ClusterIP      10.96.233.231   <none>            15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                                35m






# now do upgrade to 1.7.6
cd ~/k8s
export istiover=1.7.6
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$istiover sh -
istio-$istiover/bin/istioctl x precheck
istio-$istiover/bin/istioctl operator init --revision 1-7-6

# this changes revision in iop
kubectl apply -f istio-operator/istio-operator-1.7.6.yaml

# wait till 'Pruning removed resources'
istio-operator/show-istio-operator-logs.sh

# then wait for all components to be 'Running'
watch -n2 kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-6bdd7687b6-86cls   1/1     Running   0          2m22s
istiod-1-7-5-649b69468-ptjrj            1/1     Running   0          2m34s
istiod-1-7-6-64ff4f6869-w4tqt           1/1     Running   0          25m

# control plane (either command works)
$ kubectl get -n istio-system iop
$ kubectl get istiooperators.install.istio.io -n istio-system istio-control-plane
NAME                  REVISION   STATUS        AGE
istio-control-plane   1-7-6      HEALTHY   8h

# 'istio-ingressgateway' will be on EXTERNAL-IP
$ kubectl get services -n istio-system
istio-ingressgateway   LoadBalancer   10.96.233.110   192.168.142.253   15021:32236/TCP,80:32600/TCP,443:32601/TCP,31400:31475/TCP,15443:31837/TCP   69m
istiod-1-7-5           ClusterIP      10.96.233.231   <none>            15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                                69m
istiod-1-7-6           ClusterIP      10.96.233.63    <none>            15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                                25m

# apply namespace label istio.io/rev
istio-operator/namespace-labels-for-1.x.sh 1-7-6

# rolling deployment restart
kubectl rollout restart -n default deployment/my-istio-deployment

# envoy proxy now at new version, wait till app proxy are at 1.7.6
$ kubectl describe pod -lapp=my-istio-deployment | grep 'Image:'

#
# uninstall the old control plan
#
$ istio-1.7.5/bin/istioctl x uninstall --revision 1-7-5
  Removed HorizontalPodAutoscaler:istio-system:istiod-1-7-5.
  Removed PodDisruptionBudget:istio-system:istiod-1-7-5.
  Removed Deployment:istio-operator:istio-operator-1-7-5.
  Removed Deployment:istio-system:istiod-1-7-5.
  Removed Service:istio-operator:istio-operator-1-7-5.
  Removed Service:istio-system:istiod-1-7-5.
  Removed ConfigMap:istio-system:istio-1-7-5.
  Removed ConfigMap:istio-system:istio-sidecar-injector-1-7-5.
  Removed ServiceAccount:istio-operator:istio-operator-1-7-5.
  Removed EnvoyFilter:istio-system:metadata-exchange-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:metadata-exchange-1.7-1-7-5.
  Removed EnvoyFilter:istio-system:stats-filter-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:stats-filter-1.7-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-metadata-exchange-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-metadata-exchange-1.7-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-stats-filter-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-stats-filter-1.7-1-7-5.
  Removed MutatingWebhookConfiguration::istio-sidecar-injector-1-7-5.
object: MutatingWebhookConfiguration::istio-sidecar-injector-1-7-5 is not being deleted because it no longer exists
  Removed MutatingWebhookConfiguration::istio-sidecar-injector-1-7-5.
✔ Uninstall complete                                          








#
# now do upgrade to 1.7.8
#
cd ~/k8s
export istiover=1.7.8
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$istiover sh -
istio-$istiover/bin/istioctl x precheck

$ istio-$istiover/bin/istioctl operator init --revision 1-7-8
Using operator Deployment image: docker.io/istio/operator:1.7.8
2021-08-28T13:42:02.892856Z	info	proto: tag has too few fields: "-"
✔ Istio operator installed                                                                                              
✔ Installation complete


$ kubectl get deployments -n istio-operator
istio-operator-1-7-6   1/1     1            1           51m
istio-operator-1-7-8   1/1     1            1           43s


# this changes revision in iop
kubectl apply -f istio-operator/istio-operator-1.7.8.yaml

# wait till 'Pruning removed resources'
istio-operator/show-istio-operator-logs.sh

# then wait for all components to be 'Running'
watch -n2 kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-6bdd7687b6-86cls   1/1     Running   0          2m22s
istiod-1-7-6-649b69468-ptjrj            1/1     Running   0          2m34s
istiod-1-7-8-64ff4f6869-w4tqt           1/1     Running   0          25m

# control plane (either command works)
$ kubectl get -n istio-system iop
$ kubectl get istiooperators.install.istio.io -n istio-system istio-control-plane
NAME                  REVISION   STATUS        AGE
istio-control-plane   1-7-8      HEALTHY   8h

# 'istio-ingressgateway' will be on EXTERNAL-IP
$ kubectl get services -n istio-system
istio-ingressgateway   LoadBalancer   10.96.233.110   192.168.142.253   15021:32236/TCP,80:32600/TCP,443:32601/TCP,31400:31475/TCP,15443:31837/TCP   69m
istiod-1-7-6           ClusterIP      10.96.233.231   <none>            15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                                69m
istiod-1-7-8           ClusterIP      10.96.233.63    <none>            15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                                25m

# apply namespace label istio.io/rev
istio-operator/namespace-labels-for-1.x.sh 1-7-8

# rolling deployment restart
kubectl rollout restart -n default deployment/my-istio-deployment

# envoy proxy now at new version, wait till app proxy are at 1.7.8
$ kubectl describe pod -lapp=my-istio-deployment | grep 'Image:'

#
# uninstall the old control plan
#
# will see both 1-7-6 and 1-7-8 control planes
$ istio-operator/show-istio-versions.sh
$ istio-1.7.6/bin/istioctl x uninstall --revision 1-7-6
  Removed HorizontalPodAutoscaler:istio-system:istiod-1-7-5.
  Removed PodDisruptionBudget:istio-system:istiod-1-7-5.
  Removed Deployment:istio-operator:istio-operator-1-7-5.
  Removed Deployment:istio-system:istiod-1-7-5.
  Removed Service:istio-operator:istio-operator-1-7-5.
  Removed Service:istio-system:istiod-1-7-5.
  Removed ConfigMap:istio-system:istio-1-7-5.
  Removed ConfigMap:istio-system:istio-sidecar-injector-1-7-5.
  Removed ServiceAccount:istio-operator:istio-operator-1-7-5.
  Removed EnvoyFilter:istio-system:metadata-exchange-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:metadata-exchange-1.7-1-7-5.
  Removed EnvoyFilter:istio-system:stats-filter-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:stats-filter-1.7-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-metadata-exchange-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-metadata-exchange-1.7-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-stats-filter-1.6-1-7-5.
  Removed EnvoyFilter:istio-system:tcp-stats-filter-1.7-1-7-5.
  Removed MutatingWebhookConfiguration::istio-sidecar-injector-1-7-5.
object: MutatingWebhookConfiguration::istio-sidecar-injector-1-7-5 is not being deleted because it no longer exists
  Removed MutatingWebhookConfiguration::istio-sidecar-injector-1-7-5.
✔ Uninstall complete                                          

# now all 1-7-6 should be gone
$ istio-operator/show-istio-versions.sh







