# Phase 2 – Traditional Host-Based Deployment on Ubuntu Cloud Server

## Overview

This directory contains all artefacts produced during Phase 2 of the mid-term project. Phase 2 deploys the application directly onto a cloud-based Ubuntu server without containerisation, using Nginx as a reverse proxy, PM2 as the process manager, MongoDB installed on the host, and a TLS certificate from Let's Encrypt.

---

## Directory Contents

```
phase2/
├── nginx/
│   └── midterm-app.conf             # Nginx reverse proxy configuration
├── screenshots/
│   ├── 01-azure-vm.png              # Cloud VM instance running
│   ├── 02-firewall.png              # Security Group (port 22, 80, 443 only)
│   ├── 03-env-config.png            # .env file configuration
│   ├── 04-mongodb-status.png        # MongoDB service status (active/running)
│   ├── 05-run-setup-sh(01).png      # setup.sh execution output (part 1)
│   ├── 05-run-setup-sh(02).png      # setup.sh execution output (part 2)
│   ├── 06-pm2-start.png             # PM2 list showing app online
│   ├── 07-pm2-startup.png           # PM2 startup script configuration
│   ├── 08-nginx-conf.png            # sudo nginx -t (syntax OK)
│   ├── 09-dns-duckdns.png           # DuckDNS IP mapping configuration
│   ├── 10-certbot-ssl.png           # SSL certificate successfully issued
│   ├── 11-https-browser..png        # Secured HTTPS application in browser
│   └── 12-file-upload.png           # Verification of file upload persistence
├── .env.example                     # Environment variables template
└── README.md                        # This documentation file
```

---

## Deployment Steps

### 1. Cloud Server Provisioning

- Provider: **Amazon Web Services (AWS)**
- Instance: EC2 – Ubuntu 22.04 LTS
- Firewall (Security Group) – inbound rules:

| Port | Protocol | Purpose                    |
|------|----------|----------------------------|
| 22   | TCP      | SSH access                 |
| 80   | TCP      | HTTP (redirected to HTTPS) |
| 443  | TCP      | HTTPS                      |

All other ports remain closed to the public internet, including port 3000 (application) and port 27017 (MongoDB).

### 2. Runtime Environment Preparation

The `scripts/setup.sh` automation script from Phase 1 was transferred to the server and executed:

```bash
chmod +x scripts/setup.sh
sudo ./scripts/setup.sh
```

This installed Node.js 20.x, PM2, Nginx, and created the required directories.

### 3. Database Configuration

MongoDB 6.0 was installed directly on the Ubuntu host:

```bash
sudo systemctl enable mongod
sudo systemctl start mongod
```

The `.env` file was created in the application directory:

```env
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
```

On startup, the application connects to MongoDB successfully and seeds 10 sample products if the collection is empty. The in-memory fallback is **not** activated.

### 4. Application Deployment with PM2
The application was installed and managed using PM2 to ensure persistence:

```bash
cd ~/midterm-deployment-project
npm install --production

# Start application with PM2
pm2 start src/main.js --name "midterm-app"

# Configure auto-start on server reboot
pm2 startup
# Copy and run the command printed by pm2 startup
pm2 save
```

### 5. Nginx Reverse Proxy

Configuration file: `phase2/nginx/midterm-app.conf`

```nginx
server {

    server_name midtermcheck.duckdns.org;

    # Security headers

    add_header X-Frame-Options "SAMEORIGIN";

    add_header X-Content-Type-Options "nosniff";

    # Proxy to Node.js app

    location / {

        proxy_pass http://localhost:3000;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;

        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_cache_bypass $http_upgrade;

    }
    # File upload size limit

    client_max_body_size 50M;

    listen 443 ssl; # managed by Certbot

    ssl_certificate /etc/letsencrypt/live/midtermcheck.duckdns.org/fullchain.pem; # managed by Certbot

    ssl_certificate_key /etc/letsencrypt/live/midtermcheck.duckdns.org/privkey.pem; # managed by Certbot

    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot

    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}
server {
    if ($host = midtermcheck.duckdns.org) {
        return 301 https://$host$request_uri;
    } # managed by Certbot
    listen 80;
    server_name midtermcheck.duckdns.org;
    return 404; # managed by Certbot
}
```

```bash
sudo ln -s /etc/nginx/sites-available/midterm-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

> **Note:** This Nginx configuration is preserved in Phase 3. Only the upstream target changes when the application transitions to Docker containers (both Phase 2 and Phase 3 proxy to `localhost:3000`).

### 6. Domain and HTTPS Configuration

- Domain: Registered via DuckDNS (midtermcheck.duckdns.org).
- TLS Certificate: Issued via Certbot, automatically enforcing HTTPS redirection.

```bash
sudo certbot --nginx -d midtermcheck.duckdns.org
```

Certbot automatically updates the Nginx configuration to redirect HTTP to HTTPS.

---

## Evidence Checklist

Screenshots in `phase2/screenshots/`:

[x] VM instance running

[x] Strict firewall rules

[x] Environment configuration (.env)

[x] MongoDB active status

[x] setup.sh successful execution

[x] Application online via PM2

[x] PM2 startup script configuration

[x] Nginx syntax test success

[x] DuckDNS domain mapping

[x] Certbot SSL certificate issuance

[x] Application accessible via HTTPS

[x] Successful file upload functionality

---

## Team Contributions

| Member                        | Contributions in Phase 2                                              |
|-------------------------------|-----------------------------------------------------------------------|
| Nguyen Anh Quan (523H0083)    | Server provisioning, firewall configuration, `setup.sh` execution, PM2 deployment, Nginx configuration |
| Nguyen Thi Anh Thu (523H0101) | Domain registration, DNS configuration, HTTPS certificate installation, system verification |