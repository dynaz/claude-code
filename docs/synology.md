# Claude Code on Synology DSM (x86_64)

This profile installs the official Anthropic Claude Code CLI into an isolated Debian Linux container on Synology NAS. This repository provides deployment files, not the proprietary application source.

## Requirements
- Synology NAS with Intel/AMD x86_64 CPU and Docker/Container Manager
- Docker Compose V2 or standalone docker-compose
- SSH user authorized for Docker (sudo may be required)
- Internet access for packages and Anthropic installer
- Claude Code account for interactive authentication

Target hardware: x86_64, 3.7 GiB RAM, Docker already installed. Actual image build and NAS runtime validation are still pending.

## Install from TermiNow SSH

SSH to your NAS, then execute the following ON THE NAS. DSM does not provide apt-get; installation happens inside Docker.

```sh
cd /volume1
mkdir -p terminow-claude-deploy
cd terminow-claude-deploy
curl -fL https://github.com/dynaz/claude-code/archive/refs/heads/feature/synology-dsm-docker.tar.gz -o source.tar.gz
tar -xzf source.tar.gz --strip-components=1
sh scripts/install-synology.sh
```

If Docker permission is denied, use `sudo sh scripts/install-synology.sh`. If your Synology account cannot write in /volume1, pick a writable shared-folder path approved by the NAS administrator.

To start Claude interactively in the TermiNow SSH session:

```sh
sudo docker exec -it terminow-claude-code claude
```

First login follows the official Claude Code authorization flow. No credentials are bundled. Use a full interactive terminal/PTY.

Version check:

```sh
sudo docker exec terminow-claude-code claude --version
```

## Data and security

The container does not publish ports, mount the Docker socket, or map NAS backup directories. It runs as nonroot (UID 1000) with a memory limit of 1.5 GiB and PID limit 256. Stop or tune the agent if other NAS workloads require memory.

Docker named volumes preserve:
- claude_home -> /home/claude (sensitive account session/config)
- claude_workspace -> /workspace (project files)

The installed CLI binary is copied to /usr/local/bin/claude at build time, since the home named volume masks the installer's original home location. Updates require rebuilding the image. Keep the named volumes when updating.

Docker administrative access is powerful on DSM. Limit who can use it. Do not automatically mount your backup volumes. Encrypt any backup containing the Claude login state.

## Manage and test

```sh
sudo docker stop terminow-claude-code
sudo docker start terminow-claude-code
sudo sh scripts/test-synology.sh
```

For updates, refresh the repository archive then run:

```sh
sudo docker compose -f docker/synology/compose.yaml up -d --build
```

## Troubleshooting

- `apt-get: command not found` on the NAS: expected on DSM; do not install apt on DSM.
- Docker permission denied: authorize Docker access or use sudo.
- Compose missing: install/enable supported Docker Compose/Container Manager.
- `claude: command not found` inside container: inspect image build logs.
- Container exits with 137: inspect NAS RAM use and memory limit.
- Cannot log in from SSH: use official authorization URL/device flow. Never expose auth token in chat.

This is a containerized Synology x86_64 profile, not a DSM SPK or native ARM installation. Smoke tests do not prove sign-in or a real coding session; validate these on your NAS.
