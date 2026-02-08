# Docker Compose Configuration Guide

This document explains the Docker Compose setup for the Sunbird Garden stack.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Host Machine (127.0.0.1)                 │
├─────────────────────────────────────────────────────────────┤
│  :4400 (www)    :4402 (api)    :4401 (alert)                │
│     ↓               ↓               ↓                        │
├─────────────────────────────────────────────────────────────┤
│              Internal Docker Network (172.20.0.0/16)         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   www    │  │   api    │  │  alert   │  │    db    │   │
│  │ Angular  │  │   PHP    │  │ Node.js  │  │PostgreSQL│   │
│  │   :80    │  │   :80    │  │  :3001   │  │  :5432   │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
│       └─────────────┴──────────────┴─────────────┘          │
│                    All services can communicate              │
└─────────────────────────────────────────────────────────────┘

Volumes:
- postgres_data        → /var/lib/postgresql/data (database persistence)
- api_logs            → /var/www/html/storage/logs (API logs)
- www_node_modules    → /app/node_modules (cached dependencies)
- www_dist            → /app/dist (build artifacts)
- alert_node_modules  → /app/node_modules (cached dependencies)
```

## Security Features

### 1. Port Binding to Localhost Only

All services are bound to `127.0.0.1` (localhost), meaning they're **only accessible from the host machine**:

```yaml
ports:
  - "127.0.0.1:4400:80"  # www service
  - "127.0.0.1:4402:80"  # api service
  - "127.0.0.1:4401:3001" # alert service
```

This prevents external access from the network. To allow external access in production, you should:
- Use a reverse proxy (nginx, Traefik, Caddy)
- Configure HTTPS/SSL
- Set up proper firewall rules

### 2. Internal Database

The PostgreSQL database has **no external ports** exposed:

```yaml
db:
  # No ports section - completely internal
```

It's only accessible to other services within the `internal` Docker network.

### 3. Private Docker Network

All services communicate through a private bridge network with a dedicated subnet:

```yaml
networks:
  internal:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

## Services

### 1. Database (db)

**Image**: `postgres:16-alpine`
**Internal Port**: 5432 (not exposed to host)
**Network**: internal

Environment variables:
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database password

Volume mounts:
- `postgres_data:/var/lib/postgresql/data` - Data persistence
- `./docker/postgres/init:/docker-entrypoint-initdb.d:ro` - Initialization scripts

Health check:
- Command: `pg_isready -U {user} -d {database}`
- Interval: 10s
- Retries: 5
- Start period: 30s

### 2. API (api)

**Build Context**: `./api`
**Host Port**: `127.0.0.1:4402`
**Internal Port**: 80
**Network**: internal

Environment variables:
- `APP_ENV` - Application environment (development/production)
- `DB_HOST=db` - Database hostname (internal network)
- `DB_PORT=5432`
- `JWT_SECRET` - JWT signing secret
- `CORS_ORIGIN` - Allowed CORS origin

Volume mounts:
- `./api:/var/www/html` - Source code (development)
- `api_logs:/var/www/html/storage/logs` - Log persistence

Dependencies:
- Waits for `db` to be healthy before starting

Health check:
- Command: `curl -f http://localhost/health`
- Interval: 30s
- Start period: 40s

### 3. Frontend (www)

**Build Context**: `./www`
**Host Port**: `127.0.0.1:4400`
**Internal Port**: 80
**Network**: internal

Build arguments:
- `NODE_VERSION` - Node.js version (default: 20)
- `API_URL` - API endpoint URL
- `ALERT_URL` - Alert service URL

Volume mounts:
- `./www:/app` - Source code
- `www_node_modules:/app/node_modules` - Cached dependencies
- `www_dist:/app/dist` - Build output

Dependencies:
- Waits for `api` to start

### 4. Alert Service (alert)

**Build Context**: `./alert`
**Host Port**: `127.0.0.1:4401`
**Internal Port**: 3001
**Network**: internal

Environment variables:
- `ALERT_PORT=3001` - Service port
- `CORS_ORIGINS` - Allowed CORS origins
- `DB_HOST=db` - Database access (if needed)

Volume mounts:
- `./alert:/app` - Source code
- `alert_node_modules:/app/node_modules` - Cached dependencies

Dependencies:
- Waits for `db` to be healthy before starting

## Common Operations

### Start All Services

```bash
docker compose up -d
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f db
```

### Stop Services

```bash
docker compose down
```

### Rebuild and Restart

```bash
docker compose up -d --build
```

### Execute Commands in Containers

```bash
# API container
docker compose exec api bash
docker compose exec api php artisan migrate

# Database
docker compose exec db psql -U sunbird_user -d sunbird_db

# Frontend
docker compose exec www sh
docker compose exec www npm install

# Alert service
docker compose exec alert sh
docker compose exec alert npm install
```

### Reset Everything (Including Data)

**WARNING**: This deletes all data!

```bash
docker compose down -v
```

### View Service Status

```bash
docker compose ps
```

### Inspect Networks

```bash
docker network ls
docker network inspect sunbird_internal
```

## Volume Management

### List Volumes

```bash
docker volume ls | grep sunbird
```

### Backup Database

```bash
# Export database
docker compose exec db pg_dump -U sunbird_user sunbird_db > backup.sql

# Import database
docker compose exec -T db psql -U sunbird_user -d sunbird_db < backup.sql
```

### Clean Up Unused Volumes

```bash
docker volume prune
```

## Environment Variables

All services read from the `.env` file in the project root. Key variables:

```bash
# Project
PROJECT_NAME=sunbird           # Affects container and volume names

# Database
DB_NAME=sunbird_db
DB_USER=sunbird_user
DB_PASSWORD=<secure-password>

# Service Ports (on 127.0.0.1)
API_PORT=4402
WWW_PORT=4400
ALERT_PORT=4401

# Security
JWT_SECRET=<secure-secret>

# CORS
CORS_ORIGIN=http://localhost:4400

# Application
APP_ENV=development            # or "production"
LOG_LEVEL=info
```

## Production Deployment

### 1. Update Environment Variables

```bash
APP_ENV=production
DB_PASSWORD=<strong-random-password>
JWT_SECRET=<strong-random-secret>
CORS_ORIGIN=https://yourdomain.com
```

### 2. Use a Reverse Proxy

Create `docker-compose.prod.yaml`:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    networks:
      - internal
    depends_on:
      - www
      - api
```

Run with:
```bash
docker compose -f docker-compose.yaml -f docker-compose.prod.yaml up -d
```

### 3. Enable SSL/HTTPS

Use Let's Encrypt with Certbot or Traefik for automatic SSL.

### 4. Disable Debug Mode

```bash
APP_DEBUG=false
```

### 5. Set Network to Internal (Optional)

If your services don't need internet access:

```yaml
networks:
  internal:
    internal: true  # Blocks internet access
```

## Troubleshooting

### Database Connection Refused

```bash
# Check if database is running
docker compose ps db

# Check database logs
docker compose logs db

# Verify health
docker compose exec db pg_isready -U sunbird_user
```

### Port Already in Use

```bash
# Find process using the port
sudo lsof -i :4402

# Or change port in .env
API_PORT=5002
```

### Permission Denied Errors

```bash
# Fix ownership of volumes
docker compose exec api chown -R www-data:www-data /var/www/html/storage
```

### Container Won't Start

```bash
# View full logs
docker compose logs api

# Rebuild without cache
docker compose build --no-cache api
docker compose up -d api
```

### Network Issues

```bash
# Recreate network
docker compose down
docker network prune
docker compose up -d
```

## Development Tips

### Hot Reload

All services mount source code as volumes, enabling hot reload:
- **API**: PHP files reload automatically
- **Frontend**: Use dev server for hot module replacement
- **Alert**: Use nodemon for auto-restart

### Local Development Without Docker

You can run individual services locally:

```bash
# API (requires PHP 8.3+, PostgreSQL)
cd api
composer install
php artisan serve

# Frontend (requires Node.js 20+)
cd www
npm install
npm run dev

# Alert (requires Node.js 20+)
cd alert
npm install
npm run dev
```

Set environment variables to point to localhost services.

## Health Checks

All services include health checks that Docker uses to determine readiness:

- **db**: `pg_isready` check every 10s
- **api**: HTTP GET to `/health` every 30s
- **www**: HTTP GET to `/` or `/health` every 30s
- **alert**: HTTP GET to `/health` every 30s

View health status:
```bash
docker compose ps
```

## PostgreSQL Initialization

Place initialization scripts in `docker/postgres/init/`:

```sql
-- docker/postgres/init/01-extensions.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

Scripts run **only on first initialization**. To re-run:
```bash
docker compose down -v
docker compose up -d
```

## Resource Limits

To limit resource usage, add to services:

```yaml
services:
  db:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          memory: 512M
```
