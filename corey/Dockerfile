FROM ghcr.io/openclaw/openclaw:latest

# Pre-create data dir with node ownership so Docker volume init preserves it
USER root
RUN mkdir -p /home/node/.openclaw/workspace \
             /home/node/.openclaw/canvas \
             /home/node/.openclaw/cron \
             /home/node/.openclaw/sessions \
             /home/node/.openclaw/agents \
 && chown -R node:node /home/node/.openclaw

# Install Chromium + Xvfb for browser automation (~300MB)
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends xvfb \
 && mkdir -p /home/node/.cache/ms-playwright \
 && PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright \
    node /app/node_modules/playwright-core/cli.js install --with-deps chromium \
 && chown -R node:node /home/node/.cache/ms-playwright \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install GitHub CLI for the github skill
RUN apt-get update \
 && apt-get install -y --no-install-recommends gpg curl \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

USER node

COPY --chown=node:node config.template.json /config.template.json
COPY --chown=node:node entrypoint.sh /entrypoint.sh
COPY --chown=node:node workspace/ /opt/openclaw-workspace/
COPY --chown=node:node skills/ /opt/openclaw-skills/

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
