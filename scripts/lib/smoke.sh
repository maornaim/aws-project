smoke_test() {
  kubectl wait \
    --for=jsonpath='{.status.loadBalancer.ingress}' \
    service/"$SERVICE_NAME" \
    --timeout=5m

  URL="http://$(kubectl get service "$SERVICE_NAME" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

  echo "Testing $URL/health"
  curl --fail "$URL/health"

  echo "Testing $URL/ready"
  curl --fail "$URL/ready"

  echo "Testing $URL/users"
  curl --fail "$URL/users"

  echo "All smoke tests passed"
}
