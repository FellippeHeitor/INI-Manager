#!/bin/sh
# Compiles the library, demos and iniman, then runs the regression tests.
#
# Usage: tests/run-tests.sh [path-to-qb64pe-folder]
#        (defaults to $QB64PE, then ~/qb64pe)
set -e

QB="${1:-${QB64PE:-$HOME/qb64pe}}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/tests/_bin"
mkdir -p "$BIN"

compile() {
    echo "Compiling $1..."
    (cd "$QB" && ./qb64pe -x "$ROOT/$1.bas" -o "$BIN/$(basename "$1")" > "$BIN/$(basename "$1").log" 2>&1) || {
        cat "$BIN/$(basename "$1").log"
        exit 1
    }
}

# the demos don't include ini.bi, so this also checks that it stays optional
compile ini-demo1
compile ini-demo2
compile ini-demo3
compile iniman
compile tests/ini-tests

echo
cd "$ROOT/tests"
"$BIN/ini-tests"

echo
echo "iniman"
INIMAN="$BIN/iniman"
F="$BIN/cli-test.ini"
rm -f "$F"
fail=0
expect() { # expect <description> <expected> <actual>
    if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 (expected '$2', got '$3')"; fail=1; fi
}
expect "write"            "John Doe" "$("$INIMAN" "$F" -write owner name "John Doe")"
expect "read"             "John Doe" "$("$INIMAN" "$F" -read owner name)"
"$INIMAN" "$F" -read owner nope > /dev/null && code=0 || code=$?
expect "missing key exit" 3 "$code"
"$INIMAN" "$BIN/does-not-exist" -read > /dev/null && code=0 || code=$?
expect "missing file exit" 1 "$code"
"$INIMAN" "$F" -write owner name "John Doe" > /dev/null && code=0 || code=$?
expect "success exit" 0 "$code"
rm -f "$F"
exit $fail
