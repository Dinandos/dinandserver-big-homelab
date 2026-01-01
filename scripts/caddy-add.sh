#!/bin/bash
CADDY_FILE="/opt/caddy-system/Caddyfile"

echo "--- Nieuw Subdomein Toevoegen ---"
read -p "Naam (bijv. portainer): " sub
read -p "Doel IP:Poort (bijv. 127.0.0.1:9443): " target

# We zoeken de regel met 'handle {' (de standaard fallback) 
# en plaatsen de nieuwe matcher/handle daar net boven.
MATCHER="    @$sub host $sub.dinandserver.duckdns.org\n    handle @$sub {\n        reverse_proxy $target\n    }\n"

# Invoegen voor de laatste 'handle {' regel
sed -i "/handle {/i $MATCHER" "$CADDY_FILE"

docker exec caddy caddy reload
echo "Klaar! $sub.dinandserver.duckdns.org is nu actief."