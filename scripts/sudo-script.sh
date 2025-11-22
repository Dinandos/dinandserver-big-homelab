#!/bin/bash

# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt-get update

# Install Docker Engine, CLI, and containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-

# Enable SSH service
sudo systemctl enable ssh
sudo systemctl start ssh

# Permit root login with password
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
sudo systemctl restart ssh

# Cleanup and clear history
sudo clear
sudo history -c

# ! Definieer kleurcodes
BLUE='\033[1;34m'
GREEN='\033[1;32m'
BOLD='\033[1m'
RESET='\033[0m'

# Titel in groen en vet
sudo echo -e "${GREEN}${BOLD}Installatie voltooid${RESET}"

# Lijst in lichtblauw
sudo echo -e "${BLUE}- Systeem bijgewerkt (apt-get update)"
sudo echo -e "- Benodigde pakketten geïnstalleerd: ca-certificates, curl, gnupg, lsb-release"
sudo echo -e "- Docker repository toegevoegd en Docker geïnstalleerd"
sudo echo -e "- SSH ingeschakeld en root login met wachtwoord toegestaan"
sudo echo -e "- Systeem opgeschoond en geschiedenis gewist${RESET}"

sudo echo "Je kunt nu Docker en SSH gebruiken."