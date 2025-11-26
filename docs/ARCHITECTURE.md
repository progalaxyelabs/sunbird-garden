# Sunbird Platform Architecture

## Overview

Sunbird is a Docker-based microservices platform template designed for rapid development of web applications. It provides a standardized architecture for all ProGalaxy eLabs projects.

## Design Principles

1. **Containerized**: All services run in Docker for consistent environments
2. **Type-Safe**: Auto-generated TypeScript clients from PHP backend
3. **Real-time**: Socket.IO integration for live updates
4. **Scalable**: Services can be scaled independently
5. **Developer Friendly**: Hot reload, clear separation of concerns

## Service Architecture

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|   www (Angular)  |<--->|  api (PHP/SSP)   |<--->|  db (Postgres)   |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +------------------+
         |                        |
         |                        |
         v                        v
+--------+---------+     +--------+---------+
|                  |     |                  |
| alert (Socket.IO)|<--->|  External APIs   |
|                  |     |                  |
+------------------+     +------------------+
```

## Data Flow

### Request Flow
1. User interacts with Angular frontend (www)
2. Frontend calls auto-generated API client methods
3. API client sends HTTP request to PHP backend (api)
4. Backend processes request, interacts with PostgreSQL (db)
5. Backend returns typed response
6. Frontend updates UI

### Real-time Flow
1. Backend emits event to Socket.IO (alert)
2. Alert service broadcasts to connected clients
3. Frontend receives event via WebSocket
4. Frontend updates UI in real-time

## Technology Stack

### Frontend (www)
- **Framework**: Angular 19
- **Language**: TypeScript 5.8
- **UI**: Bootstrap 5 + ngx-bootstrap
- **State**: Angular signals (v19+)
- **HTTP**: Auto-generated API client (@stonescript/api-client)

### Backend (api)
- **Framework**: StoneScriptPHP
- **Language**: PHP 8.3
- **Database**: PostgreSQL via PDO
- **Auth**: Firebase JWT (RS256)
- **CLI**: Custom code generators

### Alert Service
- **Runtime**: Node.js 20
- **Protocol**: Socket.IO
- **Purpose**: Real-time events, notifications

### Database
- **Engine**: PostgreSQL 16
- **Migrations**: SQL files in api/database/migrations/

## API Client Generation

StoneScriptPHP automatically generates TypeScript clients from PHP route definitions:

```php
// api/src/App/Routes/UsersRoute.php
#[Route('POST', '/users')]
class UsersRoute implements IRouteHandler {
    public function handle(UsersRequest $request): UsersResponse {
        // Implementation
    }
}

// api/src/App/DTO/UsersRequest.php
class UsersRequest {
    public string $email;
    public string $password;
}

// api/src/App/DTO/UsersResponse.php
class UsersResponse {
    public int $id;
    public string $token;
}
```

Generated TypeScript:

```typescript
// www/api-client/src/index.ts
export interface UsersRequest {
    email: string;
    password: string;
}

export interface UsersResponse {
    id: number;
    token: string;
}

export class ApiClient {
    async postUsers(request: UsersRequest): Promise<UsersResponse> {
        return this.post('/users', request);
    }
}
```

## Network Configuration

All services communicate via the `sunbird-network` Docker bridge network.

| Service | Internal Port | External Port | Network |
|---------|--------------|---------------|---------|
| db | 5432 | (none) | sunbird-network |
| api | 80 | 4402 | sunbird-network |
| alert | 3001 | 4401 | sunbird-network |
| www | 4200 | 4400 | sunbird-network |

## Security Considerations

1. **Database**: Not exposed externally, only accessible within Docker network
2. **API**: JWT authentication with RS256 signatures
3. **CORS**: Configured per environment
4. **Secrets**: Environment variables, never committed
5. **HTTPS**: Handled by reverse proxy (Traefik) in production

## Extending the Platform

### Adding a New Service

1. Create service directory with Dockerfile
2. Add service to docker-compose.yaml
3. Update build.sh if build order matters
4. Document in this file

### Adding a New API Endpoint

```bash
cd api
php generate route post /endpoint
# Edit DTOs and route handler
php generate client --output=../www/api-client
```

### Adding a Database Migration

```bash
# Create migration file
echo "CREATE TABLE ..." > api/database/migrations/002_create_tablename.sql

# Run migrations
docker compose exec api php generate migrate up
```
