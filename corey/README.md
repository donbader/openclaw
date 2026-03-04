# Corey's OpenClaw Deployment

Personal OpenClaw deployment via Dokploy — single `docker compose up`.

## Setup

```bash
# 1. Copy secrets template and fill in your values
cp .env.example .env
vim .env

# 2. Make entrypoint executable
chmod +x entrypoint.sh

# 3. Deploy
docker compose up -d
```

## What's What

| File | Purpose | Committed? |
|---|---|---|
| `config.template.json` | Full config with `${ENV_VAR}` placeholders for secrets | Yes |
| `.env` | Actual secrets (API keys, bot tokens, `GH_TOKEN`, `TAVILY_API_KEY`) | No |
| `entrypoint.sh` | Substitutes env vars into config on container start | Yes |
| `workspace/` | Agent prompt files (AGENTS.md, SOUL.md, etc.) | Yes |
| `skills/` | Skills baked into the image (synced on every container start) | Yes |
| `docker-compose.yml` | Single-service deployment | Yes |

## Deploy

```bash
docker compose up -d
```

Gateway will be available at `http://<host>:18790` with token auth.

## Customize

### Change the LLM

Edit `config.template.json` — update `models.providers.rkgw` and `agents.defaults.model.primary`.

### Change Telegram allowlist

Edit `config.template.json` — update `channels.telegram.allowFrom` array.

### Change agent personality

Edit files in `workspace/` — changes take effect on `docker compose restart`.

### Enable Discord or LINE

Set `enabled: true` in `config.template.json` under the channel, add the token as a `${ENV_VAR}` placeholder, and add the actual token to `.env`.

### Add skills

Drop a skill folder (containing `SKILL.md`) into `skills/`, rebuild, and redeploy. Skills are synced from the image into the volume on every container start.

### Web search

The built-in `web_search` tool (Brave) is disabled. Web search is handled by the Tavily skill instead — set `TAVILY_API_KEY` in `.env`.

### Heartbeat

Heartbeat runs every 30 minutes during active hours (08:00–23:00 Asia/Taipei) using Haiku to save cost.

## Update

```bash
docker compose pull
docker compose up -d
```

## Logs

```bash
# Follow logs
docker compose logs -f

# Last 100 lines
docker compose logs --tail 100
```

## Stop

```bash
docker compose down
```

Data persists in the `openclaw-data` Docker volume. To nuke everything:

```bash
docker compose down -v
```
