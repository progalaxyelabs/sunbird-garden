# Sunbird Garden - AI Agent Reference

Quick reference for AI agents working on sunbird-garden.

## Project Info
- **Type**: Full-stack platform reference implementation
- **Stack**: Angular + StoneScriptPHP + PostgreSQL + Node.js
- **Location**: `/ssd2/projects/progalaxy-elabs/opensource/stonescriptphp/sunbird-garden/`
- **Status**: Active - demonstrates StoneScriptPHP framework

## Architecture
```
Frontend (Angular:4400) ──┐
                          ├─→ Docker Network ─→ API (PHP:4402) ─→ PostgreSQL
Alerts (Node.js:4401) ────┘
```

## Key Services
| Service | Port | Tech | Purpose |
|---------|------|------|---------|
| www | 4400 | Angular | UI |
| api | 4402 | PHP/StoneScriptPHP | REST API |
| alert | 4401 | Node.js | WebSocket alerts |
| db | 5432 | PostgreSQL 16 | Data storage |

## Quick Commands
```bash
# Setup
cp .env.example .env && docker compose up -d

# Access services
docker compose exec api bash       # PHP backend
docker compose exec www sh         # Angular frontend
docker compose exec db psql ...    # Database

# Debugging
docker compose logs -f <service>
docker compose down -v             # Reset all
```

## Important Files
- **docker-compose.yaml**: Service definitions
- **api/**: StoneScriptPHP backend (PHP routes, database functions)
- **www/**: Angular frontend application
- **alert/**: Node.js WebSocket service
- **docker/**: PostgreSQL initialization scripts
- **.env.example**: Configuration template

## Database
- Engine: PostgreSQL 16
- Function-based architecture (StoneScriptPHP pattern)
- Migrations in api/database/ directory
- Default: sunbird_db / sunbird_user

## Development Notes
- Services communicate via docker-compose network
- Environment variables in .env control all settings
- API generates TypeScript clients for frontend
- Real-time features via Socket.IO alert service

## Documentation
- **README.md**: Quick start and basic usage
- **USAGE.md**: Detailed usage guide
- **DOCKER.md**: Docker setup details
- **HLD.md**: Architecture and design
- https://stonescriptphp.org/docs: Official docs

## Common Tasks
- Update API: Modify api/ files, rebuild
- Update UI: Modify www/ files, rebuild
- Add alerts: Use Node.js alert service
- Database changes: Add migrations in api/database/
- Port conflicts: Change WWW_PORT/API_PORT/ALERT_PORT in .env

## Conventions
- Container names: lowercase with hyphens
- Database: snake_case functions
- API routes: RESTful (/endpoint)
- Frontend: Angular standalone components
