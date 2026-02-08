#!/bin/bash

# Sunbird Garden - Project Initialization Script
# Scaffolds a complete development environment with API, frontend, and alert services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source repository URLs
STONESCRIPT_SERVER_REPO="https://github.com/progalaxyelabs/stonescriptphp-server.git"
STONESCRIPT_UI_REPO="https://github.com/progalaxyelabs/stonescriptui-scaffold.git"

# Default project name (can be customized)
DEFAULT_PROJECT_NAME="sunbird"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Sunbird Garden - Project Initialization${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}[1/7] Checking prerequisites...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}Error:${NC} git is not installed. Please install git first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Warning:${NC} Docker is not installed. You'll need it to run the project."
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${YELLOW}Warning:${NC} Docker Compose V2 is not installed. You'll need it to run the project."
fi

echo -e "${GREEN}   Prerequisites check complete${NC}"
echo ""

# Get project name
read -p "Enter project name [${DEFAULT_PROJECT_NAME}]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_PROJECT_NAME}

# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo -e "${RED}Error:${NC} Project name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
    exit 1
fi

echo ""

# Step 2: Clone API service (stonescriptphp-server)
echo -e "${BLUE}[2/7] Cloning API service (StoneScriptPHP)...${NC}"

if [ -d "$PROJECT_ROOT/api" ]; then
    echo -e "${YELLOW}   Warning:${NC} api/ directory already exists. Skipping..."
else
    git clone --depth 1 "$STONESCRIPT_SERVER_REPO" "$PROJECT_ROOT/api"
    rm -rf "$PROJECT_ROOT/api/.git"
    echo -e "${GREEN}   API service cloned${NC}"
fi
echo ""

# Step 3: Clone frontend service (stonescriptui-scaffold)
echo -e "${BLUE}[3/7] Cloning frontend service (StoneScript UI)...${NC}"

if [ -d "$PROJECT_ROOT/www" ]; then
    echo -e "${YELLOW}   Warning:${NC} www/ directory already exists. Skipping..."
else
    git clone --depth 1 "$STONESCRIPT_UI_REPO" "$PROJECT_ROOT/www"
    rm -rf "$PROJECT_ROOT/www/.git"
    echo -e "${GREEN}   Frontend service cloned${NC}"
fi
echo ""

# Step 4: Generate alert service (Node.js + Express + Socket.IO)
echo -e "${BLUE}[4/7] Generating alert service (Node.js + Socket.IO)...${NC}"

if [ -d "$PROJECT_ROOT/alert" ]; then
    echo -e "${YELLOW}   Warning:${NC} alert/ directory already exists. Skipping..."
else
    mkdir -p "$PROJECT_ROOT/alert"

    # Create package.json
    cat > "$PROJECT_ROOT/alert/package.json" <<EOF
{
  "name": "${PROJECT_NAME}-alert",
  "version": "1.0.0",
  "description": "Real-time notification service with Socket.IO",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.6.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

    # Create server.js
    cat > "$PROJECT_ROOT/alert/server.js" <<'EOF'
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
require('dotenv').config();

const app = express();
const server = http.createServer(app);

// Configure CORS
const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:4400').split(',');

app.use(cors({
  origin: allowedOrigins,
  credentials: true
}));

const io = socketIo(server, {
  cors: {
    origin: allowedOrigins,
    methods: ['GET', 'POST'],
    credentials: true
  }
});

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'alert', timestamp: new Date().toISOString() });
});

// HTTP endpoint to broadcast alerts
app.post('/alert', (req, res) => {
  const { type, message, data } = req.body;

  if (!type || !message) {
    return res.status(400).json({ error: 'type and message are required' });
  }

  io.emit('alert', { type, message, data, timestamp: new Date().toISOString() });

  res.json({ success: true, message: 'Alert broadcasted' });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });

  // Custom event handlers
  socket.on('subscribe', (channel) => {
    socket.join(channel);
    console.log(`Client ${socket.id} subscribed to ${channel}`);
  });

  socket.on('unsubscribe', (channel) => {
    socket.leave(channel);
    console.log(`Client ${socket.id} unsubscribed from ${channel}`);
  });
});

const PORT = process.env.ALERT_PORT || 3001;

server.listen(PORT, () => {
  console.log(`Alert service running on port ${PORT}`);
  console.log(`CORS enabled for: ${allowedOrigins.join(', ')}`);
});
EOF

    # Create Dockerfile
    cat > "$PROJECT_ROOT/alert/Dockerfile" <<'EOF'
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

EXPOSE 3001

CMD ["npm", "start"]
EOF

    # Create .dockerignore
    cat > "$PROJECT_ROOT/alert/.dockerignore" <<'EOF'
node_modules
npm-debug.log
.env
.git
.gitignore
README.md
EOF

    # Create README
    cat > "$PROJECT_ROOT/alert/README.md" <<EOF
# Alert Service

Real-time notification service using Express and Socket.IO.

## Features

- WebSocket connections via Socket.IO
- HTTP API for broadcasting alerts
- Channel-based subscriptions
- CORS configuration

## API Endpoints

### GET /health
Health check endpoint

### POST /alert
Broadcast an alert to all connected clients

**Body:**
\`\`\`json
{
  "type": "info|warning|error|success",
  "message": "Alert message",
  "data": {}  // Optional additional data
}
\`\`\`

## Socket.IO Events

### Client → Server
- \`subscribe\`: Join a channel
- \`unsubscribe\`: Leave a channel

### Server → Client
- \`alert\`: Receive broadcasted alerts

## Environment Variables

- \`ALERT_PORT\`: Port to run on (default: 3001)
- \`CORS_ORIGINS\`: Comma-separated allowed origins (default: http://localhost:4400)
EOF

    echo -e "${GREEN}   Alert service generated${NC}"
fi
echo ""

# Step 5: Create compose.yaml
echo -e "${BLUE}[5/7] Creating Docker Compose configuration...${NC}"

if [ -f "$PROJECT_ROOT/compose.yaml" ]; then
    echo -e "${YELLOW}   Warning:${NC} compose.yaml already exists. Skipping..."
else
    cat > "$PROJECT_ROOT/compose.yaml" <<EOF
name: ${PROJECT_NAME}

services:
  # PostgreSQL Database
  db:
    image: postgres:16-alpine
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}-db
    environment:
      POSTGRES_DB: \${DB_NAME:-${PROJECT_NAME}_db}
      POSTGRES_USER: \${DB_USER:-${PROJECT_NAME}_user}
      POSTGRES_PASSWORD: \${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ${PROJECT_NAME}-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${DB_USER:-${PROJECT_NAME}_user}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # StoneScriptPHP API
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}-api
    environment:
      APP_ENV: \${APP_ENV:-development}
      DB_HOST: db
      DB_PORT: 5432
      DB_NAME: \${DB_NAME:-${PROJECT_NAME}_db}
      DB_USER: \${DB_USER:-${PROJECT_NAME}_user}
      DB_PASSWORD: \${DB_PASSWORD}
      JWT_SECRET: \${JWT_SECRET}
      CORS_ORIGIN: \${CORS_ORIGIN:-http://localhost:4400}
    ports:
      - "\${API_PORT:-4402}:80"
    volumes:
      - ./api:/var/www/html
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      db:
        condition: service_healthy

  # Angular Frontend
  www:
    build:
      context: ./www
      dockerfile: Dockerfile
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}-www
    environment:
      API_URL: http://localhost:\${API_PORT:-4402}
      ALERT_URL: http://localhost:\${ALERT_PORT:-4401}
    ports:
      - "\${WWW_PORT:-4400}:80"
    volumes:
      - ./www:/app
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      - api

  # Alert Service (Socket.IO)
  alert:
    build:
      context: ./alert
      dockerfile: Dockerfile
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}-alert
    environment:
      ALERT_PORT: 3001
      CORS_ORIGINS: \${CORS_ORIGIN:-http://localhost:4400}
    ports:
      - "\${ALERT_PORT:-4401}:3001"
    volumes:
      - ./alert:/app
      - /app/node_modules
    networks:
      - ${PROJECT_NAME}-network

networks:
  ${PROJECT_NAME}-network:
    driver: bridge

volumes:
  postgres_data:
EOF

    echo -e "${GREEN}   Docker Compose configuration created${NC}"
fi
echo ""

# Step 6: Create .env file
echo -e "${BLUE}[6/7] Creating environment configuration...${NC}"

if [ -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${YELLOW}   Warning:${NC} .env file already exists. Skipping..."
else
    # Generate random secrets
    JWT_SECRET=$(openssl rand -hex 32 2>/dev/null || echo "CHANGE_ME_$(date +%s)")
    DB_PASSWORD=$(openssl rand -hex 16 2>/dev/null || echo "CHANGE_ME_$(date +%s)")

    cat > "$PROJECT_ROOT/.env" <<EOF
# Project Configuration
PROJECT_NAME=${PROJECT_NAME}
APP_ENV=development

# Database Configuration
DB_NAME=${PROJECT_NAME}_db
DB_USER=${PROJECT_NAME}_user
DB_PASSWORD=${DB_PASSWORD}

# Service Ports
API_PORT=4402
WWW_PORT=4400
ALERT_PORT=4401

# Security
JWT_SECRET=${JWT_SECRET}

# CORS Configuration
CORS_ORIGIN=http://localhost:4400

# Optional: Add your custom environment variables below
EOF

    echo -e "${GREEN}   Environment file created${NC}"
    echo -e "${YELLOW}   IMPORTANT: Generated secure random secrets for JWT_SECRET and DB_PASSWORD${NC}"
fi
echo ""

# Step 7: Final instructions
echo -e "${BLUE}[7/7] Finalization...${NC}"

# Update .gitignore to exclude scaffolded directories
if ! grep -q "^api/$" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    cat >> "$PROJECT_ROOT/.gitignore" <<EOF

# Scaffolded services (generated by init.sh)
api/
www/
alert/
EOF
    echo -e "${GREEN}   Updated .gitignore${NC}"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Project '${PROJECT_NAME}' initialized!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Review your configuration:"
echo -e "   ${YELLOW}nano .env${NC}"
echo ""
echo "2. Install dependencies (if developing locally):"
echo -e "   ${YELLOW}cd api && composer install${NC}"
echo -e "   ${YELLOW}cd www && npm install${NC}"
echo -e "   ${YELLOW}cd alert && npm install${NC}"
echo ""
echo "3. Build and start services:"
echo -e "   ${YELLOW}docker compose build${NC}"
echo -e "   ${YELLOW}docker compose up -d${NC}"
echo ""
echo "4. Run database migrations:"
echo -e "   ${YELLOW}docker compose exec api php artisan migrate${NC}"
echo ""
echo "5. Access your application:"
echo "   Frontend: http://localhost:${WWW_PORT:-4400}"
echo "   API:      http://localhost:${API_PORT:-4402}"
echo "   Alert:    http://localhost:${ALERT_PORT:-4401}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "   View logs:        docker compose logs -f"
echo "   Stop services:    docker compose down"
echo "   Restart:          docker compose restart"
echo "   Shell access:     docker compose exec api bash"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
echo ""
