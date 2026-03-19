#!/bin/bash
# =============================================================
# setup.sh – Environment preparation for Product API Project
# Target OS : Ubuntu 22.04 LTS
# Usage     : chmod +x setup.sh && ./setup.sh
# =============================================================

set -e  # Dừng script nếu có lệnh nào lỗi

echo '================================================'
echo ' Starting environment setup...'
echo '================================================'

# --- 1. Cập nhật hệ thống ---
echo '[1/5] Updating system packages...'
sudo apt-get update -y
sudo apt-get upgrade -y

# --- 2. Cài đặt các gói cơ bản ---
echo '[2/5] Installing essential packages (curl, git, nginx, ufw)...'
sudo apt-get install -y \
    curl \
    git \
    build-essential \
    nginx \
    ufw

# --- 3. Cài đặt Node.js 20.x ---
echo '[3/5] Installing Node.js 20.x...'
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# --- 4. Cài đặt PM2 để chạy app Node.js ---
echo '[4/5] Installing PM2 process manager...'
sudo npm install -g pm2
echo "PM2 version: $(pm2 -v)"

# --- 5. Tạo các thư mục cần thiết theo yêu cầu của main.js ---
echo '[5/5] Creating application directories...'
mkdir -p ~/app/uploads
mkdir -p ~/app/logs
mkdir -p ~/app/data
echo 'Directories created successfully.'

echo '================================================'
echo ' Setup complete! Ready for Phase 2 deployment.'
echo '================================================'