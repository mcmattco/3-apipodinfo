# 3-apipodinfo

OBJECTIVE:
trying to make stome stuff happen getting info about the cluster or pods from the cluster API or downward API

# downward API

limited variables?
https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/#capabilities-of-the-downward-api

# cluster API

Let's get that ELB DNS name out of the API

1. first must create a clusterrole for the default service account

this manifest creates the clusterole with read access on everything

```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: service-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["*"]
  verbs: ["get", "watch", "list"]
```

2. then exec to a pod and curl API, in this case for the nginx-alpha pod's services:

```
curl \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-XGET \
-H "Accept: application/json" \
-s \
https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/default/services/nginx-alpha
```

the output though doesn't give the ELB DNS name:

```
...
 "status": {
    "loadBalancer": {
...
```

wut?
oh yeah, the load balancer lives in the nginx ingress namespace!

3. append the clusterroles.yaml to include the namespace:

```
 kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: ingress-nginx
  name: service-reader
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "watch", "list"]
```

4. update the curl command:

```
curl \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-XGET \
-H "Accept: application/json" \
-s \
https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/ingress-nginx/services/ingress-nginx
```

output:
```
...
  "status": {
    "loadBalancer": {
      "ingress": [
        {
          "hostname": "afd6a42d35d8c11eaaeeb02867eb9d8f-1961914697.us-east-2.elb.amazonaws.com"
        }
...
```

5. deploy alpine container, install curl and jq, add this line to the curl cmd to parse out the dns name:

```
| jq .status.loadBalancer.ingress[].hostname
```

output:
```
"afd6a42d35d8c11eaaeeb02867eb9d8f-1961914697.us-east-2.elb.amazonaws.com"
```

1. make new container `jqbox`, based on alpine, install bash, curl, and jq, push to dockerhub

1. create `script.sh` to run curl and jq commands, output to stuff.html in same dir ***this was a problem***

1. modify `configmap.yaml` to include script in new configmap 

1. modify initContainer to run `jqbox` and run `script.sh`, fails

1. test by creating seperate manifest to run jqbox and mount configmap, error `read-only file system'

1. research, find that configmaps are always ro, you have to create a seperate emptyDir volume and dump output there, then mount that volume to main container

1. add `workdir` volumeMount as emptyDir and `scriptdir` volumeMount as mounting the script file

1. change command for initContainer to run from script-dir

1. victory
