#!/bin/bash

set -e

HOST=$(kubectl get service app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
URL="http://$HOST"

curl --fail "$URL/health"
curl --fail "$URL/ready"
curl --fail "$URL/users"
