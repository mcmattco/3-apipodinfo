curl \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-XGET \
-H "Accept: application/json" \
-s \
https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/ingress-nginx/services/ingress-nginx \
| jq .status.loadBalancer.ingress[].hostname \
> /work-dir/stuff.html
