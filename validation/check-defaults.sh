#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d)"
trap 'rm -r -- "$work"' EXIT
cp "$root/variables.tf" "$work/variables.tf"

printf '$ terraform console # valid defaults\n> [var.ip_address, var.ip_addresses]\n'
printf '[var.ip_address, var.ip_addresses]\n' | terraform -chdir="$work" console -no-color

check_invalid() {
  local name="$1" bad_default="$2" output
  printf '\n$ terraform console # default for %s = %s\n> var.%s\n' "$name" "$bad_default" "$name"
  printf 'variable "%s" {\n  default = %s\n}\n' "$name" "$bad_default" >"$work/test_override.tf"
  output=$(printf 'var.%s\n' "$name" | terraform -chdir="$work" console -no-color 2>&1) || true
  printf '%s\n' "$output"
  [[ "$output" == *"Invalid value for variable"* ]]
}

check_invalid ip_address '"1920.1680.0.1"'
check_invalid ip_addresses '["192.168.0.1", "1.1.1.1", "1270.0.0.1"]'
