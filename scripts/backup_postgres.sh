#!/bin/bash
# Simple on-prem Postgres backup script
set -e
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
BACKUP_DIR=${BACKUP_DIR:-/backups}
mkdir -p "$BACKUP_DIR"

PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-lmhg}
PGDATABASE=${PGDATABASE:-lmhg_dev}

export PGPASSWORD=${PGPASSWORD:-lmhg}

pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Fc -f "$BACKUP_DIR/lmhg_backup_$TIMESTAMP.dump" "$PGDATABASE"

echo "Backup saved to $BACKUP_DIR/lmhg_backup_$TIMESTAMP.dump"
