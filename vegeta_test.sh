#!/bin/bash

# =============================================================================
# VEGETA ASCII TEST - mit jp2a
# =============================================================================

# Farben
GOLD='\033[38;5;220m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Cursor verstecken
tput civis

# Cleanup bei Exit
trap "tput cnorm; clear; exit" SIGINT SIGTERM

clear

echo -e "${GOLD}${BOLD}"
echo "  ╔═══════════════════════════════════════════════════════════════════╗"
echo "  ║                    PRINCE OF ALL SAIYANS                          ║"
echo "  ╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# jp2a mit Farben anzeigen
jp2a /Users/juliankonig/Documents/Workspace/Vegeta/vegeta.webp --colors --width=60

echo ""
echo -e "${GOLD}${BOLD}"
echo "  ╔═══════════════════════════════════════════════════════════════════╗"
echo "  ║              \"You won't survive this time, Kakarot!\"              ║"
echo "  ╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Cursor wieder anzeigen
tput cnorm
