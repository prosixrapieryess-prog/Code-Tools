#!/bin/bash
 
# ==================================================
#  SERVER UTILITY MENU | v3.0 | by PROXLEGENDYT
# ==================================================
 
# --- COLORS ---
RED='\033[0;31m'
LRED='\033[1;31m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
PURPLE='\033[0;35m'
LPURPLE='\033[1;35m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DGRAY='\033[1;30m'
ORANGE='\033[38;5;214m'
PINK='\033[38;5;213m'
GOLD='\033[38;5;220m'
NC='\033[0m'
BD='\033[1m'
DIM='\033[2m'
 
# --- HELPER FUNCTIONS ---
pause() {
    echo ""
    echo -e "  ${DGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "  ${CYAN}  Press any key to return to menu...${NC}"
    read -n 1 -s -r
    echo ""
}
 
# --- BRANDING HEADER ---
show_brand() {
    echo ""
    echo -e "${LPURPLE}${BD}"
    echo '  ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗     ███████╗ ██████╗ ███████╗███╗  ██╗██████╗ ██╗   ██╗████████╗'
    echo -e "${CYAN}${BD}"
    echo '  ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝██║     ██╔════╝██╔════╝ ██╔════╝████╗ ██║██╔══██╗╚██╗ ██╔╝╚══██╔══╝'
    echo -e "${LBLUE}${BD}"
    echo '  ██████╔╝██████╔╝██║   ██║ ╚███╔╝ ██║     █████╗  ██║  ███╗█████╗  ██╔██╗██║██║  ██║ ╚████╔╝    ██║   '
    echo -e "${PURPLE}${BD}"
    echo '  ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗ ██║     ██╔══╝  ██║   ██║██╔══╝  ██║╚████║██║  ██║  ╚██╔╝     ██║   '
    echo -e "${PINK}${BD}"
    echo '  ██║     ██║  ██║╚██████╔╝██╔╝ ██╗███████╗███████╗╚██████╔╝███████╗██║ ╚███║██████╔╝   ██║      ██║   '
    echo -e "${LPURPLE}${BD}"
    echo '  ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚══╝╚═════╝    ╚═╝      ╚═╝   '
    echo -e "${NC}"
}
 
# ===================== TOOLS MENU =====================
tools_menu() {
    while true; do
        clear
 
        # --- BRAND ---
        show_brand
 
        # --- TOP BORDER ---
        echo -e "${LPURPLE}  ╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${LPURPLE}  ║${NC}  ${GOLD}${BD}          ⚡  SERVER UTILITIES & TOOLS  ⚡${NC}              ${LPURPLE}║${NC}"
        echo -e "${LPURPLE}  ╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${LPURPLE}  ║${NC}  ${DGRAY}Host: ${LCYAN}$(hostname)${NC}  ${DGRAY}|${NC}  ${DGRAY}User: ${LGREEN}$(whoami)${NC}                          ${LPURPLE}║${NC}"
        echo -e "${LPURPLE}  ╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
 
        # -- SECTION 1: NETWORK & ACCESS --
        echo -e "  ${LBLUE}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
        echo -e "  ${LBLUE}${BD}│  ${CYAN}◈  ACCESS & NETWORK${NC}                                      ${LBLUE}${BD}│${NC}"
        echo -e "  ${LBLUE}${BD}└─────────────────────────────────────────────────────────┘${NC}"
        echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Root Access     ${NC}${DGRAY}→  ${GREEN}Enable Root / Sudo${NC}"
        echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Tailscale       ${NC}${DGRAY}→  ${GREEN}Mesh VPN Setup${NC}"
        echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}Zerotier        ${NC}${DGRAY}→  ${GREEN}WiFi VPN Setup${NC}"
        echo ""
 
        # -- SECTION 2: SYSTEM & OPS --
        echo -e "  ${LGREEN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
        echo -e "  ${LGREEN}${BD}│  ${YELLOW}◈  SYSTEM OPERATIONS${NC}                                     ${LGREEN}${BD}│${NC}"
        echo -e "  ${LGREEN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
        echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}System Info     ${NC}${DGRAY}→  ${YELLOW}Specs & Status${NC}"
        echo -e "  ${GOLD}${BD}  5)${NC}  ${WHITE}Port Forward    ${NC}${DGRAY}→  ${YELLOW}TCP / UDP Tunnel${NC}"
        echo ""
 
        # -- SECTION 3: INTERFACE --
        echo -e "  ${PINK}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
        echo -e "  ${PINK}${BD}│  ${LPURPLE}◈  GUI & TERMINAL${NC}                                         ${PINK}${BD}│${NC}"
        echo -e "  ${PINK}${BD}└─────────────────────────────────────────────────────────┘${NC}"
        echo -e "  ${GOLD}${BD}  6)${NC}  ${WHITE}Web Terminal    ${NC}${DGRAY}→  ${PURPLE}Browser Shell${NC}"
        echo -e "  ${GOLD}${BD}  7)${NC}  ${WHITE}RDP Installer   ${NC}${DGRAY}→  ${PURPLE}Remote Desktop${NC}"
        echo -e "  ${GOLD}${BD}  8)${NC}  ${WHITE}SSL Panel       ${NC}${DGRAY}→  ${PURPLE}SSL Certificate Manager${NC}"
        echo ""
 
        # -- FOOTER --
        echo -e "  ${LPURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${LPURPLE}║${NC}  ${LRED}${BD}  0)  ↩  Exit / Back${NC}                                      ${LPURPLE}║${NC}"
        echo -e "  ${LPURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
 
        # -- INPUT --
        echo -ne "  ${LCYAN}${BD}  ➤  Select Tool → ${NC}"
        read t
 
        case $t in
            1) 
                clear
                echo -e "\n  ${LGREEN}${BD}[ ✔ ] Launching Root Access Script...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/ptero/refs/heads/main/ptero/tools/root.sh)
                pause ;;
            2) 
                clear
                echo -e "\n  ${LCYAN}${BD}[ ✔ ] Launching Tailscale Installer...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/ptero/refs/heads/main/ptero/tools/tailscale.sh)
                pause ;;
            3) 
                clear
                echo -e "\n  ${BLUE}${BD}[ ✔ ] Launching Zerotier Installer...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/ptero/refs/heads/main/ptero/tools/zerotier.sh)
                pause ;;
            4) 
                clear
                echo -e "\n  ${YELLOW}${BD}[ ✔ ] Fetching System Info...${NC}\n"
                bash <(curl -fsSL https://raw.githubusercontent.com/prosixrapieryess-prog/Code-Tools/main/info.sh)
                pause ;;
            5) 
                clear
                echo -e "\n  ${GREEN}${BD}[ ✔ ] Launching Port Forward Tool...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/ptero/refs/heads/main/ptero/tools/localtonet.sh)
                pause ;;
            6) 
                clear
                echo -e "\n  ${PURPLE}${BD}[ ✔ ] Installing Web Terminal...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/ptero/refs/heads/main/ptero/tools/terminal.sh)
                pause ;;
            7) 
                clear
                echo -e "\n  ${LPURPLE}${BD}[ ✔ ] Installing RDP...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/tools/rdp.sh)
                pause ;;
            8) 
                clear
                echo -e "\n  ${PINK}${BD}[ ✔ ] Installing SSL Panel...${NC}\n"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/hub/refs/heads/main/Codinghub/toolbox/mengssl.sh)
                pause ;;
            0) 
                clear
                echo -e "\n  ${GOLD}${BD}  👋  Goodbye from PROXLEGENDYT! See you soon.${NC}\n"
                sleep 1
                break ;;
            *) 
                echo -e "\n  ${LRED}${BD}  ✘  Invalid Option! Please choose from the menu.${NC}"
                sleep 1 ;;
        esac
    done
}
 
# --- EXECUTE ---
tools_menu
