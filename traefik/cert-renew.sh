#!/bin/bash

# Dit script vernieuwt het Let's Encrypt certificaat met Certbot/DuckDNS en herstart Traefik.

# --- Config ---
DOMAIN="dinandos.duckdns.org"
EMAIL="dinand.tv123@gmail.com"
CERT_PATH="./certs"            # Pad naar je certificaten OP DE HOST
HOOK_SCRIPT="./certbot-duckdns-hook.sh" # Pad naar je DuckDNS hook script OP DE HOST

# Maak het hook script uitvoerbaar: chmod +x certbot-duckdns-hook.sh

# 1. Vernieuw Certificaat
echo "Start Certbot vernieuwing voor $DOMAIN..."
# We gebruiken --force-renewal voor de test, maar verwijder dit voor productie (vervang door 'renew').
docker run --rm \
  -v "$CERT_PATH:/etc/letsencrypt" \
  -v "$HOOK_SCRIPT:/hook.sh" \
  certbot/certbot \
  renew \
  --manual-auth-hook /hook.sh \
  --manual-cleanup-hook /hook.sh \
  --post-hook "echo Certificaat succesvol vernieuwd!" # **Dit doet** de vernieuwing uitvoeren.

# 2. Herstart Traefik (alleen bij succes)
if [ $? -eq 0 ]; then
    echo "Certificaatvernieuwing succesvol, Traefik herstarten..."
    docker restart traefik # **Dit doet** Traefik dwingen de nieuwe certificaatbestanden in de /certs map te laden.
    echo "Traefik herstart. Vernieuwingsproces voltooid."
else
    echo "Fout bij Certbot vernieuwing. Traefik niet herstart."
fi

# Zorg ervoor dat dit script uitvoerbaar is: chmod +x cert-renew.sh
# Stel een cronjob in voor automatische uitvoering (bijv. wekelijks).