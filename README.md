# Sunbird Garden - ProGalaxy eLabs Foundation Reference Platform

The canonical Docker-based platform template and reference implementation for all ProGalaxy eLabs projects. This foundation project demonstrates StoneScriptPHP in action and serves as the base template for new projects.

**Note:** While this package is published under `@progalaxyelabs`, the official StoneScriptPHP website and documentation are at https://stonescriptphp.org. A future migration to the `@stonescriptphp` namespace is planned.

**Location**: `/ssd2/projects/progalaxy-elabs/foundation/sunbird-garden/`
**Published**: `progalaxyelabs/sunbird-garden` (GitHub & Docker Hub)
**Website**: https://stonescriptphp.org

## Architecture

```
+-------------------------------------------------------------+
|                      Docker Compose                          |
+-------------+-------------+-------------+-------------------+
|     www     |     api     |    alert    |        db         |
|  Angular 19 | StoneScript |  Socket.IO  |   PostgreSQL 16   |
|    :4200    |   PHP :80   |    :3001    |       :5432       |
+-------------+-------------+-------------+-------------------+
|                     sunbird-network                          |
+-------------------------------------------------------------+
```

## Services

### 1. www (Frontend)
- **Tech**: Angular 19
- **Port**: 4200 (internal), 4400 (host)
- **Purpose**: SPA frontend with auto-generated API client

### 2. api (Backend)
- **Tech**: StoneScriptPHP (PHP 8.3)
- **Port**: 80 (internal), 4402 (host)
- **Purpose**: RESTful API with type-safe routes and DTOs
- **Features**: Auto-generated TypeScript client, migrations

### 3. alert (Notifications)
- **Tech**: Node.js 20 + Socket.IO
- **Port**: 3001 (internal), 4401 (host)
- **Purpose**: Real-time notifications and events

### 4. db (Database)
- **Tech**: PostgreSQL 16
- **Port**: 5432 (internal only)
- **Purpose**: Data persistence

## Quick Start

### Prerequisites
- Docker & Docker Compose
- PHP 8.3+ (for generating API client locally)
- Node.js 20+ (optional, for local development)

### Setup

```bash
# 1. Clone or copy the template
git clone git@bitbucket.org:progalaxyelabs/sunbird-garden.git myproject
cd myproject

# 2. Configure environment
cp .env.example .env
# Edit .env with your settings

# 3. Generate API client and build containers
./build.sh

# 4. Start all services
docker compose up

# 5. Access the application
# Frontend: http://localhost:4400
# API: http://localhost:4402
# Alert: http://localhost:4401
```

## Package Updates

Sunbird Garden includes a convenient update script for managing dependencies:

```bash
# Update StoneScriptPHP framework
./update.sh --stonescript

# Update Angular client library
./update.sh --ngx-client

# Update all packages (composer + npm)
./update.sh --all

# Check what's outdated without updating
./update.sh --check

# Update all and rebuild Docker containers
./update.sh --all --rebuild

# Show all available options
./update.sh --help
```

**Manual updates:**
```bash
# Update PHP packages (currently using progalaxyelabs namespace)
cd api && composer update progalaxyelabs/stonescriptphp

# Update npm packages (transitioning to @stonescriptphp/ngx-client)
cd www && npm update @stonescriptphp/ngx-client
```

For detailed update strategies and usage patterns, see **[USAGE.md](./USAGE.md)**.

**Learn more:** https://stonescriptphp.org/docs

## Development Workflow

### API Development

```bash
# Add a new route
cd api
php generate route post /users

# Edit DTOs
# api/src/App/DTO/UsersRequest.php
# api/src/App/DTO/UsersResponse.php

# Regenerate TypeScript client (IMPORTANT after route/DTO changes!)
php generate client --output=../www/api-client

# Rebuild frontend
cd ..
docker compose build www
docker compose restart www
```

### Frontend Development

```bash
cd www
npm install
npm start  # http://localhost:4200
```

### Database Migrations

```bash
# Run migrations
docker compose exec api php generate migrate up

# Check migration status
docker compose exec api php generate migrate status
```

## Creating a New Project from Template

```bash
./scripts/init-project.sh myproject /path/to/projects
```

This will:
1. Copy the template
2. Replace "sunbird" references with your project name
3. Initialize a fresh git repository

## Project Structure

```
sunbird-garden/
+-- README.md                   # This file
+-- docker-compose.yaml         # Service orchestration
+-- .env.example                # Environment template
+-- build.sh                    # Build script (correct order)
|
+-- api/                        # StoneScriptPHP backend
|   +-- Dockerfile
|   +-- Framework/              # Core framework
|   +-- src/App/                # Application code
|   |   +-- Routes/             # Route handlers
|   |   +-- Contracts/          # Interface contracts
|   |   +-- DTO/                # Request/Response DTOs
|   +-- database/migrations/    # SQL migrations
|   +-- generate                # CLI tool
|
+-- www/                        # Angular frontend
|   +-- Dockerfile
|   +-- src/app/
|   +-- api-client/             # Auto-generated from api
|
+-- alert/                      # Socket.IO service
|   +-- Dockerfile
|   +-- server.js
|
+-- docker/                     # Base Docker images
|   +-- alpine/
|   +-- debian-12v9-slim/
|
+-- docs/                       # Documentation
+-- scripts/                    # Helper scripts
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| APP_ENV | Environment (development/production) | development |
| DB_NAME | PostgreSQL database name | sunbird |
| DB_USER | PostgreSQL username | sunbird_user |
| DB_PASSWORD | PostgreSQL password | (required) |
| API_PORT | Host port for API | 4402 |
| WWW_PORT | Host port for frontend | 4400 |
| ALERT_PORT | Host port for alert service | 4401 |
| JWT_SECRET | JWT signing secret | (required) |

## Production Deployment

1. Update `.env` with production values
2. Generate secure keys for `JWT_SECRET` and `SESSION_SECRET`
3. Set `APP_ENV=production`
4. Configure proper HTTPS (use Traefik or nginx reverse proxy)
5. Set proper `CORS_ORIGIN`

```bash
docker compose -f docker-compose.yaml up -d
```

## Post-Merge Setup (One-Time)

After the v2 merge, complete these steps:

### 1. Add Bitbucket Remote and Push

```bash
git remote add origin git@bitbucket.org:progalaxyelabs/sunbird-garden.git
git push -u origin main
```

### 2. Archive ghbot-fullstack on GitHub

The ghbot-fullstack repository on GitHub is now superseded by this repo.
Either archive it or add a deprecation notice to its README.

### 3. Remove Backup Directories

After confirming everything works:

```bash
rm -rf sunbird-api.backup sunbird-frontend.backup
```

### 4. Update work-management Database

Run project scan to update sunbird-garden metadata:
```bash
# In work-management directory
mcp__work-management__scan_projects()
```

## License

Proprietary - ProGalaxy eLabs

## Support

Internal tool - contact the development team for support.
