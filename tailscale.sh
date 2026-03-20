#!/bin/bash
 
# ==================================================
#  TAILSCALE MESH COMMANDER v3.1 — INSTALL FIX
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
 
# --- HELPER FUNCTIONS ---
msg_info() { echo -e "  ${CYAN}${BD}  ➜  ${NC}${WHITE}$1${NC}"; }
msg_ok()   { echo -e "  ${GREEN}${BD}  ✔  ${NC}${LGREEN}$1${NC}"; }
msg_warn() { echo -e "  ${YELLOW}${BD}  ⚠  ${NC}${YELLOW}$1${NC}"; }
msg_err()  { echo -e "  ${RED}${BD}  ✖  ${NC}${LRED}$1${NC}"; }
 
divider() {
    echo -e "  ${DGRAY}  ─────────────────────────────────────────────────────${NC}"
}
 
get_hostname() {
    if command -v hostname &>/dev/null; then
        hostname
    elif [ -f /etc/hostname ]; then
        head -n 1 /etc/hostname
    else
        echo "Unknown-Host"
    fi
}
 
# --- BRANDING ---
show_brand() {
    echo ""
    echo -e "${LBLUE}${BD}  ████████╗ █████╗ ██╗██╗      ███████╗ ██████╗ █████╗ ██╗     ███████╗${NC}"
    echo -e "${CYAN}${BD}  ╚══██╔══╝██╔══██╗██║██║      ██╔════╝██╔════╝██╔══██╗██║     ██╔════╝${NC}"
    echo -e "${TEAL}${BD}     ██║   ███████║██║██║      ███████╗██║     ███████║██║     █████╗  ${NC}"
    echo -e "${BLUE}${BD}     ██║   ██╔══██║██║██║      ╚════██║██║     ██╔══██║██║     ██╔══╝  ${NC}"
    echo -e "${PURPLE}${BD}     ██║   ██║  ██║██║███████╗███████║╚██████╗██║  ██║███████╗███████╗${NC}"
    echo -e "${PINK}${BD}     ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝${NC}"
    echo -e "  ${GOLD}${BD}                    MESH COMMANDER${NC}  ${DGRAY}v3.1  ⬡ Secure Network Overlay${NC}"
    echo ""
}
 
# --- HEADER ---
draw_header() {
    clear
    local host_name=$(get_hostname)
    local os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    [[ -z "$os_info" ]] && os_info="Unknown OS"
 
    local ts_status="${RED}${BD}◉ NOT INSTALLED${NC}"
    local ts_ip="${DGRAY}  ---${NC}"
    local exit_node="${DGRAY}  OFF${NC}"
    local health_check="${RED}${BD}◉ DISCONNECTED${NC}"
    local ts_version="${DGRAY}  ---${NC}"
    local peer_count="${DGRAY}  0${NC}"
 
    if command -v tailscale &>/dev/null; then
        ts_version="${TEAL}$(tailscale version 2>/dev/null | head -n1)${NC}"
        if systemctl is-active --quiet tailscaled 2>/dev/null; then
            ts_status="${LIME}${BD}◉ ACTIVE  ·  MESH ONLINE${NC}"
            local ip_fetch
            ip_fetch=$(tailscale ip -4 2>/dev/null)
            if [[ -n "$ip_fetch" ]]; then
                ts_ip="${CYAN}${BD}  $ip_fetch${NC}"
                health_check="${GREEN}${BD}◉ CONNECTED${NC}"
            else
                ts_ip="${YELLOW}  Needs Authentication${NC}"
                health_check="${YELLOW}${BD}◉ PENDING AUTH${NC}"
            fi
            if tailscale status 2>/dev/null | grep -q "exit node"; then
                exit_node="${PURPLE}${BD}  ACTIVE${NC}"
            else
                exit_node="${DGRAY}  INACTIVE${NC}"
            fi
            local pc
            pc=$(tailscale status 2>/dev/null | grep -c "^\s*[0-9]" 2>/dev/null || echo 0)
            peer_count="${ORANGE}${BD}  $pc peers${NC}"
        else
            ts_status="${RED}${BD}◉ SERVICE STOPPED${NC}"
        fi
    fi
 
    show_brand
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${GOLD}${BD}        ⚡  SECURE NETWORK OVERLAY SYSTEM  ⚡${NC}          ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}DEVICE   ${NC}  ${DGRAY}:${NC}  ${WHITE}${BD}$host_name${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}SYSTEM   ${NC}  ${DGRAY}:${NC}  ${GRAY}$os_info${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}VERSION  ${NC}  ${DGRAY}:${NC}  $ts_version"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${PINK}${BD}  🔗  MESH STATUS${NC}"
    echo -e "  ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}STATUS    :${NC}  $ts_status"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}VIRTUAL IP:${NC}  $ts_ip"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}EXIT NODE :${NC}  $exit_node"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}PEERS     :${NC}  $peer_count"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}HEALTH    :${NC}  $health_check"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
 
# ==================================================
#  INSTALL TAILSCALE — FULLY FIXED
# ==================================================
install_tailscale() {
    clear
    draw_header
    divider
    echo -e "  ${LIME}${BD}  [ INSTALL & CONNECT TO MESH ]${NC}"
    divider
    echo ""
 
    # --- Already installed: offer re-auth ---
    if command -v tailscale &>/dev/null; then
        msg_warn "Tailscale is already installed."
        echo -ne "  ${PURPLE}${BD}  ➤  Re-authenticate instead? (y/N): ${NC}"
        read -r reauth
        echo ""
        if [[ "$reauth" =~ ^[Yy]$ ]]; then
            msg_info "Launching Authentication..."
            echo ""
            tailscale up
            echo ""
            if command -v tailscale &>/dev/null && tailscale ip -4 &>/dev/null; then
                msg_ok "Re-authentication complete! Connected to Mesh."
            else
                msg_warn "Authentication may be pending — check the link above."
            fi
        else
            msg_info "Operation Cancelled."
        fi
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
 
    # --- STEP 1: Check internet connectivity first ---
    echo -ne "  ${GOLD}${BD}  [0/3]${NC}  ${WHITE}Checking internet connectivity...  ${NC}"
    if curl -fsSL --max-time 8 --head https://tailscale.com >/dev/null 2>&1; then
        echo -e "${GREEN}${BD}✔ ONLINE${NC}"
    else
        echo -e "${RED}${BD}✖ NO CONNECTION${NC}"
        echo ""
        divider
        msg_err "Cannot reach tailscale.com — check your internet connection."
        echo ""
        echo -e "  ${YELLOW}${BD}  Possible fixes:${NC}"
        echo -e "  ${DGRAY}  ·  Check if your server has outbound port 443 open${NC}"
        echo -e "  ${DGRAY}  ·  Try: ${WHITE}ping google.com${NC}"
        echo -e "  ${DGRAY}  ·  Try: ${WHITE}curl -v https://tailscale.com${NC}"
        divider
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
 
    # --- STEP 2: Download install script FIRST, verify, then run ---
    echo -ne "  ${GOLD}${BD}  [1/3]${NC}  ${WHITE}Downloading install script...      ${NC}"
    curl -fsSL --max-time 30 https://tailscale.com/install.sh -o /tmp/tailscale_install.sh 2>/dev/null
    local curl_exit=$?
 
    if [[ $curl_exit -ne 0 || ! -s /tmp/tailscale_install.sh ]]; then
        echo -e "${RED}${BD}✖ DOWNLOAD FAILED (curl exit: $curl_exit)${NC}"
        echo ""
        msg_err "Could not download installer. Check connectivity."
        rm -f /tmp/tailscale_install.sh
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
    echo -e "${GREEN}${BD}✔ DOWNLOADED${NC}"
 
    # --- STEP 3: Run the installer ---
    echo -ne "  ${GOLD}${BD}  [2/3]${NC}  ${WHITE}Running installer...               ${NC}"
    bash /tmp/tailscale_install.sh >/dev/null 2>&1
    local install_exit=$?
    rm -f /tmp/tailscale_install.sh
 
    # Verify binary actually exists — don't trust exit code alone
    if ! command -v tailscale &>/dev/null; then
        echo -e "${RED}${BD}✖ INSTALL FAILED${NC}"
        echo ""
        divider
        msg_err "Tailscale binary not found after install (exit: $install_exit)."
        echo ""
        echo -e "  ${YELLOW}${BD}  Try manual install:${NC}"
        echo -e "  ${WHITE}  curl -fsSL https://tailscale.com/install.sh | sh${NC}"
        divider
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
    echo -e "${GREEN}${BD}✔ INSTALLED$(tailscale version 2>/dev/null | head -n1 | sed 's/^/ (v/')${NC})"
 
    # --- STEP 4: Enable and start the daemon ---
    echo -ne "  ${GOLD}${BD}  [3/3]${NC}  ${WHITE}Enabling Tailscale daemon...       ${NC}"
    if systemctl enable --now tailscaled >/dev/null 2>&1; then
        echo -e "${GREEN}${BD}✔ SERVICE ACTIVE${NC}"
    else
        echo -e "${YELLOW}${BD}⚠ Could not enable via systemctl${NC}"
        msg_warn "Trying to start daemon directly..."
        tailscaled --state=/var/lib/tailscale/tailscaled.state &>/dev/null &
        sleep 2
    fi
 
    # --- STEP 5: Authenticate ---
    echo ""
    echo -e "  ${YELLOW}${BD}  ┌────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  A URL will appear below. Open it in a browser   │${NC}"
    echo -e "  ${YELLOW}${BD}  │     to authenticate and join the Tailscale network. │${NC}"
    echo -e "  ${YELLOW}${BD}  └────────────────────────────────────────────────────┘${NC}"
    echo ""
 
    tailscale up 2>&1
 
    # --- Verify connection ---
    echo ""
    divider
    local ts_ip_check
    ts_ip_check=$(tailscale ip -4 2>/dev/null)
    if [[ -n "$ts_ip_check" ]]; then
        msg_ok "Connected! Tailscale IP: ${CYAN}${BD}$ts_ip_check${NC}"
        msg_ok "Device successfully joined the Mesh Network!"
    else
        msg_warn "Tailscale installed but not yet authenticated."
        msg_warn "Complete auth in your browser — then run option 1 again to re-auth."
    fi
    divider
 
    echo ""
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
# ==================================================
#  UNINSTALL TAILSCALE
# ==================================================
uninstall_tailscale() {
    clear
    draw_header
    divider
    echo -e "  ${RED}${BD}  [ UNINSTALL TAILSCALE ]${NC}"
    divider
    echo ""
 
    if ! command -v tailscale &>/dev/null; then
        msg_err "Tailscale is not installed on this system."
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
 
    msg_warn "DESTRUCTIVE ACTION — This will sever all mesh connections."
    echo -e "  ${GRAY}  All peers will lose access to this device.${NC}"
    echo ""
    echo -ne "  ${PURPLE}${BD}  ➤  Confirm Removal? (y/N): ${NC}"
    read -r confirm
    echo ""
 
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        msg_info "Disconnecting from Mesh..."
        tailscale down 2>/dev/null
 
        msg_info "Stopping Services..."
        systemctl stop tailscaled 2>/dev/null
        systemctl disable tailscaled 2>/dev/null
 
        msg_info "Removing Packages (Auto-Detect)..."
        if command -v apt &>/dev/null; then
            apt purge tailscale -y -qq >/dev/null 2>&1
        elif command -v dnf &>/dev/null; then
            dnf remove tailscale -y -q >/dev/null 2>&1
        elif command -v yum &>/dev/null; then
            yum remove tailscale -y -q >/dev/null 2>&1
        elif command -v apk &>/dev/null; then
            apk del tailscale >/dev/null 2>&1
        else
            msg_warn "Unknown package manager — manual removal may be needed."
        fi
 
        msg_info "Wiping Configuration Files..."
        rm -rf /var/lib/tailscale /etc/tailscale 2>/dev/null
 
        echo ""
        divider
        msg_ok "Tailscale completely removed from this system."
        divider
    else
        echo ""
        msg_info "Uninstall Cancelled. No changes made."
    fi
 
    echo ""
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
# ==================================================
#  NETWORK MAP
# ==================================================
network_map() {
    clear
    draw_header
    divider
    echo -e "  ${TEAL}${BD}  [ MESH NETWORK MAP ]${NC}"
    divider
    echo ""
 
    if ! command -v tailscale &>/dev/null; then
        msg_err "Tailscale is not installed."
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
 
    if ! systemctl is-active --quiet tailscaled 2>/dev/null; then
        msg_err "Tailscale daemon is not running. Start it first."
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
 
    msg_info "Scanning Mesh Peers..."
    echo ""
 
    printf "  ${GOLD}${BD}  %-22s %-18s %-12s %s${NC}\n" "HOSTNAME" "IP ADDRESS" "STATUS" "OS/DETAIL"
    echo -e "  ${DGRAY}  ──────────────────────────────────────────────────────${NC}"
 
    tailscale status 2>/dev/null | while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue
 
        local ip name status detail
        ip=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        status=$(echo "$line" | awk '{print $4}')
        detail=$(echo "$line" | awk '{print $5, $6}')
 
        local status_colored
        if [[ "$status" == "active" || "$status" == "online" ]]; then
            status_colored="${GREEN}${BD}● $status${NC}"
        elif [[ "$status" == "idle" ]]; then
            status_colored="${YELLOW}${BD}● $status${NC}"
        else
            status_colored="${DGRAY}● $status${NC}"
        fi
 
        printf "  ${CYAN}  %-22s${NC} ${LCYAN}%-18s${NC} %-12b ${GRAY}%s${NC}\n" \
            "$name" "$ip" "$status_colored" "$detail"
    done
 
    echo ""
    divider
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
# ==================================================
#  NETCHECK / DIAGNOSTICS
# ==================================================
run_netcheck() {
    clear
    draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ TROUBLESHOOTING & DIAGNOSTICS ]${NC}"
    divider
    echo ""
 
    if ! command -v tailscale &>/dev/null; then
        msg_err "Tailscale is not installed."
        echo ""
        echo -ne "  ${CYAN}  Press any key to return...${NC}"
        read -n 1 -s -r
        echo ""
        return
    fi
 
    msg_info "Running Network Health Check (tailscale netcheck)..."
    echo ""
    echo -e "  ${DGRAY}  ──────────────────────────────────────────────────────${NC}"
    tailscale netcheck 2>&1 | sed 's/^/  /'
    echo -e "  ${DGRAY}  ──────────────────────────────────────────────────────${NC}"
    echo ""
    msg_ok "Netcheck complete."
    echo ""
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
# ==================================================
#  MAIN LOOP
# ==================================================
while true; do
    draw_header
 
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  CORE OPERATIONS${NC}                                        ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Install & Connect     ${NC}${DGRAY}→  ${GREEN}Join Mesh Network${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Uninstall Completely  ${NC}${DGRAY}→  ${RED}Leave & Remove Tailscale${NC}"
    echo ""
 
    echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  DIAGNOSTICS${NC}                                            ${YELLOW}${BD}│${NC}"
    echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}View Network Map      ${NC}${DGRAY}→  ${CYAN}List All Peers${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Troubleshooting Logs  ${NC}${DGRAY}→  ${YELLOW}Run Netcheck & Debug${NC}"
    echo ""
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${RED}${BD}  0)  ↩  Exit Mesh Commander${NC}                              ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${BLUE}${BD}  root@tailscale:~# ${NC}"
    read -r option
 
    case $option in
        1) install_tailscale ;;
        2) uninstall_tailscale ;;
        3) network_map ;;
        4) run_netcheck ;;
        0)
            clear
            echo ""
            echo -e "  ${GOLD}${BD}  👋  Disconnecting UI. Mesh stays running. Goodbye!${NC}"
            echo ""
            sleep 1
            exit 0 ;;
        *)
            msg_err "Invalid Option! Choose 0–4."
            sleep 1 ;;
    esac
done
