# 3-apipodinfo

trying to make stome stuff happen getting info about the cluster or pods from the cluster API or downward API

# downward API

limited variables?
https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/#capabilities-of-the-downward-api

# cluster API

1. first must create a clusterrole for the default service account
this maifest creates the clusterole with read access on everything

'''
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: service-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["*"]
  verbs: ["get", "watch", "list"]
'''

2. then exec to alpha pod and curl API:

```
curl \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-XGET \
-H "Accept: application/json" \
-s \
https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/default/services/nginx-alpha
```
