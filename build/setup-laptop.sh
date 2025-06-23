#!/usr/bin/env bash

echo "Setting up dhcpcd..."
sudo systemctl enable --now dhcpcd.service
