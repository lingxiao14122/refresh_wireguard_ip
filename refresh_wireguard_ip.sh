#!/bin/bash

# Check for internet connectivity
if ! ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "No internet connectivity"
  exit 1
fi

# Read configuration file
source /etc/pivpn/wireguard/setupVars.conf

# Get public IP address
public_ip=$(curl -s https://api.ipify.org)

# Check if pivpnHOST needs updating
if [ "$public_ip" != "$pivpnHOST" ]; then
  # Update pivpnHOST in config file
  sudo sh -c "echo \"pivpnHOST=$public_ip\" | tee /etc/pivpn/wireguard/setupVars.conf >/dev/null"
  echo "pivpnHOST updated to $public_ip"

  # Send new IP address to Discord webhook
  DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/"
  DISCORD_MESSAGE="New public IP address: $public_ip"
  curl -H "Content-Type: application/json" -d "{\"content\": \"$DISCORD_MESSAGE\"}" "$DISCORD_WEBHOOK_URL"
else
  echo "pivpnHOST already up-to-date with $public_ip"
fi