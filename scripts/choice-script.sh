#!/bin/bash

# --- Variabelen ---
START_TIME=$SECONDS
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Flags om bij te houden wat uitgevoerd moet worden ---
INSTALL_DOCKER=false
CONFIGURE_SSH=false
CLEANUP_REQUIRED=false

# --- Functies (ongewijzigd, maar hier ingekort voor leesbaarheid) ---

functie_DockerInstallatie() {
    echo -e "${BLUE}${BOLD}--- Docker Installatie (D) ---${RESET}"
    # ... (apt-get update, install basispakketten, Docker setup logic)
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    # ... (rest van de Docker installatie)
    echo -e "${GREEN}✅ Docker installatie voltooid.${RESET}"
}

functie_SSHInstelling() {
    echo -e "${BLUE}${BOLD}--- SSH Configuratie (S) ---${RESET}"
    # ... (systemctl enable/start ssh, sed commands, systemctl restart ssh)
    echo -e "${GREEN}✅ SSH-instelling voltooid. ${RED}(Let op: Root login is toegestaan!)${RESET}"
}

functie_Cleanup() {
    echo -e "${BLUE}--- Opruimen en Afronden ---${RESET}"
    clear
    history -c
    END_TIME=$SECONDS
    DURATION=$((END_TIME - START_TIME))
    echo -e "${GREEN}${BOLD}Alle geselecteerde taken voltooid in ${DURATION} seconden.${RESET}"
    
    # Notify ntfy server
    curl -H "Title: Script Voltooid" -d "Geselecteerde taken voltooid op $(hostname) in ${DURATION} seconden." https://ntfy.dinandserver.duckdns.org/phone
}

# --- Gebruiksinformatie ---

show_help() {
    echo -e "${BOLD}Gebruik: ${RESET}./setup.sh [OPZIES]"
    echo ""
    echo -e "${BOLD}Opties:${RESET}"
    echo "  -d  | --docker    Voert Docker Installatie uit (incl. Basispakketten)."
    echo "  -s  | --ssh       Voert SSH Instelling uit (Root login toestaan)."
    echo "  -a  | --all       Voert ALLE taken uit (-d en -s)."
    echo "  -h  | --help      Toont deze helpinformatie."
    echo ""
    echo "Opmerking: Opruimen en Afronden wordt automatisch uitgevoerd na de taken."
}

# --- Argument Verwerking ---

# Controleer de argumenten
OPTIONS=$(getopt -o dsaq::h --long docker,ssh,all,cleanup::,help -n "$0" -- "$@")

if [ $? != 0 ] ; then 
    echo -e "${RED}Fout: Onjuiste argumenten.${RESET}" >&2 ; 
    show_help
    exit 1 
fi

eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -d|--docker)
            INSTALL_DOCKER=true
            CLEANUP_REQUIRED=true
            shift
            ;;
        -s|--ssh)
            CONFIGURE_SSH=true
            CLEANUP_REQUIRED=true
            shift
            ;;
        -a|--all)
            INSTALL_DOCKER=true
            CONFIGURE_SSH=true
            CLEANUP_REQUIRED=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo -e "${RED}Fout: Interne fout bij parsing ($1).${RESET}"
            exit 1
            ;;
    esac
done

# --- Uitvoering van de Geselecteerde Taken ---

if [ "$INSTALL_DOCKER" = true ]; then
    functie_DockerInstallatie
fi

if [ "$CONFIGURE_SSH" = true ]; then
    functie_SSHInstelling
fi

# --- Afronding ---

if [ "$CLEANUP_REQUIRED" = true ]; then
    functie_Cleanup
fi

if [ "$INSTALL_DOCKER" = false ] && [ "$CONFIGURE_SSH" = false ]; then
    echo -e "${YELLOW}Geen taken geselecteerd. Gebruik ${BOLD}-h${RESET}${YELLOW} voor hulp.${RESET}"
fi

exit 0