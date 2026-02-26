# NHAI AIQPS Database Migrations & Seed Strategy

## Goals
- Consistent, repeatable DB initialization for dev and CI.
- Idempotent schema setup: safe to run multiple times.
- No external migration framework required.

## How it works
- `startup.sh` starts PostgreSQL, ensures DB/user permissions, writes `db_connection.txt`, then runs:
  - `./migrate.sh up`
- `migrate.sh`:
  - Reads the connection command from `db_connection.txt` (authoritative).
  - Ensures `public.schema_migrations` exists.
  - Applies `migrations/*.sql` in lexicographic order, only once per version.
  - Executes `seed/*.sql` in lexicographic order (must be idempotent).

## File format rule (important)
Each file under `migrations/` and `seed/` must contain **exactly one SQL statement**.

Reason: container operational rule requires executing SQL statements one-at-a-time via `psql -c`.

## Seed data guidance
Seed scripts must be safe to rerun:
- Prefer `INSERT ... ON CONFLICT DO NOTHING`
- or `INSERT ... SELECT ... WHERE NOT EXISTS (...)`

## Notes on security
- `users.password_hash` stores the hash only; never store plaintext passwords.
- `mfa_devices.secret_encrypted` should be encrypted at the application layer with managed keys.
- `audit_log` is append-only by convention; enforce immutability in application logic or add DB policies later.
