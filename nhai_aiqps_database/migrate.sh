#!/bin/bash
set -euo pipefail

# NHAI AIQPS DB - Migration/Seed Flow
#
# Contract:
# - Inputs:
#   - db_connection.txt must exist and contain a working psql connection command like:
#       psql postgresql://user:pass@host:port/db
#   - ./migrations/*.sql must be "one statement per file" (single SQL statement).
#     (No semicolons required; if present, must still be a single statement.)
#   - ./seed/*.sql must be "one statement per file" and idempotent (ON CONFLICT/WHERE NOT EXISTS).
# - Outputs:
#   - Creates/updates database schema objects.
#   - Writes migration history in table public.schema_migrations.
# - Errors:
#   - Any SQL error stops execution (set -e).
# - Side effects:
#   - Creates tables/extensions/types/functions/triggers in the target DB.
#
# Usage:
#   ./migrate.sh migrate
#   ./migrate.sh seed
#   ./migrate.sh up   (migrate + seed)

CMD="${1:-up}"

if [ ! -f "db_connection.txt" ]; then
  echo "ERROR: db_connection.txt not found. Run startup.sh first."
  exit 1
fi

PSQL_CMD="$(cat db_connection.txt)"
if [ -z "${PSQL_CMD}" ]; then
  echo "ERROR: db_connection.txt is empty."
  exit 1
fi

run_sql() {
  local sql="$1"
  # -v ON_ERROR_STOP=1 makes psql fail on SQL errors
  ${PSQL_CMD} -v ON_ERROR_STOP=1 -q -c "$sql"
}

ensure_migrations_table() {
  run_sql "CREATE TABLE IF NOT EXISTS public.schema_migrations (version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now());"
}

apply_one_statement_file() {
  local file_path="$1"
  local version="$2"

  # Read raw statement; strip trailing whitespace/newlines.
  local stmt
  stmt="$(python3 - << 'PY'
import sys
p=sys.argv[1]
with open(p,'r',encoding='utf-8') as f:
    s=f.read().strip()
print(s)
PY
"$file_path")"

  if [ -z "${stmt}" ]; then
    echo "WARN: Empty migration file: ${file_path} (skipping)"
    return 0
  fi

  echo "Applying: ${version} (${file_path})"
  run_sql "${stmt}"
  run_sql "INSERT INTO public.schema_migrations(version) VALUES ('${version}') ON CONFLICT (version) DO NOTHING;"
}

apply_migrations() {
  ensure_migrations_table

  if [ ! -d "migrations" ]; then
    echo "No migrations directory found; skipping."
    return 0
  fi

  # Apply in lexicographic order.
  for f in $(ls -1 migrations/*.sql 2>/dev/null | sort); do
    local base
    base="$(basename "$f")"
    local version="${base%.sql}"

    local already
    already="$(${PSQL_CMD} -t -A -q -c "SELECT 1 FROM public.schema_migrations WHERE version='${version}' LIMIT 1;")"
    if [ "${already}" = "1" ]; then
      echo "Already applied: ${version}"
      continue
    fi

    apply_one_statement_file "$f" "$version"
  done
}

apply_seed() {
  if [ ! -d "seed" ]; then
    echo "No seed directory found; skipping."
    return 0
  fi

  echo "Seeding (idempotent statements)..."
  for f in $(ls -1 seed/*.sql 2>/dev/null | sort); do
    local stmt
    stmt="$(python3 - << 'PY'
import sys
p=sys.argv[1]
with open(p,'r',encoding='utf-8') as f:
    s=f.read().strip()
print(s)
PY
"$f")"
    if [ -z "${stmt}" ]; then
      echo "WARN: Empty seed file: ${f} (skipping)"
      continue
    fi
    echo "Seed: $(basename "$f")"
    run_sql "${stmt}"
  done
}

case "${CMD}" in
  migrate)
    apply_migrations
    ;;
  seed)
    apply_seed
    ;;
  up)
    apply_migrations
    apply_seed
    ;;
  *)
    echo "Usage: $0 {migrate|seed|up}"
    exit 1
    ;;
esac

echo "OK: migrate.sh ${CMD} complete"
