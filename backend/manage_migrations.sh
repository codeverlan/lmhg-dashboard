#!/bin/bash
set -e

# Simple migration runner for Alembic in the backend container
cd /app
if [ -z "$DATABASE_URL" ]; then
  echo "DATABASE_URL not set"
  exit 1
fi

# ensure alembic is available
alembic -c alembic.ini upgrade head

echo "Migrations applied"
