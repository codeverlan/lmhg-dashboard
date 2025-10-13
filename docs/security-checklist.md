# On-prem Security Checklist (LMHG)

This checklist contains recommended steps and controls for deploying LMHG on-premises with HIPAA considerations.

1. Network and perimeter
- Harden firewall: allow only required ports (443, 80 if needed, SSH from admin IPs).
- Place the application server behind a reverse proxy (nginx/traefik) that terminates TLS.
- Use VLANs or network segmentation to separate the DB and storage.

2. TLS & keys
- Use valid certificates from a CA for production. Keep private keys in a secure store.
- For local testing, use self-signed certs only.

3. Authentication & accounts
- Enforce MFA for staff accounts accessing PHI.
- Use strong password policies and PBKDF/Argon2 hashing.
- Periodic review and removal of inactive accounts.

4. Data protection
- Encrypt data at rest for DB and object storage.
- Ensure `hipaa_exempt` flags are enforced correctly before any data leaves the local environment.

5. Auditing & logging
- Centralize logs and use immutable storage for audit logs.
- Log all access to PHI and high-privilege actions.

6. Backups
- Automated local backups of Postgres. Keep a retention policy and periodic restores tests.
- Encrypt backups and limit access.

7. Monitoring
- Error tracking (Sentry), metrics (Prometheus/Grafana), and alerting for failures and suspicious activity.

8. Vulnerability management
- Keep OS and dependencies up to date. Apply security patches within SLA.
- Run periodic vulnerability scans and address critical findings.

9. Incident response
- Maintain an incident response plan and run tabletop exercises.
- Contact and escalation list for security incidents.

10. Compliance
- If HIPAA applies, maintain required documentation, BAAs with vendors, and regular audits.

***

Refer to `openspec/project.md` for the implementation departures and policy-level decisions.
