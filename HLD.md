# Sunbird Garden - High Level Design Document

**Version:** 1.1
**Date:** 2026-01-13
**Status:** Active
**Project Type:** Platform (Multi-Service)

---

## 1. Overview

Sunbird Garden is a complete full-stack platform reference implementation that demonstrates how to build production-ready applications using the StoneScriptPHP framework. It showcases best practices for modern full-stack development with a microservices architecture.

### Purpose
- Serve as a reference implementation for the StoneScriptPHP framework
- Demonstrate production-ready full-stack architecture patterns
- Provide a scaffolding tool for new StoneScriptPHP projects
- Showcase integration between Angular, StoneScriptPHP (PHP), and PostgreSQL
- Illustrate real-time notification implementation via WebSocket

### Target Users
- Developers learning StoneScriptPHP framework
- Teams starting new full-stack projects with StoneScriptPHP
- Developers looking for microservices architecture examples
- Contributors to the StoneScriptPHP ecosystem

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   HOST MACHINE (127.0.0.1)                       │
│              http://localhost:4400 (www)                         │
│              http://localhost:4402 (api)                         │
│              http://localhost:4401 (alert)                       │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│              DOCKER NETWORK (172.20.0.0/16)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  WWW SERVICE (Angular)                Port 4400 → :80    │  │
│  │  - Angular 18 SPA                                         │  │
│  │  - StoneScript UI                                         │  │
│  │  - Auto-generated TypeScript API clients                 │  │
│  │  - WebSocket connection to Alert service                 │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│                         ↓ HTTP/REST                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  API SERVICE (StoneScriptPHP)     Port 4402 → :80        │  │
│  │  - PHP 8.3 with StoneScriptPHP framework                 │  │
│  │  - RESTful API endpoints                                 │  │
│  │  - JWT authentication                                     │  │
│  │  - Database function abstraction                         │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ALERT SERVICE (Node.js)      Port 4401 → :3001          │  │
│  │  - Express + Socket.IO                                    │  │
│  │  - Real-time notifications                                │  │
│  │  - WebSocket pub/sub                                      │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│                         ↓ PostgreSQL Protocol                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DATABASE SERVICE (PostgreSQL 16)   Port :5432 (internal)│  │
│  │  - PostgreSQL 16 Alpine                                   │  │
│  │  - Stored procedures for business logic                  │  │
│  │  - Persistent volume: postgres_data                      │  │
│  │  - Initialization scripts support                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DOCKER VOLUMES                                │
├─────────────────────────────────────────────────────────────────┤
│  • postgres_data        → Database persistence                  │
│  • api_logs             → API logs                              │
│  • www_node_modules     → Frontend dependencies cache           │
│  • www_dist             → Frontend build artifacts              │
│  • alert_node_modules   → Alert service dependencies cache      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Tech Stack

### Frontend Service (sunbird-frontend)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Framework | Angular | 18.2.0 | SPA framework for building dynamic UI |
| UI Framework | Bootstrap | 5.3.3 | Responsive CSS framework |
| Language | TypeScript | 5.5.2 | Type-safe JavaScript superset |
| State Management | RxJS | 7.8.0 | Reactive programming for async operations |
| Build Tool | Angular CLI | 18.2.1 | Development and build toolchain |
| Testing | Jasmine + Karma | 5.2.0 / 6.4.0 | Unit testing framework |

### Backend Service (sunbird-api)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Language | PHP | 8.x | Server-side scripting language |
| Framework | Custom MVC | 0.2.0 | Minimalistic routing and controller framework |
| Database | PostgreSQL | Latest | Primary data store with stored procedures |
| Authentication | firebase/php-jwt | 6.10 | JWT token generation and validation |
| Excel Export | phpoffice/phpspreadsheet | 2.0 | Generate Excel files for data export |
| Email Service | ZeptoMail | N/A | Transactional email delivery |
| Web Server | Apache2 | Latest | HTTP server with mod_php |

### Development & Deployment

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Container | Docker | Latest | Containerized deployment |
| Base Image | Debian | 12.10-slim | Lightweight Linux distribution |
| Node.js | NVM + Node | 20.17.0 | JavaScript runtime for build tools |
| Version Control | Git | Latest | Source code management |

---

## 4. Services Table

| Service Name | Type | Port (Host→Container) | Technology | Purpose | Status |
|-------------|------|------|------------|---------|--------|
| **www** | Frontend SPA | 4400→80 | Angular 18 + TypeScript + StoneScript UI | Web application demonstrating StoneScriptPHP client integration | Active |
| **api** | Backend API | 4402→80 | PHP 8.3 + StoneScriptPHP | RESTful API with auto-generated TypeScript clients, JWT auth, PostgreSQL integration | Active |
| **alert** | Notification Service | 4401→3001 | Node.js 20 + Express + Socket.IO | Real-time WebSocket notifications and alerts | Active |
| **db** | Database | Internal :5432 | PostgreSQL 16 Alpine | Data persistence with stored procedures, no external ports | Active |

### Service Dependencies

```
www (Angular)
    ├─► api (HTTP/REST)
    │   └─► db (PostgreSQL)
    │       └─► JWT Authentication (firebase/php-jwt)
    │       └─► Email (Optional: ZeptoMail)
    │       └─► Excel Export (Optional: PHPSpreadsheet)
    └─► alert (WebSocket)
        └─► db (PostgreSQL - optional)
```

---

## 5. Data Model

### Database Schema (PostgreSQL)

The database schema is defined through migration scripts located in `docker/postgres/init/`. As a reference implementation, the actual schema will vary based on the specific application being built.

#### Example Core Tables

```sql
-- Users Table (Example)
users (
    user_id: SERIAL PRIMARY KEY,
    name: TEXT NOT NULL,
    email: TEXT NOT NULL,
    is_email_verified: BOOLEAN DEFAULT FALSE,
    email_verified_on: TIMESTAMPTZ NULL,
    created_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
)

-- Sessions Table (Example)
sessions (
    session_id: SERIAL PRIMARY KEY,
    user_id: INTEGER REFERENCES users(user_id),
    token: TEXT NOT NULL,
    created_at: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at: TIMESTAMPTZ NOT NULL,
    ip_address: TEXT,
    user_agent: TEXT
)
```

### StoneScriptPHP Pattern

The platform follows the StoneScriptPHP database-first pattern:
- Business logic resides in PostgreSQL stored procedures
- PHP functions are auto-generated from SQL functions
- Type-safe database calls through generated models
- TypeScript client interfaces auto-generated for frontend

### API Response Model

The StoneScriptPHP framework uses a standardized API response format:

```php
class ApiResponse {
    string $status;      // 'ok', 'error', 'warning'
    string $message;     // Human-readable message
    array $data;         // Response payload
    int $httpCode;       // HTTP status code
}
```

---

## 6. Key Features

### Platform Features
1. **Microservices Architecture**
   - Independent containerized services (www, api, alert, db)
   - Docker Compose orchestration
   - Health checks for all services
   - Internal Docker network isolation
   - Volume management for persistence and caching

2. **Development Experience**
   - Hot reload for all services (volume mounts)
   - Consistent environment across development and production
   - One-command setup: `docker compose up -d`
   - Comprehensive documentation (README, USAGE, DOCKER, HLD)

### StoneScriptPHP Backend Features
1. **Database-First Development**
   - Business logic in PostgreSQL stored procedures
   - Auto-generation of PHP models from SQL functions
   - Auto-generation of TypeScript clients for frontend
   - Type-safe database calls throughout the stack

2. **RESTful API**
   - Reflection-based request parsing
   - Automatic route generation
   - Standardized API response format
   - Built-in error handling

3. **Authentication & Security**
   - JWT-based authentication (firebase/php-jwt)
   - Token generation and validation
   - CORS configuration
   - Secure environment variable management

4. **Optional Integrations**
   - Email service integration (ZeptoMail)
   - Excel export capability (PHPSpreadsheet)
   - Extensible for additional services

### Frontend Features
1. **Modern Angular Application**
   - Angular 18 with standalone components
   - TypeScript for type safety
   - Auto-generated API client from backend
   - Reactive programming with RxJS

2. **StoneScript UI Integration**
   - Demonstrates StoneScriptPHP client library usage
   - Type-safe API calls
   - Consistent error handling
   - HTTP interceptors for authentication

### Real-time Notifications
1. **Alert Service (Node.js + Socket.IO)**
   - WebSocket-based real-time communication
   - Pub/sub pattern for notifications
   - HTTP endpoint for triggering alerts
   - Health monitoring endpoint

---

## 7. Integrations

### Current Integrations

| Service | Purpose | Integration Type | Status |
|---------|---------|------------------|--------|
| **PostgreSQL** | Primary database | Direct connection | Active |
| **Firebase PHP JWT** | Authentication | PHP Library | Active |
| **ZeptoMail** | Transactional emails | REST API | Active |
| **PHPSpreadsheet** | Excel generation | PHP Library | Active |

### Integration Flow

```
Frontend (Angular)
    │
    ├─► Forms Service (In-Memory) ──► Local form state management
    │
    └─► HTTP Client ──► Backend API ──┬─► PostgreSQL (Data persistence)
                                       ├─► JWT (Auth validation)
                                       ├─► ZeptoMail (Email notifications)
                                       └─► PHPSpreadsheet (Export data)
```

---

## 8. External Dependencies

### NPM Packages (Frontend)

| Package | Version | Purpose | Critical |
|---------|---------|---------|----------|
| `@angular/core` | 18.2.0 | Core Angular framework | Yes |
| `@angular/forms` | 18.2.0 | Form handling and validation | Yes |
| `@angular/router` | 18.2.0 | SPA routing | Yes |
| `bootstrap` | 5.3.3 | UI styling | No |
| `rxjs` | 7.8.0 | Reactive programming | Yes |
| `typescript` | 5.5.2 | Type system | Yes |
| `zone.js` | 0.14.10 | Angular change detection | Yes |

### Composer Packages (Backend)

| Package | Version | Purpose | Critical |
|---------|---------|---------|----------|
| `firebase/php-jwt` | 6.10 | JWT token handling | Yes |
| `phpoffice/phpspreadsheet` | 2.0 | Excel file generation | No |

### System Dependencies

| Package | Version | Purpose | Critical |
|---------|---------|---------|----------|
| PHP | 8.x | Backend runtime | Yes |
| PostgreSQL | Latest | Database | Yes |
| Apache2 | Latest | Web server | Yes |
| Node.js | 20.17.0 | Build tools | Yes |
| Angular CLI | 18 | Development CLI | Yes |

---

## 9. Deployment

### Deployment Architecture

**Environment:** Docker Compose Multi-Service Setup

```
Docker Compose Stack (sunbird)
    ├── www Service (Angular)
    │   ├── Base: Node.js 20 Alpine
    │   ├── Build: Angular production build
    │   ├── Serve: nginx or dev server
    │   └── Port: 127.0.0.1:4400 → :80
    │
    ├── api Service (StoneScriptPHP)
    │   ├── Base: PHP 8.3 with Apache
    │   ├── Extensions: pgsql, curl, mbstring, etc.
    │   ├── Dependencies: composer install
    │   └── Port: 127.0.0.1:4402 → :80
    │
    ├── alert Service (Node.js)
    │   ├── Base: Node.js 20 Alpine
    │   ├── Framework: Express + Socket.IO
    │   ├── Dependencies: npm install
    │   └── Port: 127.0.0.1:4401 → :3001
    │
    ├── db Service (PostgreSQL)
    │   ├── Image: postgres:16-alpine
    │   ├── Initialization: docker/postgres/init/
    │   ├── Volume: postgres_data
    │   └── Port: Internal :5432 only
    │
    └── Internal Network: 172.20.0.0/16
```

### Quick Start Deployment

#### 1. Setup Environment
```bash
# Clone repository
git clone https://github.com/progalaxyelabs/sunbird-garden.git
cd sunbird-garden

# Configure environment
cp .env.example .env
# Edit .env and set:
# - DB_PASSWORD (strong password)
# - JWT_SECRET (strong secret key)
# - Other settings as needed
```

#### 2. Start Services
```bash
# Start all services
docker compose up -d

# Verify all services are healthy
docker compose ps

# View logs
docker compose logs -f
```

#### 3. Access Services
- Frontend: http://localhost:4400
- API: http://localhost:4402
- Alert Service: http://localhost:4401

### Environment Variables

See `.env.example` for all available configuration options:

```bash
# Project
PROJECT_NAME=sunbird

# Database
DB_NAME=sunbird_db
DB_USER=sunbird_user
DB_PASSWORD=<secure-password>

# Service Ports
API_PORT=4402
WWW_PORT=4400
ALERT_PORT=4401

# Security
JWT_SECRET=<secure-secret>

# CORS
CORS_ORIGIN=http://localhost:4400

# Application
APP_ENV=development
```

### Production Deployment

1. **Update Environment**
   ```bash
   APP_ENV=production
   APP_DEBUG=false
   # Use strong passwords and secrets
   ```

2. **Add Reverse Proxy**
   - Use nginx, Traefik, or Caddy
   - Configure SSL/HTTPS
   - Set up proper domain routing

3. **Security Hardening**
   - Change default ports
   - Use strong passwords
   - Enable firewall rules
   - Regular security updates

4. **Monitoring**
   - Configure log aggregation
   - Set up health check monitoring
   - Enable alerting for service failures

---

## 10. Shared Libraries Used

### Custom Framework (Backend)

The `sunbird-api` service uses a custom minimalistic PHP framework located in `/Framework/`:

| Component | File | Purpose |
|-----------|------|---------|
| **Router** | `Router.php` | Reflection-based HTTP routing system |
| **Database** | `Database.php` | PostgreSQL connection and query abstraction |
| **Logger** | `Logger.php` | Application logging |
| **Environment** | `Env.php` | Environment variable management |
| **Exceptions** | `Exceptions.php` | Custom exception handling |
| **Bootstrap** | `bootstrap.php` | Application initialization |
| **Error Handler** | `error_handler.php` | Global error handling |
| **Route Interface** | `IRouteHandler.php` | Interface for route handlers |

### CLI Tools (Backend)

| Tool | Purpose |
|------|---------|
| `generate-model.php` | Auto-generate PHP models from PostgreSQL functions |
| `generate-route.php` | Scaffold new route handlers |
| `dba.php` | Database administration utility |

### Common Patterns

1. **Database Functions Pattern**
   - SQL functions stored in `App/Database/postgresql/functions/`
   - PHP models auto-generated in `App/Database/Functions/`
   - Models call PostgreSQL stored procedures directly

2. **Route Handler Pattern**
   ```php
   class SomeRoute implements IRouteHandler {
       public function process() {
           // Parse request using reflection
           $data = FnSomeFunction::run($this->param1, $this->param2);
           return new ApiResponse('ok', '', ['data' => $data]);
       }
   }
   ```

3. **Frontend Service Pattern**
   - Services use RxJS observables
   - HTTP interceptors for auth tokens
   - Centralized error handling

---

## 11. Related Projects

### Progalaxy E-Labs Ecosystem

Sunbird Garden is part of the Progalaxy E-Labs project portfolio:

| Project | Relationship | Integration Points |
|---------|--------------|-------------------|
| **Work Management Tool** | Sibling Project | None currently |
| **Common Modules** | Potential Future | Shared auth, UI components |
| **Other Tools** | Sibling Projects | Potential shared backend framework |

### Reusable Components

The following components could be extracted as shared libraries:

1. **Custom PHP MVC Framework** (`/Framework/`)
   - Lightweight alternative to Laravel/Symfony
   - PostgreSQL-first approach
   - Could be packaged as Composer library

2. **Angular Dynamic Form Engine** (`/lib/dynamic-form.ts`)
   - Generic form builder components
   - Could be published as NPM package
   - Reusable across multiple projects

3. **Docker Development Environment**
   - Debian-based PHP+Angular+PostgreSQL stack
   - Could be template for other projects

---

## 12. Constraints

### Technical Constraints

1. **StoneScriptPHP Framework**
   - Database-first approach requires PostgreSQL
   - Business logic in stored procedures (less portable)
   - Auto-generated code requires regeneration on schema changes

2. **Docker Dependencies**
   - Requires Docker and Docker Compose
   - Services tightly coupled through docker-compose configuration
   - Local development requires Docker environment

3. **Database Constraints**
   - Tightly coupled to PostgreSQL 16
   - Business logic in stored procedures
   - Migration scripts in docker/postgres/init/ run only on first initialization

4. **Authentication**
   - JWT tokens only (no OAuth/SAML by default)
   - Basic authentication implementation
   - Extension required for advanced auth patterns

5. **Scalability**
   - Single-server docker-compose setup
   - No built-in load balancing
   - Horizontal scaling requires Kubernetes or Swarm
   - No caching layer by default

### Business Constraints

1. **License**
   - MIT License (Open Source)
   - Free to use and modify
   - See LICENSE file for details

2. **Development Status**
   - Active maintenance
   - Reference implementation (not production app)
   - Documentation-focused
   - Example/template purpose

3. **Scope**
   - Reference implementation, not a complete application
   - Demonstrates patterns, not full features
   - Requires customization for production use

---

## 13. Technical Debt

As a reference implementation, this section documents areas for improvement that adopters should consider when building production applications.

### Documentation Improvements

1. **API Documentation**
   - **Issue:** No OpenAPI/Swagger documentation
   - **Impact:** Developers need to read code to understand API
   - **Recommendation:** Add Swagger/OpenAPI spec generation

2. **Code Examples**
   - **Issue:** Limited code examples for common use cases
   - **Impact:** Slower adoption and learning curve
   - **Recommendation:** Add more example implementations

### Testing Infrastructure

3. **Automated Testing**
   - **Issue:** No test suite included
   - **Impact:** Reference implementations should show testing best practices
   - **Recommendation:** Add example tests (PHPUnit for PHP, Jest for Angular, Mocha for Node.js)

4. **CI/CD Pipeline**
   - **Issue:** No example CI/CD configuration
   - **Impact:** Deployers must configure from scratch
   - **Recommendation:** Add GitHub Actions or GitLab CI examples

### Production Readiness

5. **Monitoring & Observability**
   - **Issue:** No built-in monitoring or logging aggregation
   - **Impact:** Difficult to troubleshoot production issues
   - **Recommendation:** Add example Prometheus/Grafana or ELK stack integration

6. **Backup & Recovery**
   - **Issue:** No documented backup procedures
   - **Impact:** Data loss risk
   - **Recommendation:** Document PostgreSQL backup strategies

7. **Performance Optimization**
   - **Issue:** No caching layer, query optimization examples
   - **Impact:** May not scale well under load
   - **Recommendation:** Add Redis example, query optimization patterns

8. **Security Hardening**
   - **Issue:** Basic security implementation
   - **Impact:** Production deployments need additional hardening
   - **Recommendation:** Document security best practices, rate limiting, etc.

### Known Limitations

9. **Horizontal Scaling**
   - **Issue:** Docker Compose single-server setup
   - **Impact:** Not suitable for high-availability deployments
   - **Recommendation:** Provide Kubernetes deployment examples

10. **Database Migrations**
    - **Issue:** Init scripts run only once on first startup
    - **Impact:** Schema changes require manual intervention
    - **Recommendation:** Add migration tool example (Flyway, Liquibase)

---

## Appendix

### A. File Structure

```
sunbird-garden/
├── docker/                          # Docker configurations
│   └── postgres/
│       └── init/                    # PostgreSQL initialization scripts
├── api/                             # Backend StoneScriptPHP service
│   ├── Dockerfile
│   ├── composer.json               # PHP dependencies
│   ├── src/                        # Application source code
│   │   ├── routes/                 # API route handlers
│   │   ├── functions/              # PostgreSQL function wrappers
│   │   └── config/                 # Configuration files
│   └── public/                     # Web root
│       └── index.php               # Entry point
├── www/                             # Frontend Angular service
│   ├── Dockerfile
│   ├── package.json                # npm dependencies
│   ├── angular.json                # Angular configuration
│   └── src/
│       ├── app/
│       │   ├── components/         # Reusable UI components
│       │   ├── pages/              # Route components
│       │   ├── services/           # Business logic services
│       │   └── app.routes.ts       # Application routes
│       └── index.html
├── alert/                           # Alert service (Node.js)
│   ├── Dockerfile
│   ├── package.json                # npm dependencies
│   ├── src/
│   │   └── server.js               # Express + Socket.IO server
│   └── README.md
├── docker-compose.yaml              # Service orchestration
├── .env.example                     # Environment configuration template
├── README.md                        # Quick start guide
├── USAGE.md                         # Detailed usage documentation
├── DOCKER.md                        # Docker configuration guide
├── HLD.md                           # This file (architecture document)
├── CLAUDE.md                        # AI agent reference
├── project-info.yaml                # Project metadata
├── LICENSE                          # MIT License
└── scripts/                         # Build and utility scripts
```

### B. Key Workflows

#### Development Workflow

1. **Start Services**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   docker compose up -d
   ```

2. **Make Changes**
   - API: Edit files in `api/` directory
   - Frontend: Edit files in `www/` directory
   - Alert: Edit files in `alert/` directory
   - Changes auto-reload (hot reload enabled)

3. **View Logs**
   ```bash
   docker compose logs -f <service-name>
   ```

4. **Rebuild After Dependencies Change**
   ```bash
   docker compose up -d --build
   ```

#### Creating a New API Endpoint (StoneScriptPHP)

1. Create PostgreSQL stored procedure in `docker/postgres/init/`
2. Use StoneScriptPHP CLI to generate PHP function wrapper
3. Create route handler in `api/src/routes/`
4. TypeScript client auto-generated for frontend use

#### Adding Database Changes

1. Create SQL migration file in `docker/postgres/init/`
2. For existing databases, run migrations manually:
   ```bash
   docker compose exec db psql -U sunbird_user -d sunbird_db -f /docker-entrypoint-initdb.d/migration.sql
   ```
3. For fresh installations, remove volumes and restart:
   ```bash
   docker compose down -v
   docker compose up -d
   ```

### C. Common Operations

| Operation | Command |
|-----------|---------|
| Start all services | `docker compose up -d` |
| Stop all services | `docker compose down` |
| View logs | `docker compose logs -f [service]` |
| Restart service | `docker compose restart [service]` |
| Access API container | `docker compose exec api bash` |
| Access database | `docker compose exec db psql -U sunbird_user -d sunbird_db` |
| Rebuild services | `docker compose up -d --build` |
| Reset everything | `docker compose down -v` |

---

**Document Status:** Active
**Last Updated:** 2026-01-13
**Version:** 1.1
**Maintained By:** ProGalaxy eLabs
**Website:** https://stonescriptphp.org
**Repository:** https://github.com/progalaxyelabs/sunbird-garden
