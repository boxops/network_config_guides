#!/bin/bash
# Purpose: Deploy Kea DHCP or Stork on localhost

# Prompt: Deploy Kea DHCP server or Stork server? (D/s)
read -p "Deploy Kea DHCP server or Stork server? (D/s) " -n 1 -r

# Action: Show environment variables for selected
echo "Environment variables for selected:"

# Prompt: Proceed with the deployment? (y/N)
read -p "Proceed with the deployment? (y/N) " -n 1 -r

# Action: Deploy or abort
echo "Deploy or abort"
