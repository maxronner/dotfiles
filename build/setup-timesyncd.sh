#!/usr/bin/env bash

TIMEZONE="$1"
NTP_SERVERS="$2"

sudo mkdir -p /etc/systemd/timesyncd.conf.d
echo "[Time]" | sudo tee /etc/systemd/timesyncd.conf.d/local.conf > /dev/null
echo "NTP=$NTP_SERVERS" | sudo tee -a /etc/systemd/timesyncd.conf.d/local.conf > /dev/null
sudo timedatectl set-ntp false
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
sudo timedatectl set-timezone "$TIMEZONE"
