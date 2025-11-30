FROM node:20-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001

LABEL maintainer="ProGalaxy eLabs <team@progalaxyelabs.com>"
LABEL org.opencontainers.image.source="https://github.com/progalaxyelabs/sunbird-garden"
LABEL org.opencontainers.image.description="Sunbird Garden Alert service - WebSocket notification service"

CMD ["npm", "run", "dev"]
