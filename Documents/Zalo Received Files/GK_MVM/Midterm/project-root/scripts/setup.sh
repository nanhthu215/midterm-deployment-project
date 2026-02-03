#!/bin/bash

# Hiển thị thông báo cho đẹp và dễ theo dõi
echo "------------------------------------------"
echo "DANG CAI DAT MOI TRUONG NODE.JS..."
echo "------------------------------------------"

# 1. Cập nhật hệ thống
echo "[1/3] Dang cap nhat he thong..."
sudo apt update -y

# 2. Cài đặt các phần mềm hỗ trợ (Git, Nginx)
echo "[2/3] Dang cai dat Git va Nginx..."
sudo apt install -y git curl nginx

# 3. Cài đặt Node.js phiên bản 18 (Bản ổn định)
echo "[3/3] Dang cai dat Node.js v18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Kiểm tra xem cài xong chưa
echo "------------------------------------------"
echo "HOAN THANH!"
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "------------------------------------------"