#!/bin/bash

# =============================================================================
# VEGETA AURA ANIMATION - mit jp2a
# =============================================================================
# Usage: ./vegeta_aura.sh [scale]
#   scale: 0.5 = klein, 1.0 = normal, 1.5 = groß
#   oder "auto" für automatische Terminal-Erkennung (default)
# =============================================================================

# Skalierung (Parameter oder auto)
SCALE_INPUT="${1:-auto}"

# Terminal-Größe ermitteln
TERM_COLS=$(tput cols)
TERM_ROWS=$(tput lines)

# Skalierungsfaktor berechnen
if [[ "$SCALE_INPUT" == "auto" ]]; then
    # Basierend auf Terminal-Breite UND -Höhe
    # Wir brauchen ca. 86 Zeilen für das normale Bild, ca. 80 für SSJ
    # Plus ein paar Zeilen für Aura und Text
    
    # Höhen-basierter Scale
    if (( TERM_ROWS >= 100 )); then
        HEIGHT_SCALE=1.0
    elif (( TERM_ROWS >= 80 )); then
        HEIGHT_SCALE=0.8
    elif (( TERM_ROWS >= 60 )); then
        HEIGHT_SCALE=0.6
    elif (( TERM_ROWS >= 45 )); then
        HEIGHT_SCALE=0.5
    elif (( TERM_ROWS >= 35 )); then
        HEIGHT_SCALE=0.4
    else
        HEIGHT_SCALE=0.3
    fi
    
    # Breiten-basierter Scale
    if (( TERM_COLS >= 120 )); then
        WIDTH_SCALE=1.0
    elif (( TERM_COLS >= 100 )); then
        WIDTH_SCALE=0.8
    elif (( TERM_COLS >= 80 )); then
        WIDTH_SCALE=0.6
    elif (( TERM_COLS >= 60 )); then
        WIDTH_SCALE=0.5
    else
        WIDTH_SCALE=0.4
    fi
    
    # Nimm den kleineren Wert
    if (( $(echo "$HEIGHT_SCALE < $WIDTH_SCALE" | bc -l) )); then
        SCALE=$HEIGHT_SCALE
    else
        SCALE=$WIDTH_SCALE
    fi
    
    echo "Terminal: ${TERM_COLS}x${TERM_ROWS}, scale: ${SCALE} (w:${WIDTH_SCALE} h:${HEIGHT_SCALE})"
else
    SCALE="$SCALE_INPUT"
    echo "Manual scale: ${SCALE}, Terminal: ${TERM_COLS}x${TERM_ROWS}"
fi

# Bild-Breiten berechnen (Basis: 60 für normal, 100 für SSJ)
BASE_WIDTH=60
SSJ_WIDTH=100
VEGETA_WIDTH=$(printf "%.0f" "$(echo "$BASE_WIDTH * $SCALE" | bc)")
SSJ_VEGETA_WIDTH=$(printf "%.0f" "$(echo "$SSJ_WIDTH * $SCALE" | bc)")
AURA_WIDTH=$(printf "%.0f" "$(echo "65 * $SCALE" | bc)")

# Mindestbreite
(( VEGETA_WIDTH < 25 )) && VEGETA_WIDTH=25
(( SSJ_VEGETA_WIDTH < 40 )) && SSJ_VEGETA_WIDTH=40
(( AURA_WIDTH < 30 )) && AURA_WIDTH=30

echo "Vegeta: ${VEGETA_WIDTH}w, SSJ: ${SSJ_VEGETA_WIDTH}w"
sleep 1

# Farben
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GOLD='\033[38;5;220m'
ORANGE='\033[38;5;208m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Bild-Pfade
IMG="/Users/juliankonig/Documents/Workspace/Vegeta/vegeta.webp"
IMG_SSJ="/Users/juliankonig/Documents/Workspace/Vegeta/vegeta_ssj1_attack.webp"
IMG_EXPLOSION="/Users/juliankonig/Documents/Workspace/Vegeta/explosion.png"

# Temp-Dateien für ASCII Art
VEGETA_FILE="/tmp/vegeta_ascii.txt"
VEGETA_SSJ_FILE="/tmp/vegeta_ssj_ascii.txt"
EXPLOSION_FILE="/tmp/explosion_ascii.txt"

# Cursor verstecken
tput civis

# Cleanup bei Exit
cleanup() {
    tput cnorm
    rm -f "$VEGETA_FILE" "$VEGETA_SSJ_FILE" "$EXPLOSION_FILE"
    clear
    exit
}
trap cleanup SIGINT SIGTERM

# ASCII Art generieren und in Dateien speichern
echo "Loading Vegeta..." 
jp2a "$IMG" --colors --width="$VEGETA_WIDTH" > "$VEGETA_FILE"
jp2a "$IMG_SSJ" --colors --width="$SSJ_VEGETA_WIDTH" > "$VEGETA_SSJ_FILE"
jp2a "$IMG_EXPLOSION" --colors --width="$SSJ_VEGETA_WIDTH" > "$EXPLOSION_FILE"
clear

# Einfache Ausgabe
print_vegeta() {
    cat "$VEGETA_FILE"
}

# Shake-Effekt: Jede Zeile zufällig versetzt
print_shake() {
    local max_shake=$1
    while IFS= read -r line; do
        local offset=$((RANDOM % (max_shake + 1)))
        printf "%*s%s\n" "$offset" "" "$line"
    done < "$VEGETA_FILE"
}

# Wellen-Effekt: Zeilen wellenförmig versetzt
print_wave() {
    local frame=$1
    local amplitude=$2
    local i=0
    while IFS= read -r line; do
        local wave_offset=$(( (i + frame) % 6 ))
        case $wave_offset in
            0) offset=0 ;;
            1) offset=$amplitude ;;
            2) offset=$((amplitude * 2)) ;;
            3) offset=$((amplitude * 2)) ;;
            4) offset=$amplitude ;;
            5) offset=0 ;;
        esac
        printf "%*s%s\n" "$offset" "" "$line"
        ((i++))
    done < "$VEGETA_FILE"
}

# Pulse-Effekt: Bild "atmet"
print_pulse() {
    local phase=$1
    local i=0
    local total_lines=$(wc -l < "$VEGETA_FILE")
    while IFS= read -r line; do
        if [[ $phase -eq 1 ]]; then
            if (( i % 15 == 0 && i > 10 && i < total_lines - 10 )); then
                ((i++))
                continue
            fi
        elif [[ $phase -eq 2 ]]; then
            if (( i % 20 == 0 && i > 5 && i < total_lines - 5 )); then
                echo ""
            fi
        fi
        echo "$line"
        ((i++))
    done < "$VEGETA_FILE"
}

# Power-Vibration
print_power_vibrate() {
    local intensity=$1
    while IFS= read -r line; do
        local offset=$((RANDOM % (intensity + 1)))
        printf "%*s%s\n" "$offset" "" "$line"
    done < "$VEGETA_FILE"
}

# SSJ Funktionen
print_ssj() {
    cat "$VEGETA_SSJ_FILE"
}

print_ssj_vibrate() {
    local intensity=$1
    while IFS= read -r line; do
        local offset=$((RANDOM % (intensity + 1)))
        printf "%*s%s\n" "$offset" "" "$line"
    done < "$VEGETA_SSJ_FILE"
}

# Explosion Funktionen
print_explosion() {
    cat "$EXPLOSION_FILE"
}

print_explosion_shake() {
    local intensity=$1
    while IFS= read -r line; do
        local offset=$((RANDOM % (intensity + 1)))
        printf "%*s%s\n" "$offset" "" "$line"
    done < "$EXPLOSION_FILE"
}

# =============================================================================
# FRAME: Titel einblenden
# =============================================================================
title_animation() {
    clear
    sleep 0.3
    
    echo ""
    echo ""
    echo -e "${GOLD}${BOLD}"
    
    # Buchstabe für Buchstabe
    text="  ══════════════════════════════════════════════════════"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep 0.008
    done
    echo ""
    
    sleep 0.2
    
    title="                    V E G E T A"
    for ((i=0; i<${#title}; i++)); do
        printf "%s" "${title:$i:1}"
        sleep 0.05
    done
    echo ""
    
    sleep 0.2
    
    subtitle="               Prince of all Saiyans"
    echo -e "${CYAN}"
    for ((i=0; i<${#subtitle}; i++)); do
        printf "%s" "${subtitle:$i:1}"
        sleep 0.02
    done
    echo ""
    
    echo -e "${GOLD}${BOLD}"
    text2="  ══════════════════════════════════════════════════════"
    for ((i=0; i<${#text2}; i++)); do
        printf "%s" "${text2:$i:1}"
        sleep 0.008
    done
    echo -e "${NC}"
    
    sleep 1
}

# =============================================================================
# FRAME: Vegeta erscheint + "atmet"
# =============================================================================
vegeta_appear() {
    clear
    echo ""
    print_vegeta
    sleep 1
    
    # Atmen-Animation (3 Zyklen)
    for cycle in {1..2}; do
        clear
        echo ""
        print_pulse 1  # einatmen
        sleep 0.3
        
        clear
        echo ""
        print_pulse 0  # normal
        sleep 0.3
        
        clear
        echo ""
        print_pulse 2  # ausatmen
        sleep 0.3
    done
    
    clear
    echo ""
    print_vegeta
    sleep 0.5
}

# =============================================================================
# FRAME: Aura Effekt mit verschiedenen Bewegungen!
# =============================================================================
aura_frame() {
    local intensity=$1
    local color=$2
    local movement=$3  # "shake", "wave", "vibrate"
    
    clear
    
    # Aura-Zeichen basierend auf Intensität
    local aura_chars
    case $intensity in
        1) aura_chars=("·" "˚" " " " ") ;;
        2) aura_chars=("·" "˚" "°" "*") ;;
        3) aura_chars=("⚡" "✦" "·" "˚") ;;
        4) aura_chars=("⚡" "✦" "★" "⚡") ;;
    esac
    
    # Obere Aura (skaliert)
    echo -e "${color}"
    for i in {1..2}; do
        line=""
        for ((j=0; j<AURA_WIDTH; j++)); do
            idx=$((RANDOM % ${#aura_chars[@]}))
            line+="${aura_chars[$idx]}"
        done
        echo "  $line"
    done
    echo -e "${NC}"
    
    # Vegeta mit Bewegung
    case $movement in
        "wave")
            print_wave $((RANDOM % 6)) "$intensity"
            ;;
        "vibrate")
            print_power_vibrate "$intensity" "$color"
            ;;
        *)
            print_shake "$intensity"
            ;;
    esac
    
    # Untere Aura (skaliert)
    echo -e "${color}"
    for i in {1..2}; do
        line=""
        for ((j=0; j<AURA_WIDTH; j++)); do
            idx=$((RANDOM % ${#aura_chars[@]}))
            line+="${aura_chars[$idx]}"
        done
        echo "  $line"
    done
    echo -e "${NC}"
}

# =============================================================================
# Power-Up Sequenz mit verschiedenen Bewegungsarten!
# =============================================================================
power_up() {
    # Leichte Aura (cyan) - sanfte Wellen
    for i in {1..4}; do
        aura_frame 1 "${CYAN}" "wave"
        sleep 0.2
    done
    
    # Text
    echo ""
    echo -e "                    ${CYAN}${BOLD}Nnnngh...!${NC}"
    sleep 0.6
    
    # Mittlere Aura (cyan/white) - shake beginnt
    for i in {1..5}; do
        aura_frame 2 "${WHITE}" "shake"
        sleep 0.15
    done
    
    echo ""
    echo -e "                 ${WHITE}${BOLD}HAAAAAAAA!!!${NC}"
    sleep 0.4
    
    # Starke Aura (gelb) - intensivere Bewegung
    for i in {1..6}; do
        aura_frame 3 "${YELLOW}" "vibrate"
        sleep 0.1
    done
    
    echo ""
    echo -e "              ${YELLOW}${BOLD}HAAAAAAAAAAAA!!!!${NC}"
    sleep 0.3
    
    # Maximale Aura (gold) - kurz vor Transformation
    for i in {1..8}; do
        aura_frame 4 "${GOLD}" "vibrate"
        sleep 0.06
    done
}

# =============================================================================
# TRANSFORMATION - Der große Moment!
# =============================================================================
transformation_flash() {
    # Generiere Flash-Zeile basierend auf Terminal-Breite
    local flash_line=""
    for ((j=0; j<TERM_COLS; j++)); do
        flash_line+="█"
    done
    
    # Screen Flash - weiß
    clear
    echo -e "${WHITE}${BOLD}"
    for ((i=0; i<TERM_ROWS; i++)); do
        echo "$flash_line"
    done
    echo -e "${NC}"
    sleep 0.1
    
    # Screen Flash - gelb
    clear
    echo -e "${YELLOW}"
    for ((i=0; i<TERM_ROWS; i++)); do
        echo "$flash_line"
    done
    echo -e "${NC}"
    sleep 0.1
    
    # Screen Flash - weiß
    clear
    echo -e "${WHITE}${BOLD}"
    for ((i=0; i<TERM_ROWS; i++)); do
        echo "$flash_line"
    done
    echo -e "${NC}"
    sleep 0.1
}

# =============================================================================
# SSJ Reveal mit Aura
# =============================================================================
ssj_aura_frame() {
    local intensity=$1
    local ssj_aura_width=$((SSJ_VEGETA_WIDTH + 5))
    
    clear
    
    # Obere goldene Aura (skaliert)
    echo -e "${GOLD}"
    for i in {1..2}; do
        line=""
        for ((j=0; j<ssj_aura_width; j++)); do
            chars=("⚡" "✦" "★" "·" "˚")
            idx=$((RANDOM % ${#chars[@]}))
            line+="${chars[$idx]}"
        done
        echo "$line"
    done
    echo -e "${NC}"
    
    # SSJ Vegeta mit Shake
    print_ssj_vibrate "$intensity"
    
    # Untere goldene Aura (skaliert)
    echo -e "${GOLD}"
    for i in {1..2}; do
        line=""
        for ((j=0; j<ssj_aura_width; j++)); do
            chars=("⚡" "✦" "★" "·" "˚")
            idx=$((RANDOM % ${#chars[@]}))
            line+="${chars[$idx]}"
        done
        echo "$line"
    done
    echo -e "${NC}"
}

ssj_reveal() {
    # Transformation Flash
    transformation_flash
    
    # SSJ erscheint mit intensiver Aura
    for i in {1..10}; do
        ssj_aura_frame 4
        sleep 0.08
    done
    
    # Aura beruhigt sich
    for i in {1..5}; do
        ssj_aura_frame 2
        sleep 0.12
    done
    
    # Stabiler SSJ
    for i in {1..3}; do
        ssj_aura_frame 1
        sleep 0.2
    done
}

# =============================================================================
# EXPLOSION - FINAL FLASH IMPACT!
# =============================================================================
explosion_sequence() {
    local explosion_aura_width=$((SSJ_VEGETA_WIDTH + 10))
    
    # Schnelle weiße Flashes
    for flash in {1..3}; do
        clear
        echo -e "${WHITE}${BOLD}"
        for ((i=0; i<TERM_ROWS; i++)); do
            printf '%*s\n' "$TERM_COLS" '' | tr ' ' '█'
        done
        echo -e "${NC}"
        sleep 0.05
        
        clear
        echo -e "${YELLOW}"
        for ((i=0; i<TERM_ROWS; i++)); do
            printf '%*s\n' "$TERM_COLS" '' | tr ' ' '█'
        done
        echo -e "${NC}"
        sleep 0.05
    done
    
    # Explosion erscheint mit intensivem Shake
    for i in {1..8}; do
        clear
        echo -e "${ORANGE}"
        # Obere Aura
        line=""
        for ((j=0; j<explosion_aura_width; j++)); do
            chars=("💥" "✦" "★" "⚡" "🔥")
            idx=$((RANDOM % ${#chars[@]}))
            line+="${chars[$idx]}"
        done
        echo "$line"
        echo -e "${NC}"
        
        print_explosion_shake 4
        
        echo -e "${ORANGE}"
        line=""
        for ((j=0; j<explosion_aura_width; j++)); do
            chars=("💥" "✦" "★" "⚡" "🔥")
            idx=$((RANDOM % ${#chars[@]}))
            line+="${chars[$idx]}"
        done
        echo "$line"
        echo -e "${NC}"
        sleep 0.1
    done
    
    # Explosion beruhigt sich
    for i in {1..5}; do
        clear
        echo -e "${YELLOW}"
        line=""
        for ((j=0; j<explosion_aura_width; j++)); do
            chars=("·" "˚" "✦" "★")
            idx=$((RANDOM % ${#chars[@]}))
            line+="${chars[$idx]}"
        done
        echo "$line"
        echo -e "${NC}"
        
        print_explosion_shake 2
        
        echo -e "${YELLOW}"
        line=""
        for ((j=0; j<explosion_aura_width; j++)); do
            chars=("·" "˚" "✦" "★")
            idx=$((RANDOM % ${#chars[@]}))
            line+="${chars[$idx]}"
        done
        echo "$line"
        echo -e "${NC}"
        sleep 0.15
    done
    
    # Finale Explosion statisch
    clear
    print_explosion
    echo ""
    echo -e "                    ${ORANGE}${BOLD}💥 BOOOOM!!! 💥${NC}"
    sleep 1.5
}

# =============================================================================
# Victory Screen - SSJ Version
# =============================================================================
victory() {
    clear
    local ssj_aura_width=$((SSJ_VEGETA_WIDTH + 5))
    
    # Generiere skalierte Aura-Linie
    local aura_line=""
    for ((j=0; j<ssj_aura_width; j++)); do
        if (( j % 2 == 0 )); then
            aura_line+="⚡"
        else
            aura_line+="✦"
        fi
    done
    
    echo -e "${GOLD}"
    echo "$aura_line"
    echo -e "${NC}"
    
    print_ssj
    
    echo -e "${GOLD}"
    echo "$aura_line"
    echo ""
    echo -e "${BOLD}"
    echo "    ╔═══════════════════════════════════════════════════════════╗"
    echo "    ║                                                           ║"
    echo "    ║    \"I am a Super Saiyan! The Prince of all Saiyans!\"      ║"
    echo "    ║                                                           ║"
    echo "    ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    title_animation
    vegeta_appear
    power_up
    ssj_reveal          # Transformation zu SSJ!
    explosion_sequence  # FINAL FLASH EXPLOSION!
    victory
    
    sleep 3
    tput cnorm
    echo ""
}

main
