#!/bin/bash

# Bestandnaam voor de master compose
MASTER_FILE="docker-compose.yml"

echo "name: mijn-homelab" > $MASTER_FILE
echo "" >> $MASTER_FILE
echo "include:" >> $MASTER_FILE

# Zoek alle compose files in submappen (maximaal 2 diep)
# We negeren de docker-compose.yml in de root zelf om oneindige lussen te voorkomen
find . -mindepth 2 -maxdepth 3 -name "docker-compose.yml" -o -name "compose.yml" | sort | while read file; do
    # Maak het pad relatief (bijv. ./app-1/docker-compose.yml)
    RELATIVE_PATH="./${file#./}"
    echo "  - $RELATIVE_PATH" >> $MASTER_FILE
    echo "Gevonden: $RELATIVE_PATH"
done

echo "✅ $MASTER_FILE is succesvol gegenereerd!"