#!/bin/bash

set -e

cleanup() {
  docker compose -f compose.test.yml down -v
}

trap cleanup EXIT

docker compose -f compose.test.yml up -d --build --wait

curl --fail http://localhost:5000/health
curl --fail http://localhost:5000/
curl --fail http://localhost:5000/ready
curl --fail http://localhost:5000/test-db

curl --fail \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"ci-test","email":"ci-test@example.com"}' \
  http://localhost:5000/users

curl --fail http://localhost:5000/users
