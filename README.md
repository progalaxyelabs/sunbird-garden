# Sunbird Garden

A complete full-stack platform reference implementation for StoneScriptPHP framework.

**Website**: https://stonescriptphp.org | **Docs**: https://stonescriptphp.org/docs

## Purpose

Sunbird Garden is a scaffolding tool and reference implementation that demonstrates how to build production-ready full-stack applications using:

- **Backend**: StoneScriptPHP (PHP REST API with database functions)
- **Frontend**: Angular with StoneScript UI
- **Notifications**: Node.js + Socket.IO (real-time alerts)
- **Database**: PostgreSQL 16 with migrations
- **Docker**: Complete containerized development and production setup

## Getting Started

### Prerequisites
- Docker 20.10+ and Docker Compose V2
- Git

### Setup
```bash
cp .env.example .env
docker compose up -d
```

### Access Services
- **Frontend**: http://localhost:4400
- **API**: http://localhost:4402
- **Alerts**: http://localhost:4401

## Project Structure

```
sunbird-garden/
├── api/              # StoneScriptPHP backend (PHP)
├── www/              # Angular frontend
├── alert/            # Node.js WebSocket service
├── docker/           # PostgreSQL setup scripts
├── docker-compose.yaml
├── .env.example      # Configuration template
├── README.md         # This file
├── USAGE.md          # Detailed usage guide
├── DOCKER.md         # Docker configuration
├── HLD.md            # Architecture document
└── scripts/          # Build and initialization
```

## Configuration

Edit `.env` to customize deployment:

```bash
# Database
DB_NAME=sunbird_db
DB_USER=sunbird_user
DB_PASSWORD=secure-password

# Ports
API_PORT=4402
WWW_PORT=4400
ALERT_PORT=4401

# Security
JWT_SECRET=your-secret-key
CORS_ORIGIN=http://localhost:4400
```

## Development

Access services in containers:

```bash
# API (PHP backend)
docker compose exec api bash

# Frontend (Angular)
docker compose exec www sh

# Alerts (Node.js)
docker compose exec alert sh

# Database
docker compose exec db psql -U sunbird_user -d sunbird_db
```

## Common Commands

```bash
docker compose up -d          # Start all services
docker compose down           # Stop services
docker compose logs -f        # View logs
docker compose up -d --build  # Rebuild and restart
docker compose down -v        # Remove data (WARNING!)
```

## Alert Service

Real-time notifications via Socket.IO and HTTP:

```bash
# Broadcast alert
curl -X POST http://localhost:4401/alert \
  -H "Content-Type: application/json" \
  -d '{"type": "info", "message": "Hello"}'

# Health check
curl http://localhost:4401/health
```

WebSocket client:
```javascript
const socket = io('http://localhost:4401');
socket.on('alert', (data) => console.log(data));
```

## Repository URLs

The initialization script clones from these repositories:

- **API**: https://github.com/progalaxyelabs/stonescriptphp-server
- **Frontend**: https://github.com/progalaxyelabs/stonescriptui-scaffold

## Troubleshooting

```bash
# View logs
docker compose logs -f <service>

# Port conflict? Update .env and restart
docker compose down && docker compose up -d

# Fresh start (WARNING: deletes data)
docker compose down -v && rm -rf api/ www/ alert/
```

## Contributing

This is an open-source scaffolding tool. Contributions welcome!

## License

MIT License

## Support

- **Documentation**: https://stonescriptphp.org/docs
- **Issues**: https://github.com/progalaxyelabs/sunbird-garden/issues
- **Discussions**: https://github.com/progalaxyelabs/sunbird-garden/discussions

---

**Built with ❤️ by ProGalaxy eLabs**
