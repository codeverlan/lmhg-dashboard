#!/bin/bash
# Initialize Hydra database and register an example client
set -e

HYDRA_ADMIN_URL=${HYDRA_ADMIN_URL:-http://localhost:4444}
CLIENT_ID=${HYDRA_CLIENT_ID:-lmhg-backend}
CLIENT_SECRET=${HYDRA_CLIENT_SECRET:-change-me}
REDIRECT_URI=${HYDRA_CLIENT_REDIRECT:-https://localhost:3000/oauth/callback}

# Wait for hydra admin
echo "Waiting for Hydra admin at $HYDRA_ADMIN_URL"
until curl -s $HYDRA_ADMIN_URL/health/ready | grep 'ok' >/dev/null 2>&1; do
  echo -n '.'; sleep 1
done

echo "Registering client $CLIENT_ID"
cat <<EOF | curl -s -X POST $HYDRA_ADMIN_URL/clients -H 'Content-Type: application/json' -d @-
{
  "client_id": "$CLIENT_ID",
  "grant_types": ["authorization_code","refresh_token","client_credentials"],
  "response_types": ["code","id_token"],
  "scope": "openid offline_access phi:access",
  "redirect_uris": ["$REDIRECT_URI"],
  "token_endpoint_auth_method": "client_secret_basic",
  "client_secret": "$CLIENT_SECRET"
}
EOF

echo "Client registered (or already existed)"

*** End Patch