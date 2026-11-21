#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR/.."

source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/start-stop/start.sh"
source "$SCRIPT_DIR/start-stop/stop.sh"
source "$SCRIPT_DIR/tests/smoke.sh"
source "$SCRIPT_DIR/tests/test.sh"

action=""

while getopts "a:" option; do
  case "$option" in
    a)
      action="$OPTARG"
      ;;
    *)
      echo "Usage: $0 -a {start|stop|smoke|test}"
      exit 1
      ;;
  esac
done

case "$action" in
  start)
    start_environment
    ;;
  stop)
    stop_environment
    ;;
  smoke)
    smoke_test
    ;;
  test)
    integration_test
    ;;
  *)
    echo "Usage: $0 -a {start|stop|smoke|test}"
    exit 1
    ;;
esac
