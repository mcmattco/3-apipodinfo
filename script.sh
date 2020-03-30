#!/bin/bash

elb='elb.amazonaws.com'
saname='something'

curloutput=$( \
curl \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-XGET \
-H "Accept: application/json" \
-s \
https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/ingress-nginx/services/ingress-nginx \
)

echo -e "The service account running this pod is" $saname "<br>" > /work-dir/stuff.html

if [[ "$curloutput" == *"$elb"* ]]
then
  echo $curloutput | jq .status.loadBalancer.ingress[].hostname >> /work-dir/stuff.html
else
  echo $curloutput | jq .message >> /work-dir/stuff.html
fi
