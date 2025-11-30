# Sunbird Garden - Usage Guide

**Sunbird Garden** is a reference implementation platform showcasing the StoneScriptPHP framework with a modern full-stack architecture.

**Official Website:** https://stonescriptphp.org
**Documentation:** https://stonescriptphp.org/docs

## Table of Contents
- [What is Sunbird Garden?](#what-is-sunbird-garden)
- [Use Case 1: Standalone Deployment](#use-case-1-standalone-deployment)
- [Use Case 2: Foundation for Custom Projects](#use-case-2-foundation-for-custom-projects)
- [Keeping Updated](#keeping-updated)
- [Docker Image Versioning](#docker-image-versioning)
- [Architecture](#architecture)

---

## What is Sunbird Garden?

Sunbird Garden is a **complete full-stack platform** that provides:

- **Frontend:** Angular application with StoneScriptPHP client integration
- **Backend:** StoneScriptPHP (PHP) API with auto-generated TypeScript clients
- **Database:** PostgreSQL 16 with migrations
- **Notifications:** WebSocket-based alert/notification system (Node.js)
- **Docker Orchestration:** Production-ready docker-compose configuration

### Key Features

✅ **Contract-Based API** - PHP backend with TypeScript client auto-generation
✅ **Real-time Notifications** - WebSocket alert service
✅ **Database Migrations** - PostgreSQL with structured migration system
✅ **Health Checks** - Built-in health monitoring for all services
✅ **Production Ready** - Environment-based configuration
✅ **Dependency Management** - Composer (PHP) + npm (Angular) packages

---

## Use Case 1: Standalone Deployment

### When to Use This Approach

Use sunbird-garden as a **standalone package** when your project needs:

- A simple full-stack application (frontend + backend + database)
- WebSocket-based notifications/alerts
- Quick MVP or proof-of-concept
- All-in-one deployment without customization

### Quick Start

```bash
# 1. Clone the repository
cd /ssd2/projects/progalaxy-elabs/foundation/stonescriptphp/sunbird-garden/

# 2. Configure environment
cp .env.example .env
# Edit .env with your database credentials and API URLs

# 3. Start all services
docker compose up -d

# 4. Access the application
# Frontend: http://localhost:4400
# API: http://localhost:4402
# Alert Service: http://localhost:4401
```

### Services Included

| Service | Port | Technology | Purpose |
|---------|------|------------|---------|
| **www** | 4400 | Angular | Frontend application |
| **api** | 4402 | PHP (StoneScriptPHP) | Backend API |
| **alert** | 4401 | Node.js | WebSocket notifications |
| **db** | 5432 | PostgreSQL 16 | Database |

### Default Configuration

```yaml
# docker-compose.yaml
services:
  www:   # Angular frontend
  api:   # StoneScriptPHP backend
  alert: # Node.js WebSocket service
  db:    # PostgreSQL database
```

All services communicate via a shared Docker network (`sunbird-network`).

---

## Use Case 2: Foundation for Custom Projects

### When to Use This Approach

Use sunbird-garden as a **foundation** when:

- You need the StoneScriptPHP stack but with custom services
- You want to extend the base functionality
- You need to add project-specific services (e.g., Rust CLI, payment service)
- You want to reuse the database, auth, and framework setup

### Architecture Patterns

#### Pattern A: Git Submodule (Recommended)

**Best for:** Projects that extend sunbird-garden while staying updated with framework improvements.

```bash
# Add sunbird-garden as a submodule to your project
cd /your-project/
git submodule add /path/to/sunbird-garden sunbird-garden

# Your project structure:
your-project/
├── sunbird-garden/          # Git submodule (foundation)
│   ├── api/                 # StoneScriptPHP base
│   ├── www/                 # Angular base (optional)
│   ├── alert/               # WebSocket service (optional)
│   └── docker-compose.yaml
├── custom-api/              # Your custom API extensions
├── custom-www/              # Your custom frontend
├── custom-service/          # Your unique services
├── docker-compose.override.yml  # Orchestrates everything
└── .env
```

**Example: WebMeteor Platform**

```yaml
# webmeteor-platform/docker-compose.override.yml
services:
  # Reuse sunbird's PostgreSQL database
  db:
    extends:
      file: ./sunbird-garden/docker-compose.yaml
      service: db
    environment:
      POSTGRES_DB: webmeteor
      POSTGRES_USER: webmeteor
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "127.0.0.1:3074:5432"
    networks:
      - custom-network

  # Extend sunbird's API with custom routes
  api:
    build:
      context: ./custom-api
    volumes:
      - ./custom-api:/var/www/html
      - ./sunbird-garden/api:/var/www/sunbird-base:ro  # Mount as read-only base
    environment:
      DB_HOST: db
      DB_NAME: webmeteor
      SUNBIRD_BASE_PATH: /var/www/sunbird-base
    depends_on:
      - db
    ports:
      - "127.0.0.1:3071:80"
    networks:
      - custom-network

  # Add your unique services
  cli-server:
    build: ./custom-cli-server
    ports:
      - "127.0.0.1:3072:3072"
    networks:
      - custom-network

networks:
  custom-network:
    driver: bridge
```

**Update workflow:**
```bash
# Update sunbird-garden submodule to latest
cd sunbird-garden
git pull origin main
cd ..
git add sunbird-garden
git commit -m "Update sunbird-garden to latest"

# Your custom code remains unchanged
# Benefit from framework updates without breaking changes
```

#### Pattern B: Docker Image Extension

**Best for:** Creating derived platforms with consistent base infrastructure.

```dockerfile
# custom-api/Dockerfile
FROM sunbird-api:1.0.0 AS base

# Inherit StoneScriptPHP framework, dependencies, and configuration
# Add custom routes and functions
COPY ./custom-routes /var/www/html/src/routes/custom/
COPY ./custom-functions /var/www/html/src/functions/custom/

EXPOSE 3071
CMD ["php", "stone", "serve"]
```

```yaml
# docker-compose.yaml
services:
  api:
    build:
      context: ./custom-api
      args:
        SUNBIRD_VERSION: 1.0.0  # Pin to specific version
    ports:
      - "3071:3071"
```

#### Pattern C: Service Composition

**Best for:** Microservices architecture where each service is independent.

```yaml
# docker-compose.yaml
services:
  # Sunbird's database (shared infrastructure)
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - ./sunbird-garden/api/database/migrations:/docker-entrypoint-initdb.d
    networks:
      - app-network

  # Your custom API (uses sunbird's composer packages)
  custom-api:
    build: ./api
    environment:
      DB_HOST: db
    networks:
      - app-network

  # Your custom frontend (uses ngx-stonescriptphp-client npm package)
  custom-www:
    build: ./www
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

---

## Keeping Updated

Sunbird Garden provides a **convenient update script** (`update.sh`) to manage package updates, plus manual package manager options.

### Using the Update Script (Recommended)

Sunbird Garden includes an `update.sh` script that simplifies updating packages:

```bash
# Update StoneScriptPHP framework
./update.sh --stonescript

# Update Angular client library
./update.sh --ngx-client

# Update all packages (composer + npm)
./update.sh --all

# Check what's outdated without updating
./update.sh --check

# Update specific PHP package
./update.sh --php firebase/php-jwt

# Update specific npm package
./update.sh --npm @angular/core

# Update all and rebuild Docker containers
./update.sh --all --rebuild

# Show all options
./update.sh --help
```

**Features:**
- ✅ Update individual packages or all at once
- ✅ Shortcuts for StoneScriptPHP and ngx-stonescriptphp-client
- ✅ Check for outdated packages before updating
- ✅ Optional Docker container rebuild
- ✅ Colored output with clear status messages

### Framework Updates: Composer (PHP)

The StoneScriptPHP framework is distributed as a **Composer package**.

```json
// api/composer.json
{
  "name": "your-project/api",
  "require": {
    "progalaxyelabs/stonescriptphp": "^1.0",  // Semantic versioning
    "firebase/php-jwt": "^6.10"
  }
}
```

**Update workflow:**
```bash
cd api/
composer update progalaxyelabs/stonescriptphp  # Update framework
composer update                                 # Update all packages
```

### Client Library Updates: npm (Angular)

The Angular client library is distributed as an **npm package**.

```json
// www/package.json
{
  "name": "your-project-www",
  "dependencies": {
    "@stonescriptphp/ngx-client": "^1.0.0",  // Semantic versioning
    "@angular/core": "^19.0.0"
  }
}
```

**Update workflow:**
```bash
cd www/
npm update @stonescriptphp/ngx-client  # Update client
npm outdated                            # Check for updates
ng update @stonescriptphp/ngx-client   # Angular-aware update
```

### Database Schema Updates

Sunbird Garden uses **migration files** for database schema changes.

```bash
# api/database/migrations/
001_create_users_table.sql
002_create_sessions_table.sql
003_add_roles.sql  # New migration from sunbird update
```

**Update workflow:**
```bash
# After updating sunbird-garden submodule, run new migrations
docker compose exec db psql -U ${DB_USER} -d ${DB_NAME} -f /docker-entrypoint-initdb.d/003_add_roles.sql
```

---

## Docker Image Versioning

While Docker Compose doesn't have an "ng update" equivalent, you can manage versions using these strategies:

### Strategy 1: Semantic Versioning (Recommended)

**Pin specific versions in docker-compose.yaml:**

```yaml
services:
  db:
    image: postgres:16.1  # Specific version

  api:
    image: sunbird-api:1.2.3  # Semantic versioning

  www:
    image: sunbird-www:1.2.3
```

**Update workflow:**
```bash
# Manual version bump
# Edit docker-compose.yaml: sunbird-api:1.2.3 → sunbird-api:1.3.0

docker compose pull    # Pull updated images
docker compose up -d   # Recreate containers with new versions
```

### Strategy 2: Renovate Bot / Dependabot

Use automated dependency update tools that support Docker Compose.

**Example: Renovate configuration**

```json
// renovate.json
{
  "extends": ["config:base"],
  "dockerfile": {
    "enabled": true
  },
  "docker-compose": {
    "enabled": true,
    "fileMatch": ["(^|/)docker-compose[^/]*\\.ya?ml$"]
  },
  "packageRules": [
    {
      "matchDatasources": ["docker"],
      "matchPackageNames": ["postgres"],
      "allowedVersions": "16.x"  // Stay on major version 16
    },
    {
      "matchDatasources": ["docker"],
      "matchPackageNames": ["sunbird-api", "sunbird-www"],
      "automerge": true,
      "automergeType": "pr",
      "minimumReleaseAge": "3 days"
    }
  ]
}
```

Renovate will automatically create PRs when new Docker image versions are available.

### Strategy 3: Watchtower (Auto-Update)

**Automated container updates** (use cautiously in production).

```yaml
# docker-compose.yaml
services:
  watchtower:
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400  # Check daily
    environment:
      WATCHTOWER_CLEANUP: true
      WATCHTOWER_INCLUDE_RESTARTING: true
```

Watchtower automatically pulls and updates containers with `:latest` tags.

### Strategy 4: Version Catalog (Custom)

Create a **versions.env** file to centralize version management.

```bash
# versions.env
POSTGRES_VERSION=16.1
SUNBIRD_API_VERSION=1.2.3
SUNBIRD_WWW_VERSION=1.2.3
SUNBIRD_ALERT_VERSION=1.1.0
NODE_VERSION=20.10-alpine
```

```yaml
# docker-compose.yaml
services:
  db:
    image: postgres:${POSTGRES_VERSION}

  api:
    image: sunbird-api:${SUNBIRD_API_VERSION}

  www:
    image: sunbird-www:${SUNBIRD_WWW_VERSION}
```

**Update workflow:**
```bash
# Edit versions.env
SUNBIRD_API_VERSION=1.3.0

# Reload and update
docker compose --env-file versions.env up -d
```

### Comparison: Docker Versioning vs. Package Managers

| Aspect | npm/composer | Docker Compose |
|--------|-------------|----------------|
| **Version file** | package.json / composer.json | docker-compose.yaml + .env |
| **Lock file** | package-lock.json / composer.lock | No native equivalent |
| **Update command** | `npm update` / `composer update` | `docker compose pull` |
| **Semantic versioning** | ✅ Built-in (`^1.0.0`) | ⚠️ Manual (`image: foo:1.0.0`) |
| **Auto-update tools** | Renovate, Dependabot | Renovate, Dependabot, Watchtower |
| **Rollback** | `npm install <version>` | `docker compose down && up` with old version |

### Best Practice: Hybrid Approach

```yaml
# docker-compose.yaml
services:
  # Infrastructure: Pin major versions
  db:
    image: postgres:16  # Always use PostgreSQL 16.x (latest patch)

  # Application: Pin specific versions in production
  api:
    image: sunbird-api:${API_VERSION:-1.2.3}  # Default to 1.2.3
    build:
      context: ./api
      args:
        COMPOSER_VERSION: ${COMPOSER_VERSION:-2.6}

  www:
    image: sunbird-www:${WWW_VERSION:-1.2.3}
    build:
      context: ./www
      args:
        NODE_VERSION: ${NODE_VERSION:-20.10}
```

```bash
# .env
API_VERSION=1.2.3
WWW_VERSION=1.2.3
COMPOSER_VERSION=2.6
NODE_VERSION=20.10
```

**Update workflow:**
```bash
# 1. Update package dependencies first
cd api && composer update
cd www && npm update

# 2. Rebuild images with updated dependencies
docker compose build

# 3. Update version tags in .env
# API_VERSION=1.3.0

# 4. Deploy
docker compose up -d
```

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  WWW (Angular + ngx-stonescriptphp-client)                  │
│  - Auto-generated TypeScript API clients                    │
│  - Real-time WebSocket connection to alert service          │
│  Port: 4400                                                  │
└─────────────────────────┬───────────────────────────────────┘
                          │
              ┌───────────┴──────────┐
              │   HTTPS / REST API   │
              └───────────┬──────────┘
                          │
┌─────────────────────────────────────────────────────────────┐
│                   SERVICES LAYER                             │
├───────────────────┬─────────────────┬───────────────────────┤
│  API Service      │  Alert Service  │                       │
│  (StoneScriptPHP) │  (Node.js)      │                       │
│  Port: 4402       │  Port: 4401     │                       │
│                   │                 │                       │
│  - Auto-routes    │  - WebSocket    │                       │
│  - Type-safe API  │  - Pub/Sub      │                       │
│  - PostgreSQL     │  - Real-time    │                       │
└───────────────────┴─────────────────┴───────────────────────┘
                          │
              ┌───────────┴──────────┐
              │   PostgreSQL 16      │
              │   Port: 5432         │
              └──────────────────────┘
```

### Data Flow

1. **API Client Generation:**
   ```
   StoneScriptPHP (PHP) → Contract Definitions → TypeScript Generator →
   ngx-stonescriptphp-client (npm package) → Angular App
   ```

2. **Real-time Notifications:**
   ```
   Backend Event → Alert Service (WebSocket) → Frontend Listener → UI Update
   ```

3. **Database Operations:**
   ```
   Angular → HTTP Client → StoneScriptPHP API → PostgreSQL Function → Response
   ```

### Package Dependencies

```
Sunbird Garden Dependencies:

1. StoneScriptPHP Framework (Composer)
   └─> API Service

2. ngx-stonescriptphp-client (npm)
   └─> WWW Service (Angular)

3. PostgreSQL 16 (Docker)
   └─> Database Service

4. Node.js Runtime (Docker)
   └─> Alert Service
```

---

## Summary

**For simple projects:** Use sunbird-garden as-is with `docker compose up`.

**For custom projects:** Use Git submodules + package managers:
- **Quick updates:** `./update.sh --stonescript` or `./update.sh --ngx-client`
- **PHP updates:** `composer update progalaxyelabs/stonescriptphp`
- **Angular updates:** `npm update @stonescriptphp/ngx-client`
- **Docker images:** Pin versions in docker-compose.yaml + Renovate Bot

**Update workflow:** Sunbird Garden's `update.sh` script provides an "ng update"-like experience for managing framework and client library updates.

**Official Documentation:** https://stonescriptphp.org/docs

---

## Additional Resources

- **Official Website:** https://stonescriptphp.org
- **Documentation:** https://stonescriptphp.org/docs
- **StoneScriptPHP Framework:** `/foundation/stonescriptphp/StoneScriptPHP/`
- **Angular Client Library:** `/foundation/stonescriptphp/ngx-stonescriptphp-client/`
- **Example Projects:** See `webmeteor-platform` for Git submodule pattern
- **Project Info:** See `project-info.yaml` for metadata and configuration

**Questions?** Check the individual service README files in `api/`, `www/`, and `alert/` directories, or visit https://stonescriptphp.org/docs.
