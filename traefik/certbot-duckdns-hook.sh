#!/bin/bash
# Certbot DuckDNS Hook Script - Definitieve Correctie

# --- Configuratie (VERVANG DEZE WAARDEN) ---
# Alleen het subdomein (bijv. 'dinandos', niet 'dinandos.duckdns.org')
DUCKDNS_SUBDOMAIN="dinandos" 
# Jouw DuckDNS Token
DUCKDNS_TOKEN="fb700a2a-e9b9-4775-8999-c6e73656108c" 
# Wachtijd (nodig voor DNS-propagatie)
WAIT_TIME=90

# --- Functies ---

# 1. Authenticatie (TXT record plaatsen)
authenticate() {
    # Certbot levert $CERTBOT_DOMAIN en $CERTBOT_VALIDATION automatisch aan.
    echo "Authenticatie: Plaatsen TXT record..."
    
    # Gebruik cURL om de TXT record te zetten met de validatiewaarde
    # Dit doet: Voegt &txt={WAARDE} toe aan de update URL.
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}&txt=${CERTBOT_VALIDATION}&verbose=true")

    if [[ "$RESPONSE" == *OK* ]]; then
        echo "DuckDNS TXT record succesvol bijgewerkt. Wachten ${WAIT_TIME}s..."
        sleep ${WAIT_TIME}
    else
        echo "Fout bij TXT-update. Respons: ${RESPONSE}"
        exit 1 
    fi
}

# 2. Opruiming (TXT record verwijderen)
cleanup() {
    echo "Opruiming: Verwijderen TXT record..."

    # Gebruik cURL om de TXT record te wissen
    # Dit doet: Gebruikt &clear=true om de TXT record te wissen.
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}&clear=true&verbose=true")

    if [[ "$RESPONSE" == *OK* ]]; then
        echo "DuckDNS TXT record succesvol verwijderd."
    else
        echo "Fout bij TXT-opruiming. Respons: ${RESPONSE}"
    fi
}

# --- Hoofdlogica ---

# De "case" stuurt Certbot's aanroep naar de juiste functie.
case "$1" in
    "auth")
        authenticate
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        echo "Ongeldige aanroep. Gebruik 'auth' of 'cleanup'."
        exit 1
        ;;
esac

exit 0