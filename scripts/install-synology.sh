#!/bin/sh
# Install the official Claude Code CLI into a Linux container on Synology DSM.
# Run as the SSH user with Docker access; use sudo if needed.
set -eu

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Linux ] || fail "This installer requires a Linux / Synology host."
case "$(uname -m)" in
  x86_64|amd64) ;;
  *) fail "This profile supports x86_64 Synology only. No native DSM ARM support." ;;
esac
command -v docker >/dev/null 2>&1 || fail "Docker/Container Manager must be installed on the NAS."
docker info >/dev/null 2>&1 || fail "Cannot access Docker. Check permissions, or rerun: sudo sh scripts/install-synology.sh"

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
compose_file="$root/docker/synology/compose.yaml"

if docker compose version >/dev/null 2>&1; then
  compose() { docker compose -f "$compose_file" "$@"; }
elif command -v docker-compose >/dev/null 2>&1; then
  compose() { docker-compose -f "$compose_file" "$@"; }
else
  fail "Docker Compose is required. Install/enable Container Manager or docker-compose."
fi

printf '%s\n' "Validating Synology Compose configuration..."
compose config >/dev/null
printf '%s\n' "Building isolated Claude Code container (Linux amd64)..."
compose up -d --build
printf '%s\n' "Checking the Claude Code binary..."
compose exec -T claude claude --version
cat <<'EOF'

Synology Claude Code container is ready.
From TermiNow SSH on the NAS, open an interactive Claude Code session:
  docker exec -it terminow-claude-code claude
If Docker requires elevated permission:
  sudo docker exec -it terminow-claude-code claude

Your Claude account sign-in remains required; no credentials are included.
See docs/synology.md for updates, backups, and network/security notes.
EOF
