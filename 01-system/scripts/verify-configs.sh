#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAILED=0

echo "--- 🐳 Controleren van Docker Compose Netwerken ---"
FILES=$(find . -mindepth 2 \( -name "compose.yaml" -o -name "docker-compose.yml" \))
for f in $FILES; do
    if ! grep -qi "external: true" "$f"; then
        echo -e "${RED}[FOUT]${NC} $f mist 'external: true'"
        FAILED=1
    else
        echo -e "${GREEN}[OK]${NC} $f"
    fi
done

echo -e "\n--- 🌐 Controleren van Caddyfile Syntax ---"
if [ -f "./caddy-full/Caddyfile" ]; then
    if sudo docker run --rm -v ./caddy-full/Caddyfile:/etc/caddy/Caddyfile caddy:latest caddy validate --config /etc/caddy/Caddyfile > /dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} Caddyfile is valide."
    else
        echo -e "${RED}[FOUT]${NC} Caddyfile bevat fouten!"
        FAILED=1
    fi
else
    echo "Geen Caddyfile gevonden om te checken."
fi

exit $FAILED