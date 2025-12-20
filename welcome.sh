#!/bin/bash
# Vaporwave terminal welcome with arrow key navigation

# === CONFIGURATION (override these before sourcing) ===
WELCOME_DIR="${WELCOME_DIR:-$HOME/code}"
WELCOME_LIMIT="${WELCOME_LIMIT:-10}"
WELCOME_AUTO="${WELCOME_AUTO:-true}"

welcome() {
    local SELECTED=0

    # Colors
    local C_RESET='\033[0m' C_CYAN='\033[36m' C_MAGENTA='\033[35m'
    local C_PINK='\033[95m' C_PURPLE='\033[94m' C_YELLOW='\033[33m' C_GREEN='\033[32m'

    # Scan directory and get filesystem modification times
    local -a all_dirs=() all_mtimes=()

    [ -d "$WELCOME_DIR" ] && for d in "$WELCOME_DIR"/*/; do
        d="${d%/}"
        [ -d "$d" ] && {
            all_dirs+=("$d")
            all_mtimes+=($(stat -c %Y "$d" 2>/dev/null || echo 0))
        }
    done

    [ ${#all_dirs[@]} -eq 0 ] && return

    # Sort by modification time (bubble sort)
    for ((i=0; i<${#all_dirs[@]}-1; i++)); do
        for ((j=i+1; j<${#all_dirs[@]}; j++)); do
            [ ${all_mtimes[$j]} -gt ${all_mtimes[$i]} ] && {
                local t=${all_dirs[$i]}; all_dirs[$i]=${all_dirs[$j]}; all_dirs[$j]=$t
                t=${all_mtimes[$i]}; all_mtimes[$i]=${all_mtimes[$j]}; all_mtimes[$j]=$t
            }
        done
    done

    # Take top N most recently modified
    local -a dirs=()
    for i in "${!all_dirs[@]}"; do
        [ $i -ge "$WELCOME_LIMIT" ] && break
        dirs+=("${all_dirs[$i]}")
    done

    # Draw function
    draw() {
        clear
        echo -e "\n${C_PINK}  ╔═════════════════════════════════════╗      ${C_CYAN}██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗${C_RESET}"
        echo -e "${C_PINK}  ║ ${C_MAGENTA}◢◤◢◤◢◤◢◤${C_RESET} ${C_CYAN}D I R E C T O R Y${C_RESET}${C_MAGENTA} ◥◣◥◣◥◣◥◣${C_RESET}${C_PINK} ║      ${C_CYAN}██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║${C_RESET}"
        echo -e "${C_PINK}  ║ ${C_MAGENTA}◥◣◥◣◥◣◥◣${C_RESET} ${C_CYAN}N A V I G A T O R${C_RESET}${C_MAGENTA} ◢◤◢◤◢◤◢◤${C_RESET}${C_PINK} ║      ${C_CYAN}██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║${C_RESET}"
        echo -e "${C_PINK}  ╚═════════════════════════════════════╝      ${C_CYAN}██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║${C_RESET}"
        echo -e "                                               ${C_CYAN}╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝${C_RESET}"
        echo -e "${C_YELLOW}  ▼ Most Recently Modified:${C_RESET}                     ${C_RESET}╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝${C_RESET}"
        echo -e "${C_CYAN}  ────────────────────────────────────${C_RESET}"
        echo ""

        for i in "${!dirs[@]}"; do
            local name=$(basename "${dirs[$i]}")
            local prefix="   "
            local style="${C_RESET}"

            if [ $i -eq $SELECTED ]; then
                prefix="${C_PINK} ▶ ${C_RESET}"
                style="${C_CYAN}"
            fi

            printf "  %b%b%-32s%b\n" "$prefix" "$style" "$name" "${C_RESET}"
        done

        echo ""
        echo -e "${C_MAGENTA}     ◢◤◢◤◢◤◢◤  V A P O R W A V E  ◢◤◢◤◢◤◢◤${C_RESET}"
        echo ""
        echo -e "${C_PURPLE}  ↑/↓ Navigate  ${C_GREEN}Enter${C_PURPLE} CD  ${C_YELLOW}C${C_PURPLE} Claude  ${C_PINK}Esc${C_PURPLE} Exit${C_RESET}"
        echo ""
    }

    # Main loop
    draw

    while true; do
        read -rsn1 key

        if [ "$key" = $'\x1b' ]; then
            read -rsn2 -t 0.01 rest
            key="$key$rest"
        fi

        case "$key" in
            $'\x1b[A'|$'\x1bOA') # Up arrow
                [ $SELECTED -gt 0 ] && ((SELECTED--)) && draw
                ;;
            $'\x1b[B'|$'\x1bOB') # Down arrow
                [ $SELECTED -lt $((${#dirs[@]}-1)) ] && ((SELECTED++)) && draw
                ;;
            $'\x1b'|$'\x1b\x1b') # Esc
                clear
                return 0
                ;;
            '') # Enter
                clear
                cd "${dirs[$SELECTED]}"
                return 0
                ;;
            c|C) # Claude
                clear
                echo -e "${C_CYAN}Opening Claude Code...${C_RESET}"
                claude "${dirs[$SELECTED]}"
                return 0
                ;;
        esac
    done
}

# Auto-run: interactive shell + enabled + not already run
if [[ $- == *i* && "$WELCOME_AUTO" == "true" && -z "$_WELCOME_RAN" ]]; then
    export _WELCOME_RAN=1
    welcome
fi
