#!/bin/bash

set -e

kubectl wait \
  --for=jsonpath='{.status.loadBalancer.ingress}' \
  service/app-service \
  --timeout=5m

HOST=$(kubectl get service app-service \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

URL="http://$HOST"

echo "Testing $URL/health"
curl --fail "$URL/health"

echo "Testing $URL/ready"
curl --fail "$URL/ready"

echo "Testing $URL/users"
curl --fail "$URL/users"

echo "All smoke tests passed"