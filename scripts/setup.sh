#!/bin/bash
# =============================================================
# setup.sh – Environment preparation for Product API Project
# Target OS : Ubuntu 22.04 LTS
# Usage     : chmod +x setup.sh && ./setup.sh
# =============================================================

set -e  # Dừng script nếu có lệnh nào lỗi [cite: 171]

echo '================================================'
echo ' Starting environment setup...'
echo '================================================'

# --- 1. Cập nhật hệ thống ---
echo '[1/5] Updating system packages...'
sudo apt-get update -y [cite: 177]
sudo apt-get upgrade -y [cite: 178]

# --- 2. Cài đặt các gói cơ bản ---
echo '[2/5] Installing essential packages (curl, git, nginx, ufw)...'
sudo apt-get install -y curl git build-essential nginx ufw [cite: 181, 185, 186]

# --- 3. Cài đặt Node.js 20.x ---
echo '[3/5] Installing Node.js 20.x...'
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - [cite: 189]
sudo apt-get install -y nodejs [cite: 190]
echo "Node version: $(node -v)" [cite: 191]

# --- 4. Cài đặt PM2 để chạy app Node.js ---
echo '[4/5] Installing PM2 process manager...'
sudo npm install -g pm2 [cite: 195]
echo "PM2 version: $(pm2 -v)" [cite: 196]

# --- 5. Tạo các thư mục cần thiết theo yêu cầu của main.js ---
echo '[5/5] Creating application directories...'
mkdir -p ~/app/public/uploads [cite: 199, 200]
mkdir -p ~/app/logs [cite: 199]
echo 'Directories created successfully.' [cite: 202]

echo '================================================'
echo ' Setup complete! Ready for Phase 2 deployment.'
echo '================================================'