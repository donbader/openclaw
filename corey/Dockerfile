FROM ghcr.io/openclaw/openclaw:latest

# Pre-create data dir with node ownership so Docker volume init preserves it
USER root
RUN mkdir -p /home/node/.openclaw/workspace \
             /home/node/.openclaw/canvas \
             /home/node/.openclaw/cron \
             /home/node/.openclaw/sessions \
             /home/node/.openclaw/agents \
 && chown -R node:node /home/node/.openclaw
USER node

COPY --chown=node:node config.template.json /config.template.json
COPY --chown=node:node entrypoint.sh /entrypoint.sh
COPY --chown=node:node workspace/ /home/node/.openclaw/workspace/

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
