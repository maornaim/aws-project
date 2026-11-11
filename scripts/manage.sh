#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR/.."

source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/start.sh"
source "$SCRIPT_DIR/lib/stop.sh"
source "$SCRIPT_DIR/lib/smoke.sh"
source "$SCRIPT_DIR/lib/test.sh"

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
