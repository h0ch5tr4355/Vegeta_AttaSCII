#!/bin/bash

# =============================================================================
# VEGETA - IT'S OVER 9000!!! - ASCII Animation
# =============================================================================
# Usage: ./vegeta_over9000.sh [scale]
#   scale: 0.5 = klein, 1.0 = normal
#   oder "auto" für automatische Terminal-Erkennung (default)
# =============================================================================

# Skalierung (Parameter oder auto)
SCALE_INPUT="${1:-auto}"

# Terminal-Größe ermitteln
TERM_COLS=$(tput cols)
TERM_ROWS=$(tput lines)

# Skalierungsfaktor berechnen
if [[ "$SCALE_INPUT" == "auto" ]]; then
    if (( TERM_ROWS >= 50 )); then
        HEIGHT_SCALE=1.0
    elif (( TERM_ROWS >= 40 )); then
        HEIGHT_SCALE=0.8
    elif (( TERM_ROWS >= 30 )); then
        HEIGHT_SCALE=0.6
    else
        HEIGHT_SCALE=0.5
    fi
    
    if (( TERM_COLS >= 100 )); then
        WIDTH_SCALE=1.0
    elif (( TERM_COLS >= 80 )); then
        WIDTH_SCALE=0.8
    elif (( TERM_COLS >= 60 )); then
        WIDTH_SCALE=0.6
    else
        WIDTH_SCALE=0.5
    fi
    
    if (( $(echo "$HEIGHT_SCALE < $WIDTH_SCALE" | bc -l) )); then
        SCALE=$HEIGHT_SCALE
    else
        SCALE=$WIDTH_SCALE
    fi
    echo "Terminal: ${TERM_COLS}x${TERM_ROWS}, scale: ${SCALE}"
else
    SCALE="$SCALE_INPUT"
    echo "Manual scale: ${SCALE}"
fi

# Bild-Breite
BASE_WIDTH=80
IMG_WIDTH=$(printf "%.0f" "$(echo "$BASE_WIDTH * $SCALE" | bc)")
(( IMG_WIDTH < 40 )) && IMG_WIDTH=40

echo "Width: ${IMG_WIDTH}"
sleep 1

# Farben
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GOLD='\033[38;5;220m'
ORANGE='\033[38;5;208m'
GREEN='\033[0;32m'
NC='\033[0m'
BOLD='\033[1m'
BLINK='\033[5m'

# Frame-Pfade
FRAMES_DIR="/Users/juliankonig/Documents/Workspace/Vegeta/over9000_frames"

# Temp-Dateien
FRAME1="/tmp/over9000_frame1.txt"
FRAME2="/tmp/over9000_frame2.txt"
FRAME3="/tmp/over9000_frame3.txt"
FRAME4="/tmp/over9000_frame4.txt"

# Cursor verstecken
tput civis

# Cleanup
cleanup() {
    tput cnorm
    rm -f "$FRAME1" "$FRAME2" "$FRAME3" "$FRAME4"
    clear
    exit
}
trap cleanup SIGINT SIGTERM

# Frames generieren
echo "Loading frames..."
jp2a "$FRAMES_DIR/frame_001.png" --colors --width="$IMG_WIDTH" > "$FRAME1"
jp2a "$FRAMES_DIR/frame_002.png" --colors --width="$IMG_WIDTH" > "$FRAME2"
jp2a "$FRAMES_DIR/frame_003.png" --colors --width="$IMG_WIDTH" > "$FRAME3"
jp2a "$FRAMES_DIR/frame_004.png" --colors --width="$IMG_WIDTH" > "$FRAME4"
clear

# Shake Funktion
print_shake() {
    local file=$1
    local intensity=$2
    while IFS= read -r line; do
        local offset=$((RANDOM % (intensity + 1)))
        printf "%*s%s\n" "$offset" "" "$line"
    done < "$file"
}

# =============================================================================
# SCENE 1: Scouter Reading
# =============================================================================
scene_scouter() {
    clear
    echo ""
    echo -e "${GREEN}${BOLD}"
    echo "    ╔════════════════════════════════════════════╗"
    echo "    ║           SCOUTER ACTIVATED                ║"
    echo "    ╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    sleep 1
    
    # Frame 1 - Vegeta schaut auf Scouter
    clear
    cat "$FRAME1"
    echo ""
    echo -e "${GREEN}    ▓▓▓ SCANNING... ▓▓▓${NC}"
    sleep 1.5
}

# =============================================================================
# SCENE 2: Power Level Rising
# =============================================================================
scene_power_rising() {
    # Scouter zeigt steigende Zahlen
    local numbers=(1000 2500 5000 7500 8000 8500 9000)
    
    for num in "${numbers[@]}"; do
        clear
        cat "$FRAME2"
        echo ""
        echo -e "${GREEN}${BOLD}"
        echo "    ╔════════════════════════════════════════════╗"
        printf "    ║        POWER LEVEL: %-20s ║\n" "$num"
        echo "    ╚════════════════════════════════════════════╝"
        echo -e "${NC}"
        sleep 0.3
    done
    
    # Scouter fängt an zu glitchen
    for i in {1..5}; do
        clear
        print_shake "$FRAME2" 2
        echo ""
        echo -e "${RED}${BOLD}"
        echo "    ╔════════════════════════════════════════════╗"
        local glitch=$((9000 + RANDOM % 100))
        printf "    ║        POWER LEVEL: %-20s ║\n" "$glitch"
        echo "    ║            ⚠️  WARNING ⚠️                   ║"
        echo "    ╚════════════════════════════════════════════╝"
        echo -e "${NC}"
        sleep 0.15
    done
}

# =============================================================================
# SCENE 3: IT'S OVER 9000!!!
# =============================================================================
scene_over9000() {
    # Dramatische Pause
    clear
    cat "$FRAME3"
    sleep 0.8
    
    # Screen flash
    for i in {1..3}; do
        clear
        echo -e "${WHITE}${BOLD}"
        for ((j=0; j<TERM_ROWS; j++)); do
            printf '%*s\n' "$TERM_COLS" '' | tr ' ' '█'
        done
        echo -e "${NC}"
        sleep 0.05
        
        clear
        echo -e "${YELLOW}"
        for ((j=0; j<TERM_ROWS; j++)); do
            printf '%*s\n' "$TERM_COLS" '' | tr ' ' '█'
        done
        echo -e "${NC}"
        sleep 0.05
    done
    
    # DER MOMENT!
    for i in {1..8}; do
        clear
        print_shake "$FRAME4" 4
        echo ""
        echo -e "${RED}${BOLD}"
        echo "    ╔════════════════════════════════════════════╗"
        echo "    ║                                            ║"
        echo "    ║       💥 POWER LEVEL: OVER 9000!!! 💥      ║"
        echo "    ║                                            ║"
        echo "    ╚════════════════════════════════════════════╝"
        echo -e "${NC}"
        sleep 0.1
    done
}

# =============================================================================
# SCENE 4: Scouter Explodes
# =============================================================================
scene_scouter_explodes() {
    # Mehr shake, scouter überhitzt
    for i in {1..6}; do
        clear
        print_shake "$FRAME4" 5
        echo ""
        echo -e "${ORANGE}${BOLD}${BLINK}"
        echo "    ⚠️⚠️⚠️ SCOUTER OVERLOAD ⚠️⚠️⚠️"
        echo -e "${NC}"
        sleep 0.08
    done
    
    # EXPLOSION!
    for i in {1..4}; do
        clear
        echo -e "${ORANGE}"
        for ((j=0; j<TERM_ROWS; j++)); do
            line=""
            for ((k=0; k<TERM_COLS; k++)); do
                chars=("💥" "✦" "★" "🔥" "⚡" " ")
                idx=$((RANDOM % ${#chars[@]}))
                line+="${chars[$idx]}"
            done
            echo "$line"
        done
        echo -e "${NC}"
        sleep 0.1
    done
    
    # Aftermath
    clear
    echo ""
    echo ""
    echo ""
    echo -e "${RED}${BOLD}"
    cat << 'EOF'
    
    
                    💥💥💥💥💥💥💥💥💥💥
                  💥                      💥
                💥   SCOUTER DESTROYED!    💥
                  💥                      💥
                    💥💥💥💥💥💥💥💥💥💥
    
    
EOF
    echo -e "${NC}"
    sleep 1.5
}

# =============================================================================
# SCENE 5: Vegeta's Reaction
# =============================================================================
scene_vegeta_reaction() {
    clear
    cat "$FRAME4"
    echo ""
    echo -e "${GOLD}${BOLD}"
    echo "    ╔════════════════════════════════════════════════════════╗"
    echo "    ║                                                        ║"
    echo "    ║    \"What?! 9000?! There's no way that can be right!\"   ║"
    echo "    ║                                                        ║"
    echo "    ╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    sleep 3
}

# =============================================================================
# FINALE: The Legendary Text
# =============================================================================
finale() {
    clear
    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}${BOLD}"
    
    # Langsam den Text aufbauen
    text="          IT'S OVER 9000!!!"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep 0.08
    done
    echo ""
    echo ""
    
    sleep 0.5
    
    # ASCII Art Text
    echo -e "${GOLD}"
    cat << 'EOF'
    
     ██████╗ ██╗   ██╗███████╗██████╗      █████╗  ██████╗  ██████╗  ██████╗ 
    ██╔═══██╗██║   ██║██╔════╝██╔══██╗    ██╔══██╗██╔═████╗██╔═████╗██╔═████╗
    ██║   ██║██║   ██║█████╗  ██████╔╝    ╚██████║██║██╔██║██║██╔██║██║██╔██║
    ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗     ╚═══██║████╔╝██║████╔╝██║████╔╝██║
    ╚██████╔╝ ╚████╔╝ ███████╗██║  ██║     █████╔╝╚██████╔╝╚██████╔╝╚██████╔╝
     ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝     ╚════╝  ╚═════╝  ╚═════╝  ╚═════╝ 
                                                                              
EOF
    echo -e "${NC}"
    
    sleep 2
    
    echo -e "${CYAN}"
    echo "                    - Vegeta, Prince of all Saiyans"
    echo -e "${NC}"
    
    sleep 3
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    scene_scouter
    scene_power_rising
    scene_over9000
    scene_scouter_explodes
    scene_vegeta_reaction
    finale
    
    tput cnorm
    echo ""
}

main
