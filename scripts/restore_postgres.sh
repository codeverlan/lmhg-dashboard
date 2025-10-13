#!/bin/bash
# Simple on-prem Postgres restore script
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/backup.dump"
  exit 1
fi
BACKUP_FILE=$1
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-lmhg}
PGDATABASE=${PGDATABASE:-lmhg_dev}
export PGPASSWORD=${PGPASSWORD:-lmhg}

pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -c "$BACKUP_FILE"

echo "Restore complete"
