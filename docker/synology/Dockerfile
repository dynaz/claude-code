# Install the official, unmodified Claude Code Linux amd64 binary in an isolated container.
# The host DSM system is never modified by this Dockerfile.
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/claude \
    PATH=/home/claude/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    DISABLE_AUTOUPDATER=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash ca-certificates curl git openssh-client ripgrep tini \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 1000 claude \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash claude \
    && mkdir -p /workspace \
    && chown claude:claude /workspace

USER claude

# Native installer is maintained by Anthropic. Do not modify Claude Code itself.
# Validate the installer and binary at build time; a pinned release can be
# selected by updating this step after checking the official install docs.
RUN curl -fsSL https://claude.ai/install.sh -o /tmp/claude-install.sh \
    && bash /tmp/claude-install.sh \
    && /home/claude/.local/bin/claude --version \
    && rm -f /tmp/claude-install.sh

USER root
# Keep the executable available if a persistent volume masks /home/claude.
RUN cp -L /home/claude/.local/bin/claude /usr/local/bin/claude \
    && chmod 0755 /usr/local/bin/claude

USER claude
WORKDIR /workspace
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sleep", "infinity"]
