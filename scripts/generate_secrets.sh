#!/usr/bin/env bash
set -euo pipefail

# Generate a secure local .env from backend/.env.prod.example
OUT=backend/.env
TEMPLATE=backend/.env.prod.example

if [ ! -f "$TEMPLATE" ]; then
  echo "Template $TEMPLATE not found"
  exit 1
fi

PYTHON=$(command -v python3 || command -v python || true)
if [ -z "$PYTHON" ]; then
    echo "Python (python3) not found in PATH. Install Python 3 to run this script." >&2
    exit 1
fi

$PYTHON - <<'PY'
import secrets, os, textwrap
tpl=open('backend/.env.prod.example').read()
def gen(n=48):
    return secrets.token_urlsafe(n)

replacements = {
    'REPLACE_ME_DB_PASS': gen(12),
    'REPLACE_ME_APP_SECRET': gen(48),
    'REPLACE_ME_HYDRA_SYSTEM_SECRET': secrets.token_hex(32),
    'REPLACE_ME_HYDRA_SECRETS_SYSTEM': secrets.token_hex(32),
    'REPLACE_ME_HYDRA_CLIENT_SECRET': gen(24),
    'REPLACE_ME_SMTP_PASSWORD': gen(16),
    'REPLACE_ME_S3_KEY': gen(12),
    'REPLACE_ME_S3_SECRET': gen(24),
}

out = tpl
for k,v in replacements.items():
    out = out.replace(k, v)

with open('backend/.env','w') as f:
    f.write(out)
print('Wrote backend/.env')
PY

chmod 600 $OUT
echo "Created $OUT with restrictive permissions (600). Do NOT commit this file."
