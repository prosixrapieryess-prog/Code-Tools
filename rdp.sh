#!/bin/bash
 
# ==================================================
#  RDP + noVNC CONTROL PANEL v3.0
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
 
# --- HELPERS ---
msg_info() { echo -e "  ${CYAN}${BD}  ➜  ${NC}${WHITE}$1${NC}"; }
msg_ok()   { echo -e "  ${GREEN}${BD}  ✔  ${NC}${LGREEN}$1${NC}"; }
msg_warn() { echo -e "  ${YELLOW}${BD}  ⚠  ${NC}${YELLOW}$1${NC}"; }
msg_err()  { echo -e "  ${RED}${BD}  ✖  ${NC}${LRED}$1${NC}"; }
msg_step() { echo -e "\n  ${GOLD}${BD}  [$1/$2]${NC}  ${WHITE}$3${NC}"; }
 
divider() {
    echo -e "  ${DGRAY}  ─────────────────────────────────────────────────────${NC}"
}
 
pause() {
    echo ""
    divider
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
svc_status_badge() {
    if systemctl is-active --quiet "$1" 2>/dev/null; then
        echo -e "${LIME}${BD}◉ ACTIVE  ${NC}"
    else
        echo -e "${RED}${BD}◉ STOPPED ${NC}"
    fi
}
 
# --- ROOT CHECK ---
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "  ${RED}${BD}  ╔══════════════════════════════════════╗${NC}"
    echo -e "  ${RED}${BD}  ║   ✖  ROOT PRIVILEGES REQUIRED        ║${NC}"
    echo -e "  ${RED}${BD}  ╚══════════════════════════════════════╝${NC}"
    echo -e "  ${YELLOW}  Run with: ${WHITE}sudo bash $0${NC}"
    echo ""
    exit 1
fi
 
# ==================================================
#  BRANDING
# ==================================================
show_brand() {
    echo ""
    echo -e "${PURPLE}${BD}  ██████╗ ██████╗ ██████╗      ██╗   ██╗███╗   ██╗ ██████╗${NC}"
    echo -e "${PINK}${BD}  ██╔══██╗██╔══██╗██╔══██╗     ██║   ██║████╗  ██║██╔════╝${NC}"
    echo -e "${CYAN}${BD}  ██████╔╝██║  ██║██████╔╝     ██║   ██║██╔██╗ ██║██║     ${NC}"
    echo -e "${LBLUE}${BD}  ██╔══██╗██║  ██║██╔═══╝      ╚██╗ ██╔╝██║╚██╗██║██║     ${NC}"
    echo -e "${TEAL}${BD}  ██║  ██║██████╔╝██║     ███╗  ╚████╔╝ ██║ ╚████║╚██████╗${NC}"
    echo -e "${LPURPLE}${BD}  ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚══╝   ╚═══╝  ╚═╝  ╚═══╝ ╚═════╝${NC}"
    echo -e "  ${GOLD}${BD}           noVNC CONTROL PANEL${NC}  ${DGRAY}v3.0  ·  XFCE • xRDP • TigerVNC${NC}"
    echo ""
}
 
# ==================================================
#  HEADER
# ==================================================
draw_header() {
    clear
    show_brand
 
    local IP
    IP=$(curl -s --max-time 4 ifconfig.me 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')
    [[ -z "$IP" ]] && IP="N/A"
 
    echo -e "  ${PURPLE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}  ${GOLD}${BD}      ⚡  RDP + noVNC CONTROL CENTER  ⚡${NC}              ${PURPLE}${BD}║${NC}"
    echo -e "  ${PURPLE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}  ${DGRAY}HOST    :${NC}  ${WHITE}${BD}$(hostname)${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}  ${DGRAY}IP ADDR :${NC}  ${CYAN}${BD}$IP${NC}"
    echo -e "  ${PURPLE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}  ${PINK}${BD}  🔗  CONNECTION INFO${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}    ${DGRAY}RDP    :${NC}  ${GREEN}${BD}$IP:3389${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}    ${DGRAY}noVNC  :${NC}  ${CYAN}${BD}http://$IP:6080/vnc.html${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}    ${DGRAY}VNC    :${NC}  ${TEAL}${BD}$IP:5901${NC}"
    echo -e "  ${PURPLE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}  ${PINK}${BD}  ⚙   SERVICE STATUS${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}    ${DGRAY}xRDP   :${NC}  $(svc_status_badge xrdp)"
    echo -e "  ${PURPLE}${BD}║${NC}    ${DGRAY}noVNC  :${NC}  $(svc_status_badge novnc)"
    echo -e "  ${PURPLE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
 
# ==================================================
#  INSTALL ALL
# ==================================================
install_all() {
    clear; draw_header
    divider
    echo -e "  ${LIME}${BD}  [ FULL INSTALLATION ]${NC}"
    divider
    echo ""
 
    local TOTAL=7
 
    # STEP 1 — Update system
    msg_step 1 $TOTAL "Updating system packages..."
    apt-get update -qq >/dev/null 2>&1 && apt-get upgrade -y -qq >/dev/null 2>&1
    msg_ok "System updated."
 
    # STEP 2 — Install core desktop + remote tools
    msg_step 2 $TOTAL "Installing XFCE4 + xRDP + TigerVNC + noVNC..."
    apt-get install -y -qq \
        xfce4 xfce4-goodies xfce4-terminal \
        xrdp \
        tigervnc-standalone-server tigervnc-common \
        novnc websockify \
        firefox-esr \
        curl wget >/dev/null 2>&1
    msg_ok "Core packages installed."
 
    # STEP 3 — Configure xRDP
    msg_step 3 $TOTAL "Configuring xRDP..."
    systemctl enable xrdp >/dev/null 2>&1
    systemctl start xrdp >/dev/null 2>&1
    # Add xrdp to ssl-cert group (needed for certificate access)
    adduser xrdp ssl-cert >/dev/null 2>&1 || true
    # Set XFCE as default desktop session
    echo "xfce4-session" > ~/.xsession
    echo "xfce4-session" > /etc/skel/.xsession
    chmod +x ~/.xsession
    msg_ok "xRDP configured → port 3389."
 
    # STEP 4 — Configure VNC
    msg_step 4 $TOTAL "Configuring TigerVNC..."
    mkdir -p ~/.vnc
    # BUG FIX: vncpasswd -f needs echo piped in, not just run blind
    echo "root" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null
    chmod 600 ~/.vnc/passwd
 
    cat > ~/.vnc/config <<EOF
geometry=1280x720
depth=24
alwaysshared
EOF
 
    # BUG FIX: Kill existing VNC session before starting new one to avoid conflicts
    vncserver -kill :1 >/dev/null 2>&1 || true
    sleep 1
    vncserver -localhost no :1 >/dev/null 2>&1
    msg_ok "VNC configured → port 5901."
 
    # STEP 5 — Install noVNC service
    msg_step 5 $TOTAL "Setting up noVNC systemd service..."
    cat > /etc/systemd/system/novnc.service <<EOF
[Unit]
Description=noVNC Web Client
After=network.target
 
[Service]
Type=simple
User=root
ExecStart=/usr/bin/websockify --web=/usr/share/novnc/ 6080 localhost:5901
Restart=on-failure
RestartSec=5
 
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload >/dev/null 2>&1
    systemctl enable novnc >/dev/null 2>&1
    systemctl start novnc >/dev/null 2>&1
    msg_ok "noVNC service active → port 6080."
 
    # STEP 6 — Firewall
    msg_step 6 $TOTAL "Configuring firewall rules..."
    ufw allow 3389/tcp >/dev/null 2>&1 || true
    ufw allow 6080/tcp >/dev/null 2>&1 || true
    ufw allow 5901/tcp >/dev/null 2>&1 || true
    ufw reload >/dev/null 2>&1 || true
    msg_ok "Firewall rules applied (3389, 6080, 5901)."
 
    # STEP 7 — Browsers
    msg_step 7 $TOTAL "Installing web browsers..."
    install_browsers
 
    echo ""
    divider
    msg_ok "Full installation complete!"
    divider
    echo ""
    draw_header
    pause
}
 
# ==================================================
#  INSTALL BROWSERS
# ==================================================
install_browsers() {
    clear; draw_header
    divider
    echo -e "  ${CYAN}${BD}  [ BROWSER INSTALLER ]${NC}"
    divider
    echo ""
 
    local TOTAL=4
    local step=1
 
    # Firefox ESR (via apt)
    msg_step $step $TOTAL "Installing Firefox ESR..."
    if apt-get install -y -qq firefox-esr >/dev/null 2>&1; then
        msg_ok "Firefox ESR installed."
    else
        msg_warn "Firefox ESR skipped (may already exist)."
    fi
    ((step++))
 
    # Chromium
    msg_step $step $TOTAL "Installing Chromium..."
    if apt-get install -y -qq chromium >/dev/null 2>&1 || \
       apt-get install -y -qq chromium-browser >/dev/null 2>&1; then
        msg_ok "Chromium installed."
    else
        msg_warn "Chromium not available for this distro."
    fi
    ((step++))
 
    # Google Chrome
    msg_step $step $TOTAL "Installing Google Chrome..."
    local ARCH
    ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
    if [[ "$ARCH" == "amd64" ]]; then
        curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
            -o /tmp/chrome.deb >/dev/null 2>&1
        if apt-get install -y /tmp/chrome.deb >/dev/null 2>&1; then
            msg_ok "Google Chrome installed."
        else
            apt-get install -f -y -qq >/dev/null 2>&1
            msg_warn "Chrome install attempted with dependency fix."
        fi
        rm -f /tmp/chrome.deb
    else
        msg_warn "Chrome only supports amd64 — skipped on $ARCH."
    fi
    ((step++))
 
    # Brave (optional)
    msg_step $step $TOTAL "Brave Browser (optional)..."
    echo ""
    echo -ne "  ${CYAN}${BD}  ➤  Install Brave Browser? (y/N): ${NC}"
    read -r install_brave
    echo ""
    if [[ "$install_brave" =~ ^[Yy]$ ]]; then
        curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
            https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
            >/dev/null 2>&1
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" \
            > /etc/apt/sources.list.d/brave-browser-release.list
        apt-get update -qq >/dev/null 2>&1
        if apt-get install -y -qq brave-browser >/dev/null 2>&1; then
            msg_ok "Brave Browser installed."
        else
            msg_err "Brave installation failed."
        fi
    else
        msg_info "Brave skipped."
    fi
 
    # Fix sandbox flags for all browsers (needed in RDP/VNC sessions)
    _fix_browser_desktop_entries
 
    echo ""
    divider
    msg_ok "Browser setup complete."
    divider
    pause
}
 
# --- Fix .desktop entries for RDP/VNC sandbox compatibility ---
_fix_browser_desktop_entries() {
    msg_info "Applying --no-sandbox flags for RDP/VNC compatibility..."
 
    local fixes=(
        "/usr/share/applications/google-chrome.desktop:Exec=/usr/bin/google-chrome-stable:Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-dev-shm-usage"
        "/usr/share/applications/brave-browser.desktop:Exec=/usr/bin/brave-browser-stable:Exec=/usr/bin/brave-browser-stable --no-sandbox --disable-dev-shm-usage"
        "/usr/share/applications/chromium.desktop:Exec=/usr/bin/chromium:Exec=/usr/bin/chromium --no-sandbox --disable-dev-shm-usage"
        "/usr/share/applications/chromium-browser.desktop:Exec=/usr/bin/chromium-browser:Exec=/usr/bin/chromium-browser --no-sandbox --disable-dev-shm-usage"
    )
 
    for entry in "${fixes[@]}"; do
        local file="${entry%%:*}"
        local rest="${entry#*:}"
        local old="${rest%%:*}"
        local new="${rest#*:}"
        if [[ -f "$file" ]]; then
            sed -i "s|^Exec=.*${old##*/}.*|$new|g" "$file" 2>/dev/null || true
        fi
    done
 
    # Copy .desktop shortcuts to Desktop
    mkdir -p ~/Desktop
    for f in google-chrome.desktop brave-browser.desktop chromium.desktop \
              chromium-browser.desktop firefox-esr.desktop firefox.desktop; do
        [[ -f "/usr/share/applications/$f" ]] && \
            cp "/usr/share/applications/$f" ~/Desktop/ 2>/dev/null || true
    done
    chmod +x ~/Desktop/*.desktop 2>/dev/null || true
 
    # Mark as trusted (if gio is available)
    if command -v gio &>/dev/null; then
        for d in ~/Desktop/*.desktop; do
            gio set "$d" metadata::trusted true 2>/dev/null || true
        done
    fi
 
    # Reload desktop (non-fatal if xfdesktop not running)
    xfdesktop --reload 2>/dev/null || true
    msg_ok "Browser desktop entries fixed."
}
 
# ==================================================
#  SERVICE CONTROLS
# ==================================================
start_services() {
    clear; draw_header
    divider
    echo -e "  ${LIME}${BD}  [ START SERVICES ]${NC}"
    divider
    echo ""
 
    msg_info "Starting xRDP..."
    if systemctl start xrdp 2>/dev/null; then
        msg_ok "xRDP started."
    else
        msg_err "xRDP failed to start."
    fi
 
    msg_info "Starting VNC server..."
    # BUG FIX: kill any existing session first to avoid 'display already in use' error
    vncserver -kill :1 >/dev/null 2>&1 || true
    sleep 1
    if vncserver -localhost no :1 >/dev/null 2>&1; then
        msg_ok "VNC server started on :1 (port 5901)."
    else
        msg_err "VNC server failed to start."
    fi
 
    msg_info "Starting noVNC..."
    if systemctl start novnc 2>/dev/null; then
        msg_ok "noVNC started on port 6080."
    else
        msg_err "noVNC failed to start."
    fi
 
    echo ""
    divider
    msg_ok "All services started."
    divider
    pause
}
 
stop_services() {
    clear; draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ STOP SERVICES ]${NC}"
    divider
    echo ""
 
    msg_info "Stopping xRDP..."
    systemctl stop xrdp 2>/dev/null && msg_ok "xRDP stopped." || msg_warn "xRDP was not running."
 
    msg_info "Stopping VNC server..."
    vncserver -kill :1 >/dev/null 2>&1 && msg_ok "VNC server stopped." || msg_warn "VNC was not running."
 
    msg_info "Stopping noVNC..."
    systemctl stop novnc 2>/dev/null && msg_ok "noVNC stopped." || msg_warn "noVNC was not running."
 
    echo ""
    divider
    msg_ok "All services stopped."
    divider
    pause
}
 
restart_services() {
    clear; draw_header
    divider
    echo -e "  ${CYAN}${BD}  [ RESTART SERVICES ]${NC}"
    divider
    echo ""
 
    msg_info "Restarting xRDP..."
    systemctl restart xrdp 2>/dev/null && msg_ok "xRDP restarted." || msg_err "xRDP restart failed."
 
    msg_info "Restarting VNC server..."
    vncserver -kill :1 >/dev/null 2>&1 || true
    sleep 1
    vncserver -localhost no :1 >/dev/null 2>&1 && msg_ok "VNC restarted." || msg_err "VNC restart failed."
 
    msg_info "Restarting noVNC..."
    systemctl restart novnc 2>/dev/null && msg_ok "noVNC restarted." || msg_err "noVNC restart failed."
 
    echo ""
    divider
    msg_ok "All services restarted."
    divider
    pause
}
 
# ==================================================
#  STATUS
# ==================================================
status_services() {
    clear; draw_header
    divider
    echo -e "  ${TEAL}${BD}  [ SERVICE & PORT STATUS ]${NC}"
    divider
    echo ""
 
    # Service status
    echo -e "  ${PINK}${BD}  SERVICES:${NC}"
    echo ""
 
    for svc in xrdp novnc; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo -e "    ${DGRAY}$svc${NC}  →  ${LIME}${BD}◉ ACTIVE${NC}"
        else
            echo -e "    ${DGRAY}$svc${NC}  →  ${RED}${BD}◉ STOPPED${NC}"
        fi
    done
 
    # VNC process check
    if pgrep -x "Xtigervnc" >/dev/null 2>&1 || pgrep -x "Xvnc" >/dev/null 2>&1; then
        echo -e "    ${DGRAY}vnc   ${NC}  →  ${LIME}${BD}◉ ACTIVE${NC}"
    else
        echo -e "    ${DGRAY}vnc   ${NC}  →  ${RED}${BD}◉ STOPPED${NC}"
    fi
 
    echo ""
    echo -e "  ${PINK}${BD}  OPEN PORTS:${NC}"
    echo ""
 
    local ports=(3389 6080 5901)
    local labels=("xRDP" "noVNC" "VNC ")
    local i=0
 
    # BUG FIX: use 'ss' with fallback to 'netstat' (netstat not always installed)
    local port_cmd="ss -tulpn"
    command -v ss &>/dev/null || port_cmd="netstat -tulpn"
 
    for port in "${ports[@]}"; do
        if $port_cmd 2>/dev/null | grep -q ":$port "; then
            echo -e "    ${DGRAY}${labels[$i]} :${NC}  ${GREEN}${BD}◉ LISTENING on :$port${NC}"
        else
            echo -e "    ${DGRAY}${labels[$i]} :${NC}  ${DGRAY}◉ NOT listening on :$port${NC}"
        fi
        ((i++))
    done
 
    echo ""
    echo -e "  ${PINK}${BD}  ACTIVE CONNECTIONS:${NC}"
    echo ""
    $port_cmd 2>/dev/null | grep -E ":3389|:6080|:5901" | \
        awk '{print "    " $1 "\t" $5 "\t→\t" $6}' || \
        echo -e "    ${DGRAY}None${NC}"
 
    echo ""
    divider
    pause
}
 
# ==================================================
#  VNC PASSWORD
# ==================================================
change_vnc_password() {
    clear; draw_header
    divider
    echo -e "  ${YELLOW}${BD}  [ VNC PASSWORD MANAGER ]${NC}"
    divider
    echo ""
 
    msg_info "Updating VNC password..."
    echo ""
    vncpasswd
 
    echo ""
    divider
    if [ $? -eq 0 ]; then
        msg_ok "Password updated. Restart VNC to apply."
        msg_warn "Use Option 4 (Restart) to apply the new password."
    else
        msg_err "Password change failed."
    fi
    divider
    pause
}
 
# ==================================================
#  USER MANAGEMENT
# ==================================================
user_management() {
    clear; draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ USER MANAGEMENT ]${NC}"
    divider
    echo ""
    bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/tools/xrdp.sh) 2>/dev/null \
        || msg_err "Could not fetch user management script."
    pause
}
 
# ==================================================
#  UNINSTALL
# ==================================================
uninstall_all() {
    clear; draw_header
    divider
    echo -e "  ${RED}${BD}  [ FULL UNINSTALL ]${NC}"
    divider
    echo ""
 
    msg_warn "DESTRUCTIVE ACTION — This removes ALL RDP/VNC/browser components."
    echo -e "  ${GRAY}  xRDP · TigerVNC · noVNC · XFCE4 · Browsers · Configs${NC}"
    echo ""
    echo -ne "  ${RED}${BD}  ➤  Type 'YES' to confirm full removal: ${NC}"
    read -r confirm
    echo ""
 
    if [[ "$confirm" != "YES" ]]; then
        msg_info "Uninstall cancelled. No changes made."
        pause
        return
    fi
 
    local TOTAL=7
    local step=1
 
    # STEP 1 — Stop services
    msg_step $step $TOTAL "Stopping all services..."
    systemctl stop xrdp novnc 2>/dev/null || true
    vncserver -kill :1 >/dev/null 2>&1 || true
    msg_ok "Services stopped."
    ((step++))
 
    # STEP 2 — Remove xRDP
    msg_step $step $TOTAL "Removing xRDP..."
    apt-get purge -y -qq xrdp >/dev/null 2>&1
    rm -rf /etc/xrdp 2>/dev/null
    msg_ok "xRDP removed."
    ((step++))
 
    # STEP 3 — Remove VNC
    msg_step $step $TOTAL "Removing TigerVNC..."
    apt-get purge -y -qq \
        tigervnc-standalone-server \
        tigervnc-common >/dev/null 2>&1
    rm -rf ~/.vnc 2>/dev/null
    msg_ok "TigerVNC removed."
    ((step++))
 
    # STEP 4 — Remove noVNC
    msg_step $step $TOTAL "Removing noVNC..."
    apt-get purge -y -qq novnc websockify >/dev/null 2>&1
    rm -f /etc/systemd/system/novnc.service 2>/dev/null
    systemctl daemon-reload >/dev/null 2>&1
    msg_ok "noVNC removed."
    ((step++))
 
    # STEP 5 — Remove XFCE4
    msg_step $step $TOTAL "Removing XFCE4 desktop..."
    apt-get purge -y -qq xfce4 xfce4-goodies xfce4-terminal >/dev/null 2>&1
    rm -f ~/.xsession /etc/skel/.xsession 2>/dev/null
    msg_ok "XFCE4 removed."
    ((step++))
 
    # STEP 6 — Remove browsers
    msg_step $step $TOTAL "Removing browsers..."
    apt-get purge -y -qq \
        google-chrome-stable \
        firefox firefox-esr \
        chromium chromium-browser \
        brave-browser >/dev/null 2>&1
    # Remove repos and keys
    rm -f /etc/apt/sources.list.d/google-chrome.list \
          /etc/apt/sources.list.d/brave-browser-release.list \
          /usr/share/keyrings/google-chrome.gpg \
          /usr/share/keyrings/brave-browser-archive-keyring.gpg 2>/dev/null
    # Remove desktop shortcuts
    rm -f ~/Desktop/*.desktop 2>/dev/null
    msg_ok "Browsers and repos removed."
    ((step++))
 
    # STEP 7 — Autoremove & clean
    msg_step $step $TOTAL "Running autoremove & cleanup..."
    apt-get autoremove -y -qq >/dev/null 2>&1
    apt-get autoclean -y -qq >/dev/null 2>&1
    msg_ok "System cleaned."
 
    echo ""
    divider
    msg_ok "Full uninstall complete. System is clean."
    divider
    pause
}
 
# ==================================================
#  MAIN MENU LOOP
# ==================================================
while true; do
    draw_header
 
    # Installation
    echo -e "  ${GREEN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${GREEN}${BD}│  ${LIME}◈  INSTALLATION${NC}                                           ${GREEN}${BD}│${NC}"
    echo -e "  ${GREEN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Full Install     ${NC}${DGRAY}→  ${GREEN}XFCE + xRDP + VNC + noVNC + Browsers${NC}"
    echo -e "  ${GOLD}${BD}  7)${NC}  ${WHITE}Browsers Only    ${NC}${DGRAY}→  ${GREEN}Chrome · Chromium · Firefox · Brave${NC}"
    echo ""
 
    # Service Controls
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  SERVICE CONTROLS${NC}                                       ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Start Services   ${NC}${DGRAY}→  ${LIME}Launch xRDP · VNC · noVNC${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}Stop Services    ${NC}${DGRAY}→  ${ORANGE}Halt all remote desktop services${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Restart Services ${NC}${DGRAY}→  ${CYAN}Full service cycle restart${NC}"
    echo -e "  ${GOLD}${BD}  5)${NC}  ${WHITE}Service Status   ${NC}${DGRAY}→  ${TEAL}View ports and service health${NC}"
    echo ""
 
    # Management
    echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  MANAGEMENT${NC}                                             ${YELLOW}${BD}│${NC}"
    echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  6)${NC}  ${WHITE}VNC Password     ${NC}${DGRAY}→  ${YELLOW}Change VNC access password${NC}"
    echo -e "  ${GOLD}${BD}  8)${NC}  ${WHITE}User Manager     ${NC}${DGRAY}→  ${YELLOW}Add · Remove · Manage users${NC}"
    echo ""
 
    # Danger Zone
    echo -e "  ${RED}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${RED}${BD}│  ${LRED}◈  DANGER ZONE${NC}                                            ${RED}${BD}│${NC}"
    echo -e "  ${RED}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  9)${NC}  ${WHITE}Uninstall ALL    ${NC}${DGRAY}→  ${RED}Remove everything completely${NC}"
    echo ""
 
    # Footer
    echo -e "  ${PURPLE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${PURPLE}${BD}║${NC}  ${RED}${BD}  0)  ↩  Exit Panel${NC}                                        ${PURPLE}${BD}║${NC}"
    echo -e "  ${PURPLE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${PURPLE}${BD}  root@rdp:~# ${NC}"
    read -r opt
 
    case $opt in
        1) install_all ;;
        2) start_services ;;
        3) stop_services ;;
        4) restart_services ;;
        5) status_services ;;
        6) change_vnc_password ;;
        7) install_browsers ;;
        8) user_management ;;
        9) uninstall_all ;;
        0)
            clear
            echo ""
            echo -e "  ${GOLD}${BD}  👋  RDP Panel offline. Stay connected!${NC}"
            echo ""
            sleep 1
            exit 0 ;;
        *)
            msg_err "Invalid option. Choose 0–9."
            sleep 1 ;;
    esac
done
