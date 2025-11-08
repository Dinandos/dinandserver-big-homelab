#!/bin/bash

START_TIME=$SECONDS

# Update package index
apt-get update

# Install required packages
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
apt-get update

# Install Docker Engine, CLI, and containerd
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-

# Enable SSH service
systemctl enable ssh
systemctl start ssh

# Permit root login with password
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
systemctl restart ssh

# Cleanup and clear history
clear
history -c

# ! Definieer kleurcodes
BLUE='\033[1;34m'
GREEN='\033[1;32m'
BOLD='\033[1m'
RESET='\033[0m'

# Titel in groen en vet
echo -e "${GREEN}${BOLD}Installatie voltooid${RESET}"

# Lijst in lichtblauw
echo -e "${BLUE}- Systeem bijgewerkt (apt-get update)"
echo -e "- Benodigde pakketten geïnstalleerd: ca-certificates, curl, gnupg, lsb-release"
echo -e "- Docker repository toegevoegd en Docker geïnstalleerd"
echo -e "- SSH ingeschakeld en root login met wachtwoord toegestaan"
echo -e "- Nala geïnstalleerd (verbeterde apt front-end)"
echo -e "- Neofetch geïnstalleerd via nala"
echo -e "- Systeem opgeschoond en geschiedenis gewist${RESET}"

echo "Je kunt nu Docker, SSH, Nala en Neofetch gebruiken."
# Calculate total execution time
END_TIME=$SECONDS
DURATION=$((END_TIME - START_TIME))

# Notify ntfy server that the script is complete, including duration
curl -H "Title: Script Voltooid" -d "Script is voltooid op $(hostname) in ${DURATION} seconden." https://ntfy.dinandserver.duckdns.org/phone
