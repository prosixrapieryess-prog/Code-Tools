#!/bin/bash
 
# ==================================================
#  ZEROTIER MESH COMMANDER v3.0
# ==================================================
 
# --- THEME & COLORS ---
RED='\033[1;31m'
LRED='\033[0;31m'
GREEN='\033[1;32m'
LGREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
LBLUE='\033[0;34m'
PURPLE='\033[1;35m'
LPURPLE='\033[0;35m'
CYAN='\033[1;36m'
LCYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DGRAY='\033[1;30m'
ORANGE='\033[38;5;214m'
PINK='\033[38;5;213m'
GOLD='\033[38;5;220m'
TEAL='\033[38;5;87m'
LIME='\033[38;5;154m'
NC='\033[0m'
BD='\033[1m'
 
# --- CURSOR TRAP ---
trap "tput cnorm; echo ''; exit 0" SIGINT SIGTERM
 
# --- HELPER FUNCTIONS ---
msg_info() { echo -e "  ${CYAN}${BD}  ➜  ${NC}${WHITE}$1${NC}"; }
msg_ok()   { echo -e "  ${GREEN}${BD}  ✔  ${NC}${LGREEN}$1${NC}"; }
msg_warn() { echo -e "  ${YELLOW}${BD}  ⚠  ${NC}${YELLOW}$1${NC}"; }
msg_err()  { echo -e "  ${RED}${BD}  ✖  ${NC}${LRED}$1${NC}"; }
 
divider() {
    echo -e "  ${DGRAY}  ─────────────────────────────────────────────────────${NC}"
}
 
pause() {
    echo ""
    tput cnorm
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
    tput civis
}
 
# --- BRANDING ---
show_brand() {
    echo ""
    echo -e "${LBLUE}${BD}  ███████╗███████╗██████╗  ██████╗ ████████╗██╗███████╗██████╗ ${NC}"
    echo -e "${CYAN}${BD}  ╚════██║██╔════╝██╔══██╗██╔═══██╗╚══██╔══╝██║██╔════╝██╔══██╗${NC}"
    echo -e "${TEAL}${BD}      ██╔╝█████╗  ██████╔╝██║   ██║   ██║   ██║█████╗  ██████╔╝${NC}"
    echo -e "${BLUE}${BD}     ██╔╝ ██╔══╝  ██╔══██╗██║   ██║   ██║   ██║██╔══╝  ██╔══██╗${NC}"
    echo -e "${PURPLE}${BD}     ██║  ███████╗██║  ██║╚██████╔╝   ██║   ██║███████╗██║  ██║${NC}"
    echo -e "${PINK}${BD}     ╚═╝  ╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝  ╚═╝${NC}"
    echo -e "  ${GOLD}${BD}                  MESH COMMANDER${NC}  ${DGRAY}v3.0  ⬡ Virtual Network Control${NC}"
    echo ""
}
 
# --- STATUS HELPERS ---
get_zt_status() {
    if ! command -v zerotier-cli &>/dev/null; then
        echo -e "${RED}${BD}◉ NOT INSTALLED${NC}"
        return
    fi
    if systemctl is-active --quiet zerotier-one 2>/dev/null; then
        echo -e "${LIME}${BD}◉ ACTIVE  ·  SERVICE RUNNING${NC}"
    else
        echo -e "${RED}${BD}◉ STOPPED${NC}"
    fi
}
 
get_zt_address() {
    if command -v zerotier-cli &>/dev/null && systemctl is-active --quiet zerotier-one 2>/dev/null; then
        local addr
        addr=$(zerotier-cli info 2>/dev/null | awk '{print $3}')
        [[ -n "$addr" ]] && echo -e "${CYAN}${BD}  $addr${NC}" || echo -e "${DGRAY}  ---${NC}"
    else
        echo -e "${DGRAY}  ---${NC}"
    fi
}
 
get_zt_version() {
    if command -v zerotier-cli &>/dev/null; then
        local ver
        ver=$(zerotier-cli info 2>/dev/null | awk '{print $4}')
        [[ -n "$ver" ]] && echo -e "${TEAL}  $ver${NC}" || echo -e "${DGRAY}  ---${NC}"
    else
        echo -e "${DGRAY}  ---${NC}"
    fi
}
 
get_network_count() {
    if command -v zerotier-cli &>/dev/null && systemctl is-active --quiet zerotier-one 2>/dev/null; then
        local count
        count=$(zerotier-cli listnetworks 2>/dev/null | grep -c "^[0-9a-f]" 2>/dev/null || echo 0)
        echo -e "${ORANGE}${BD}  $count network(s)${NC}"
    else
        echo -e "${DGRAY}  0 network(s)${NC}"
    fi
}
 
# --- HEADER ---
draw_header() {
    tput civis
    clear
    local host_name
    host_name=$(hostname 2>/dev/null || echo "Unknown-Host")
    local os_info
    os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    [[ -z "$os_info" ]] && os_info="Unknown OS"
 
    local zt_status zt_addr zt_version net_count
    zt_status=$(get_zt_status)
    zt_addr=$(get_zt_address)
    zt_version=$(get_zt_version)
    net_count=$(get_network_count)
 
    show_brand
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${GOLD}${BD}       ⚡  VIRTUAL NETWORK CONTROL SYSTEM  ⚡${NC}          ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}DEVICE   ${NC}  ${DGRAY}:${NC}  ${WHITE}${BD}$host_name${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}SYSTEM   ${NC}  ${DGRAY}:${NC}  ${GRAY}$os_info${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}VERSION  ${NC}  ${DGRAY}:${NC}  $zt_version"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${PINK}${BD}  🔗  ZEROTIER MESH STATUS${NC}"
    echo -e "  ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}SERVICE   :${NC}  $zt_status"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}NODE ADDR :${NC}  $zt_addr"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}NETWORKS  :${NC}  $net_count"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
 
# --- ACTIONS ---
 
deploy_and_join() {
    tput cnorm
    clear
    draw_header
    divider
    echo -e "  ${LIME}${BD}  [ DEPLOY & JOIN NETWORK ]${NC}"
    divider
    echo ""
 
    # Check already installed
    if command -v zerotier-cli &>/dev/null; then
        msg_warn "ZeroTier is already installed on this system."
        echo -ne "  ${PURPLE}${BD}  ➤  Skip install and just join a network? (y/N): ${NC}"
        tput cnorm
        read skip_install
        echo ""
        if [[ ! "$skip_install" =~ ^[Yy]$ ]]; then
            msg_info "Operation Cancelled."
            pause
            return
        fi
    else
        # Install
        echo -ne "  ${GOLD}${BD}  [1/2]${NC}  ${WHITE}Downloading & Installing ZeroTier...  ${NC}"
        if curl -s https://install.zerotier.com | bash >/dev/null 2>&1; then
            echo -e "${GREEN}${BD}✔ DONE${NC}"
        else
            echo -e "${RED}${BD}✖ FAILED${NC}"
            echo ""
            msg_err "Installation failed. Check your internet connection."
            pause
            return
        fi
 
        # Enable Service
        echo -ne "  ${GOLD}${BD}  [2/2]${NC}  ${WHITE}Enabling ZeroTier Service...          ${NC}"
        if systemctl enable --now zerotier-one >/dev/null 2>&1; then
            echo -e "${GREEN}${BD}✔ DONE${NC}"
        else
            echo -e "${YELLOW}${BD}⚠ SKIPPED (Manual start may be needed)${NC}"
        fi
        echo ""
    fi
 
    # Join Network
    echo -e "  ${YELLOW}${BD}  ┌────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  Enter the 16-character ZeroTier Network ID      │${NC}"
    echo -e "  ${YELLOW}${BD}  │     to join the private mesh network.               │${NC}"
    echo -e "  ${YELLOW}${BD}  └────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne "  ${CYAN}${BD}  ➤  Enter NETWORK_ID: ${NC}"
    tput cnorm
    read NETWORK_ID
    echo ""
 
    if [[ -n "$NETWORK_ID" ]]; then
        # Validate length (ZeroTier network IDs are 16 hex chars)
        if [[ ${#NETWORK_ID} -ne 16 ]]; then
            msg_warn "Network ID should be 16 characters. Attempting anyway..."
        fi
        msg_info "Joining network: ${CYAN}$NETWORK_ID${NC}"
        if zerotier-cli join "$NETWORK_ID" >/dev/null 2>&1; then
            echo ""
            divider
            msg_ok "Successfully joined network: ${CYAN}$NETWORK_ID${NC}"
            msg_ok "Approve this device in your ZeroTier Central dashboard."
            divider
        else
            echo ""
            divider
            msg_err "Failed to join network. Is ZeroTier service running?"
            divider
        fi
    else
        msg_warn "No Network ID entered. Skipping join step."
    fi
 
    pause
}
 
remove_zerotier() {
    tput cnorm
    clear
    draw_header
    divider
    echo -e "  ${RED}${BD}  [ REMOVE ZEROTIER COMPLETELY ]${NC}"
    divider
    echo ""
 
    if ! command -v zerotier-cli &>/dev/null; then
        msg_err "ZeroTier is not installed on this system."
        pause
        return
    fi
 
    msg_warn "DESTRUCTIVE ACTION — This will remove all ZeroTier networks and data."
    echo -e "  ${GRAY}  All joined networks will be disconnected.${NC}"
    echo ""
    echo -ne "  ${PURPLE}${BD}  ➤  Confirm Removal? (y/N): ${NC}"
    tput cnorm
    read confirm
    echo ""
 
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        msg_info "Leaving all networks..."
        zerotier-cli listnetworks 2>/dev/null | awk 'NR>1 {print $3}' | while read -r netid; do
            [[ -n "$netid" ]] && zerotier-cli leave "$netid" >/dev/null 2>&1
        done
 
        msg_info "Stopping ZeroTier Service..."
        systemctl stop zerotier-one 2>/dev/null
        systemctl disable zerotier-one 2>/dev/null
 
        msg_info "Removing Packages (Auto-Detect)..."
        if command -v apt &>/dev/null; then
            apt remove zerotier-one -y -qq >/dev/null 2>&1
            apt purge zerotier-one -y -qq >/dev/null 2>&1
        elif command -v dnf &>/dev/null; then
            dnf remove zerotier-one -y -q >/dev/null 2>&1
        elif command -v yum &>/dev/null; then
            yum remove zerotier-one -y -q >/dev/null 2>&1
        elif command -v apk &>/dev/null; then
            apk del zerotier-one >/dev/null 2>&1
        else
            msg_warn "Unknown package manager — binary may need manual removal."
        fi
 
        msg_info "Wiping Configuration & Data..."
        rm -rf /var/lib/zerotier-one /etc/zerotier-one 2>/dev/null
 
        echo ""
        divider
        msg_ok "ZeroTier completely removed from this system."
        divider
    else
        echo ""
        msg_info "Removal Cancelled. No changes made."
    fi
 
    pause
}
 
view_networks() {
    tput cnorm
    clear
    draw_header
    divider
    echo -e "  ${TEAL}${BD}  [ JOINED NETWORKS ]${NC}"
    divider
    echo ""
 
    if ! command -v zerotier-cli &>/dev/null; then
        msg_err "ZeroTier is not installed."
        pause
        return
    fi
 
    if ! systemctl is-active --quiet zerotier-one 2>/dev/null; then
        msg_err "ZeroTier service is not running. Start it first."
        pause
        return
    fi
 
    msg_info "Fetching joined networks..."
    echo ""
 
    # Column headers
    printf "  ${GOLD}${BD}  %-20s %-18s %-12s %s${NC}\n" "NETWORK ID" "NAME" "STATUS" "IP ASSIGNED"
    echo -e "  ${DGRAY}  ──────────────────────────────────────────────────────${NC}"
 
    local found=0
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^200 ]] && continue
        found=1
 
        local net_id name status ip_assign
        net_id=$(echo "$line" | awk '{print $3}')
        name=$(echo "$line" | awk '{print $4}')
        status=$(echo "$line" | awk '{print $6}')
        ip_assign=$(echo "$line" | awk '{print $9}')
        [[ -z "$ip_assign" ]] && ip_assign="---"
 
        if [[ "$status" == "OK" ]]; then
            status_c="${GREEN}${BD}● OK${NC}"
        elif [[ "$status" == "ACCESS_DENIED" ]]; then
            status_c="${RED}${BD}● DENIED${NC}"
        else
            status_c="${YELLOW}${BD}● $status${NC}"
        fi
 
        printf "  ${CYAN}  %-20s${NC} ${LCYAN}%-18s${NC} %-12b ${TEAL}%s${NC}\n" \
            "$net_id" "$name" "$status_c" "$ip_assign"
    done < <(zerotier-cli listnetworks 2>/dev/null)
 
    if [[ "$found" -eq 0 ]]; then
        echo -e "  ${DGRAY}  No networks joined yet.${NC}"
    fi
 
    echo ""
    divider
    pause
}
 
leave_network() {
    tput cnorm
    clear
    draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ LEAVE A NETWORK ]${NC}"
    divider
    echo ""
 
    if ! command -v zerotier-cli &>/dev/null; then
        msg_err "ZeroTier is not installed."
        pause
        return
    fi
 
    if ! systemctl is-active --quiet zerotier-one 2>/dev/null; then
        msg_err "ZeroTier service is not running."
        pause
        return
    fi
 
    echo -ne "  ${CYAN}${BD}  ➤  Enter NETWORK_ID to leave: ${NC}"
    tput cnorm
    read LEAVE_ID
    echo ""
 
    if [[ -n "$LEAVE_ID" ]]; then
        msg_info "Leaving network: ${CYAN}$LEAVE_ID${NC}"
        if zerotier-cli leave "$LEAVE_ID" >/dev/null 2>&1; then
            divider
            msg_ok "Successfully left network: ${CYAN}$LEAVE_ID${NC}"
            divider
        else
            divider
            msg_err "Failed to leave. Check the network ID and try again."
            divider
        fi
    else
        msg_warn "No Network ID entered. Nothing changed."
    fi
 
    pause
}
 
# --- MAIN LOOP ---
while true; do
    draw_header
 
    # Core Operations
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  CORE OPERATIONS${NC}                                        ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Deploy & Join Network    ${NC}${DGRAY}→  ${GREEN}Install & Connect${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Remove ZeroTier          ${NC}${DGRAY}→  ${RED}Uninstall Completely${NC}"
    echo ""
 
    # Network Management
    echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  NETWORK MANAGEMENT${NC}                                     ${YELLOW}${BD}│${NC}"
    echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}View Joined Networks     ${NC}${DGRAY}→  ${CYAN}List All Networks${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Leave a Network          ${NC}${DGRAY}→  ${YELLOW}Disconnect from Network${NC}"
    echo ""
 
    # Footer
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${RED}${BD}  0)  ↩  Exit ZeroTier Commander${NC}                          ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    tput cnorm
    echo -ne "  ${BLUE}${BD}  root@zerotier:~# ${NC}"
    read option
 
    case $option in
        1) deploy_and_join ;;
        2) remove_zerotier ;;
        3) view_networks ;;
        4) leave_network ;;
        0)
            tput cnorm
            clear
            echo ""
            echo -e "  ${GOLD}${BD}  👋  Exiting ZeroTier Commander. Network stays active!${NC}"
            echo ""
            sleep 1
            exit 0 ;;
        *)
            tput cnorm
            msg_err "Invalid Option! Choose 0–4."
            sleep 1 ;;
    esac
done
