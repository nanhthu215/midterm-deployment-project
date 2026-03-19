# Phase 3 – Containerized Deployment with Docker Compose

## Overview

This directory contains all artefacts produced during Phase 3 of the mid-term project. Phase 3 migrates the application from the traditional host-based deployment (Phase 2) to a fully containerised architecture using Docker and Docker Compose. All application components — web application and database — run exclusively inside Docker containers on the same server used in Phase 2.

---

## Directory Contents

```
phase3/
├── docker-compose.yml               # Docker Compose service definitions
├── Dockerfile                       # Instructions to build the application image
├── .env.example                     # Environment variable template
├── screenshots/
│   ├── 01-docker-v.png              # Fig 4.1 – Docker & Compose versions
│   ├── 02-dockerfile.png            # Fig 4.2 – Dockerfile contents
│   ├── 03-docker-build.png          # Fig 4.3 – docker build output
│   ├── 04-docker-push.png           # Fig 4.4 – docker push output
│   ├── 05-dockerhub.png             # Fig 4.5 – Docker Hub repository
│   ├── 06-docker-pull.png           # Fig 4.6 – docker pull on server
│   ├── 07-compose-up.png            # Fig 4.8 – docker compose up -d output
│   ├── 08-docker-ps.png             # Fig 4.9 – docker ps (both containers Up)
│   ├── 09-volumes.png               # Fig 4.10 – docker volume ls
│   ├── 10-restart-cont.png          # Fig 4.11 – container restart verification
│   ├── 11-restart-daemon.png        # Fig 4.12 – daemon restart verification
│   ├── 12-reboot-server.png         # Fig 4.13 – server reboot verification
│   ├── 13-https-phase3.png          # Fig 4.14 – HTTPS working post-reboot
│   └── 14-persist-data.png          # Fig 4.15 – Uploaded files intact post-reboot
└── README.md                        # This documentation file
```

---

## Architecture

```
Internet
    │ HTTPS :443
    ▼
[Nginx — host level] ──────── proxy_pass localhost:3000
    │
    ▼ :3000
┌─────────────────────────────────────────┐
│         Docker Compose Stack            │
│  ┌──────────────────┐                   │
│  │   web container  │◄── Docker Hub     │
│  │ midterm-app:latest│    (pull image)  │
│  └────────┬─────────┘                   │
│           │ mongo:27017 (app_network)   │
│  ┌────────▼─────────┐                   │
│  │  mongo container  │                  │
│  │    mongo:6.0      │                  │
│  └──────────────────┘                   │
│                                         │
│  Volumes:                               │
│  • uploads_data → /app/uploads          │
│  • mongo_data   → /data/db              │
└─────────────────────────────────────────┘
```

---

## Deployment Steps

### 1. Install Docker and Docker Compose

Run on the Phase 2 server:

```bash
# Install Docker Engine
curl -fsSL [https://get.docker.com](https://get.docker.com) | sudo sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose plugin
sudo apt-get install -y docker-compose-plugin

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify installation
docker --version
docker compose version
```

### 2. Build and Push Docker Image (on local machine)

The `Dockerfile` is located at the repository root.

```bash
# Build the image
docker build -t nanhthu215/midterm-app:latest .
docker build -t nanhthu215/midterm-app:1.0 .

# Push to Docker Hub
docker login
docker push nanhthu215/midterm-app:latest
docker push nanhthu215/midterm-app:1.0
```

Docker Hub repository: `https://hub.docker.com/r/nanhthu215/midterm-app`

### 3. Stop Phase 2 PM2 Process

```bash
pm2 stop all
pm2 delete all

# Confirm port 3000 is free
sudo ss -tlnp | grep 3000
```

### 4. Deploy with Docker Compose

```bash
cd ~/midterm-deployment-project/phase3

# Create .env from template
cp .env.example .env
# .env contents:
#   PORT=3000
#   MONGO_URI=mongodb://mongo:27017/products_db
#   NODE_ENV=production

# Pull image from Docker Hub
docker pull nanhthu215/midterm-app:latest

# Start the full stack
docker compose up -d

# Verify both containers are running
docker ps
docker compose logs -f
```

### 5. Update Nginx (no changes needed)

The Nginx configuration from Phase 2 requires no modification. `proxy_pass http://localhost:3000` continues to work because the Docker container maps port 3000 to the host.

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## Docker Compose Configuration

Full file: `phase3/docker-compose.yml`

Key design decisions:

| Setting         | Value                                | Reason                                              |
|-----------------|--------------------------------------|-----------------------------------------------------|
| `web.image`     | `nanhthu215/midterm-app:latest`      | Pulls from registry, not built locally              |
| `mongo.image`   | `mongo:6.0`                          | Official image, pinned version                      |
| `restart`       | `always`                             | Auto-recover from crashes, daemon restarts, reboots |
| `MONGO_URI`     | `mongodb://midterm_mongo:27017/midterm_db` | Uses Docker service name, not localhost       |
| `uploads_data`  | `/app/src/public/uploads`            | Persists uploaded files across container restarts   |
| `mongo_data`    | `/data/db`                           | Persists database across container restarts         |
| Network         | `app_network` (bridge)               | Internal communication by service name              |

---

## Environment Variables

Copy `.env.example` to `.env` in the `phase3/` directory before running:

```env
PORT=3000
MONGO_URI=mongodb://mongo:27017/products_db
NODE_ENV=production
```

> **Important:** Never use `localhost` as the MongoDB host inside Docker Compose. Use the service name `mongo` instead — Docker's internal DNS resolves this automatically.

---

## Evidence Checklist

Screenshots in `phase3/screenshots/`:

[x] 01-docker-v.png: Docker and Compose versions

[x] 02-dockerfile.png: Dockerfile contents

[x] 03-docker-build.png: Image build process

[x] 04-docker-push.png: Image push to registry

[x] 05-dockerhub.png: Public Docker Hub repository

[x] 06-docker-pull.png: Pulling image on production server

[x] 07-compose-up.png: Starting services via compose

[x] 08-docker-ps.png: Running containers list

[x] 09-volumes.png: Docker volumes list

[x] 10-restart-cont.png: Container restart test

[x] 11-restart-daemon.png: Daemon restart test

[x] 12-reboot-server.png: Full server reboot test

[x] 13-https-phase3.png: HTTPS application access post-reboot

[x] 14-persist-data.png: Verification of persistent volumes

---

## Team Contributions

| Member                        | Contributions in Phase 3                                                     |
|-------------------------------|------------------------------------------------------------------------------|
| Nguyen Anh Quan (523H0083)    | Dockerfile authoring, `docker build`, `docker push` to Docker Hub, Docker installation on server |
| Nguyen Thi Anh Thu (523H0101) | `docker-compose.yml` configuration, volume and persistence testing, restart behaviour verification, HTTPS verification |