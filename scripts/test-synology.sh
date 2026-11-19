#!/bin/sh
# Minimal smoke test; run on any Linux amd64 Docker host, including DSM.
set -eu
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || fail "Docker is required."
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
compose_file="$root/docker/synology/compose.yaml"
if docker compose version >/dev/null 2>&1; then
  compose() { docker compose -f "$compose_file" "$@"; }
elif command -v docker-compose >/dev/null 2>&1; then
  compose() { docker-compose -f "$compose_file" "$@"; }
else
  fail "Docker Compose is required."
fi

compose config >/dev/null
compose exec -T claude sh -c 'set -eu; claude --version; id -u | grep -qx 1000; test -w "$HOME"; test -w /workspace; touch /workspace/.synology-claude-smoke; rm /workspace/.synology-claude-smoke'
printf '%s\n' "PASS: Claude Code binary, nonroot user, and persistent workspace verified."
