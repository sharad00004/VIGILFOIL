#!/usr/bin/env bash
# Source from any working directory. All mutable runtime state stays in testing/.
CNS_TEST_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export JAVA_HOME="$CNS_TEST_ROOT/tools/jdk"
export GRADLE_USER_HOME="$CNS_TEST_ROOT/cache/gradle"
export XDG_CACHE_HOME="$CNS_TEST_ROOT/cache/xdg"
export TMPDIR="$CNS_TEST_ROOT/cache/tmp"
export JAVA_TOOL_OPTIONS="-Duser.home=\"$CNS_TEST_ROOT/cache/java-home\""
export PATH="$JAVA_HOME/bin:$PATH"
mkdir -p "$GRADLE_USER_HOME" "$XDG_CACHE_HOME" "$TMPDIR" "$CNS_TEST_ROOT/cache/java-home"
