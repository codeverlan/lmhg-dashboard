#!/bin/sh
set -e

# If node_modules is missing (volume shadowed), install dependencies on container start
if [ ! -d node_modules ]; then
  echo "node_modules missing, installing..."
  npm install --legacy-peer-deps
fi

# If a build is requested (CI) it will have been done at image build time.
# Start the dev server (Next.js) by default
exec "$@"
