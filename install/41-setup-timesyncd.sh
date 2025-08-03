#!/usr/bin/env bash

TIMEZONE="${1:-Europe/Stockholm}"
NTP_SERVERS="${2:-0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org}"

echo "Setting up timesyncd..."

sudo mkdir -p /etc/systemd/timesyncd.conf.d
echo "[Time]" | sudo tee /etc/systemd/timesyncd.conf.d/local.conf > /dev/null
echo "NTP=$NTP_SERVERS" | sudo tee -a /etc/systemd/timesyncd.conf.d/local.conf > /dev/null
sudo timedatectl set-ntp false
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
sudo timedatectl set-timezone "$TIMEZONE"
