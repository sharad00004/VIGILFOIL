#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../env.sh"
COOJA_DIR="$CNS_TEST_ROOT/tools/contiki-ng/tools/cooja"
exec "$JAVA_HOME/bin/java" -Xms256m -Xmx2048m --enable-native-access=ALL-UNNAMED \
  -jar "$COOJA_DIR/build/libs/cooja.jar" \
  --contiki "$CNS_TEST_ROOT/tools/contiki-ng" --cooja "$COOJA_DIR" "$@"
