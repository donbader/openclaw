#!/bin/sh
# Substitute ${VAR} and ${VAR:-default} placeholders in config.template.json
# using only POSIX sh + awk (no gettext/envsubst binary needed).
# Runs as non-root on bookworm.

set -eu

OPENCLAW_HOME="/home/node/.openclaw"
TEMPLATE="/config.template.json"
OUTPUT="/tmp/openclaw.json"
export OPENCLAW_CONFIG_PATH="${OUTPUT}"

# Ensure data dirs exist and are writable (volume may be root-owned)
for dir in "${OPENCLAW_HOME}" "${OPENCLAW_HOME}/canvas" "${OPENCLAW_HOME}/cron" "${OPENCLAW_HOME}/sessions" "${OPENCLAW_HOME}/agents"; do
  mkdir -p "$dir" 2>/dev/null || true
done

# Seed workspace on first run; overwrite when RESET_WORKSPACE=1
if [ ! -d "${OPENCLAW_HOME}/workspace" ] || [ "${RESET_WORKSPACE:-}" = "1" ]; then
  cp -rf /opt/openclaw-workspace/* "${OPENCLAW_HOME}/workspace/" 2>/dev/null || \
    cp -r /opt/openclaw-workspace "${OPENCLAW_HOME}/workspace"
  echo "[entrypoint] Workspace synced from image"
fi

# Render config template with env var substitution
awk '{
  while (match($0, /\$\{[A-Za-z_][A-Za-z_0-9]*(:-[^}]*)?\}/)) {
    prefix = substr($0, 1, RSTART - 1)
    token  = substr($0, RSTART + 2, RLENGTH - 3)  # strip ${ and }
    # check for :-default
    idx = index(token, ":-")
    if (idx > 0) {
      varname = substr(token, 1, idx - 1)
      defval  = substr(token, idx + 2)
    } else {
      varname = token
      defval  = ""
    }
    val = ENVIRON[varname]
    if (val == "" && defval != "") val = defval
    printf "%s%s", prefix, val
    $0 = substr($0, RSTART + RLENGTH)
  }
  print
}' "${TEMPLATE}" > "${OUTPUT}"

echo "[entrypoint] Config written to ${OUTPUT}"

exec node dist/index.js gateway \
  --bind lan \
  --port 18790
