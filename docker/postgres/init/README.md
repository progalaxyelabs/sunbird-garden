# PostgreSQL Initialization Scripts

This directory is mounted to `/docker-entrypoint-initdb.d/` in the PostgreSQL container.

## Usage

Place SQL or shell scripts here that should run when the database is first initialized:

- `*.sql` - SQL scripts (executed in alphabetical order)
- `*.sh` - Shell scripts (executed in alphabetical order)

## Execution Order

Scripts are executed in alphabetical order. Use numeric prefixes for control:

```
01-create-extensions.sql
02-create-schemas.sql
03-seed-data.sql
```

## Example: Enable Extensions

Create `01-extensions.sql`:

```sql
-- Enable commonly used PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";
```

## Notes

- Scripts only run on **first initialization** (when the database is empty)
- To re-run scripts, delete the PostgreSQL volume: `docker compose down -v`
- Scripts run as the `postgres` superuser
- Environment variables from docker-compose.yaml are available
