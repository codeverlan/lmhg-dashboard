# Backup & Restore Policy (LMHG)

Scope: Postgres database and on-prem object storage for PHI artifacts.

Backup schedule
- Daily snapshot backups at 02:00 local time.
- Weekly full backups retained for 12 weeks.
- Monthly backups retained for 12 months (offsite if policy allows but PHI must remain local-only per configuration).

Storage & encryption
- Backups stored on a separate physical volume with encrypted filesystem (LUKS) or on an encrypted NAS.
- Backups are also stored as compressed `pg_dump` files and encrypted with a symmetric key managed on-prem.

Retention & rotation
- Automatic pruning of backups older than retention policy.
- Regular restore validation (monthly test restore to a staging DB).

Access & key management
- Rotation of backup encryption keys annually.
- Keys stored in a secure on-prem secrets manager; only authorized admins have access.

Restores
- Restores are performed by the system admin following the documented restore steps in `scripts/restore_postgres.sh`.
- Always restore to a staging environment first and validate before switching production.

***

Contact: primary admin and backup officer listed in the runbook.
