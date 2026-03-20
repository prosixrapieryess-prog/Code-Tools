#!/bin/bash
 
# ==================================================
#  TERMINAL SHARING HUB v4.1
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
has()      { command -v "$1" >/dev/null 2>&1; }
msg_info() { echo -e "  ${CYAN}${BD}  ➜  ${NC}${WHITE}$1${NC}"; }
msg_ok()   { echo -e "  ${GREEN}${BD}  ✔  ${NC}${LGREEN}$1${NC}"; }
msg_warn() { echo -e "  ${YELLOW}${BD}  ⚠  ${NC}${YELLOW}$1${NC}"; }
msg_err()  { echo -e "  ${RED}${BD}  ✖  ${NC}${LRED}$1${NC}"; }
 
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
 
get_status() {
    if has "$1"; then
        echo -e "${LIME}${BD}● INSTALLED${NC} "
    else
        echo -e "${DGRAY}● MISSING   ${NC} "
    fi
}
 
# --- BRANDING ---
show_brand() {
    echo ""
    echo -e "${LBLUE}${BD}  ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     ${NC}"
    echo -e "${CYAN}${BD}  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     ${NC}"
    echo -e "${TEAL}${BD}     ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     ${NC}"
    echo -e "${BLUE}${BD}     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     ${NC}"
    echo -e "${PURPLE}${BD}     ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗${NC}"
    echo -e "${PINK}${BD}     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝${NC}"
    echo -e "  ${GOLD}${BD}                   SHARING HUB${NC}  ${DGRAY}v4.1  ·  Remote Collaboration Suite${NC}"
    echo ""
}
 
# --- HEADER ---
draw_header() {
    clear
    local host ip uptime_val
    host=$(hostname 2>/dev/null || echo "unknown")
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    uptime_val=$(uptime -p 2>/dev/null || echo "N/A")
    [[ -z "$ip" ]] && ip="N/A"
 
    show_brand
 
    echo -e "  ${CYAN}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${GOLD}${BD}      ⚡  REMOTE COLLABORATION SUITE  ⚡${NC}              ${CYAN}${BD}║${NC}"
    echo -e "  ${CYAN}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${DGRAY}HOST   :${NC}  ${WHITE}${BD}$host${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${DGRAY}IP     :${NC}  ${LCYAN}$ip${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${DGRAY}UPTIME :${NC}  ${GRAY}$uptime_val${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${DGRAY}VERSION:${NC}  ${TEAL}4.1 Stable${NC}"
    echo -e "  ${CYAN}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
 
# ==================================================
#  BASE DEPENDENCY INSTALLER
# ==================================================
base_install() {
    local missing=()
    for dep in curl wget; do
        has "$dep" || missing+=("$dep")
    done
 
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        msg_warn "Missing base dependencies: ${missing[*]}"
        msg_info "Installing: ${missing[*]}..."
        if command -v apt &>/dev/null; then
            apt-get update -qq >/dev/null 2>&1
            apt-get install -y -qq "${missing[@]}" curl wget screen tmux >/dev/null 2>&1
        elif command -v dnf &>/dev/null; then
            dnf install -y -q "${missing[@]}" curl wget screen tmux >/dev/null 2>&1
        elif command -v yum &>/dev/null; then
            yum install -y -q "${missing[@]}" curl wget screen tmux >/dev/null 2>&1
        elif command -v apk &>/dev/null; then
            apk add --quiet "${missing[@]}" curl wget screen tmux >/dev/null 2>&1
        else
            msg_err "Cannot auto-install dependencies — unknown package manager."
        fi
    fi
}
 
# ==================================================
#  TOOL INSTALLER / UNINSTALLER
# ==================================================
manage_tool() {
    local TOOL="$1"
    clear
    draw_header
    divider
    echo -e "  ${GOLD}${BD}  [ PACKAGE MANAGER ]  →  ${WHITE}$TOOL${NC}"
    divider
    echo ""
 
    if has "$TOOL"; then
        echo -e "  ${LIME}${BD}  ◉  '$TOOL' is currently INSTALLED.${NC}"
        echo ""
        echo -ne "  ${RED}${BD}  ➤  Uninstall '$TOOL'? (y/N): ${NC}"
        read -r confirm
        echo ""
 
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            msg_info "Removing $TOOL..."
 
            case $TOOL in
                sshx)
                    rm -rf "$HOME/.sshx" 2>/dev/null
                    rm -f "$(which sshx 2>/dev/null)" 2>/dev/null
                    rm -f /usr/local/bin/sshx /usr/bin/sshx 2>/dev/null
                    ;;
                tmate)
                    if command -v apt &>/dev/null;    then apt-get remove -y -qq tmate >/dev/null 2>&1
                    elif command -v dnf &>/dev/null;  then dnf remove -y tmate >/dev/null 2>&1
                    elif command -v yum &>/dev/null;  then yum remove -y tmate >/dev/null 2>&1
                    elif command -v pacman &>/dev/null; then pacman -Rns --noconfirm tmate >/dev/null 2>&1
                    else rm -f /usr/local/bin/tmate /usr/bin/tmate 2>/dev/null; fi
                    ;;
                upterm)
                    rm -f /usr/local/bin/upterm /usr/bin/upterm 2>/dev/null
                    ;;
                ttyd)
                    rm -f /usr/local/bin/ttyd /usr/bin/ttyd 2>/dev/null
                    ;;
                gotty)
                    rm -f /usr/local/bin/gotty /usr/bin/gotty 2>/dev/null
                    ;;
                cloudflared)
                    rm -f /usr/local/bin/cloudflared /usr/bin/cloudflared 2>/dev/null
                    if command -v apt &>/dev/null; then apt-get remove -y -qq cloudflared >/dev/null 2>&1; fi
                    ;;
            esac
 
            echo ""
            if ! has "$TOOL"; then
                divider
                msg_ok "'$TOOL' removed successfully."
                divider
            else
                divider
                msg_err "Could not fully remove '$TOOL'. Try: rm -f \$(which $TOOL)"
                divider
            fi
        else
            msg_info "Uninstall cancelled. No changes made."
        fi
 
    else
        echo -e "  ${DGRAY}  ◉  '$TOOL' is currently NOT INSTALLED.${NC}"
        echo ""
        echo -ne "  ${GREEN}${BD}  ➤  Install '$TOOL' now? (y/N): ${NC}"
        read -r confirm
        echo ""
 
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            msg_info "Installing $TOOL..."
            echo ""
            local install_ok=0
 
            case $TOOL in
                sshx)
                    if curl -sSf https://sshx.io/get | sh >/dev/null 2>&1; then install_ok=1; fi
                    ;;
                tmate)
                    if command -v apt &>/dev/null; then
                        apt-get update -qq >/dev/null 2>&1
                        apt-get install -y -qq tmate >/dev/null 2>&1 && install_ok=1
                    elif command -v dnf &>/dev/null; then
                        dnf install -y tmate >/dev/null 2>&1 && install_ok=1
                    elif command -v yum &>/dev/null; then
                        yum install -y tmate >/dev/null 2>&1 && install_ok=1
                    elif command -v pacman &>/dev/null; then
                        pacman -S --noconfirm tmate >/dev/null 2>&1 && install_ok=1
                    else
                        msg_err "No supported package manager found for tmate."
                    fi
                    ;;
                upterm)
                    if curl -fsSL https://upterm.sh/install | sh >/dev/null 2>&1; then install_ok=1; fi
                    ;;
                ttyd)
                    # BUG FIX: detect arch for correct binary
                    local arch
                    arch=$(uname -m)
                    local ttyd_bin="ttyd.x86_64"
                    [[ "$arch" == "aarch64" || "$arch" == "arm64" ]] && ttyd_bin="ttyd.aarch64"
                    [[ "$arch" == "armv7l" ]] && ttyd_bin="ttyd.arm"
                    local ttyd_url
                    ttyd_url=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest \
                        | grep "browser_download_url.*$ttyd_bin\"" \
                        | cut -d '"' -f 4 2>/dev/null)
                    if [[ -n "$ttyd_url" ]]; then
                        curl -fsSL "$ttyd_url" -o /tmp/ttyd 2>/dev/null && \
                        chmod +x /tmp/ttyd && \
                        mv /tmp/ttyd /usr/local/bin/ttyd && install_ok=1
                    else
                        msg_err "Could not fetch ttyd download URL."
                    fi
                    ;;
                gotty)
                    local arch
                    arch=$(uname -m)
                    local gotty_arch="amd64"
                    [[ "$arch" == "aarch64" || "$arch" == "arm64" ]] && gotty_arch="arm64"
                    local gotty_url
                    gotty_url=$(curl -s https://api.github.com/repos/sorenisanerd/gotty/releases/latest \
                        | grep "browser_download_url.*linux_${gotty_arch}.tar.gz\"" \
                        | cut -d '"' -f 4 2>/dev/null)
                    if [[ -n "$gotty_url" ]]; then
                        curl -fsSL "$gotty_url" -o /tmp/gotty.tar.gz 2>/dev/null && \
                        tar -xzf /tmp/gotty.tar.gz -C /tmp/ 2>/dev/null && \
                        chmod +x /tmp/gotty && \
                        mv /tmp/gotty /usr/local/bin/gotty && \
                        rm -f /tmp/gotty.tar.gz && install_ok=1
                    else
                        msg_err "Could not fetch gotty download URL."
                    fi
                    ;;
                cloudflared)
                    local arch
                    arch=$(uname -m)
                    local cf_bin="cloudflared-linux-amd64"
                    [[ "$arch" == "aarch64" || "$arch" == "arm64" ]] && cf_bin="cloudflared-linux-arm64"
                    [[ "$arch" == "armv7l" ]] && cf_bin="cloudflared-linux-arm"
                    if curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/$cf_bin" \
                        -o /usr/local/bin/cloudflared 2>/dev/null; then
                        chmod +x /usr/local/bin/cloudflared && install_ok=1
                    fi
                    ;;
            esac
 
            echo ""
            if [[ "$install_ok" -eq 1 ]] && has "$TOOL"; then
                divider
                msg_ok "'$TOOL' installed successfully!"
                divider
            else
                divider
                msg_err "Installation failed or binary not found in PATH."
                divider
            fi
        else
            msg_info "Installation cancelled. No changes made."
        fi
    fi
 
    pause
}
 
# ==================================================
#  PACKAGE MANAGER MENU
# ==================================================
package_manager_menu() {
    while true; do
        draw_header
 
        echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
        echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  PACKAGE MANAGER  ·  Install / Uninstall Tools${NC}         ${YELLOW}${BD}│${NC}"
        echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
        echo -e "  ${GRAY}  Select a tool to toggle its installation state.${NC}"
        echo ""
        echo -e "  ${GOLD}${BD}  1)${NC}  $(get_status sshx)        ${WHITE}sshx${NC}         ${DGRAY}→  ${GRAY}Web Multiplayer Shell${NC}"
        echo -e "  ${GOLD}${BD}  2)${NC}  $(get_status tmate)       ${WHITE}tmate${NC}        ${DGRAY}→  ${GRAY}Tmux Session Sharing${NC}"
        echo -e "  ${GOLD}${BD}  3)${NC}  $(get_status upterm)      ${WHITE}upterm${NC}       ${DGRAY}→  ${GRAY}Secure SSH Sharing${NC}"
        echo -e "  ${GOLD}${BD}  4)${NC}  $(get_status ttyd)        ${WHITE}ttyd${NC}         ${DGRAY}→  ${GRAY}Web Terminal (C++)${NC}"
        echo -e "  ${GOLD}${BD}  5)${NC}  $(get_status gotty)       ${WHITE}gotty${NC}        ${DGRAY}→  ${GRAY}Web Terminal (Go)${NC}"
        echo -e "  ${GOLD}${BD}  6)${NC}  $(get_status cloudflared) ${WHITE}cloudflared${NC}  ${DGRAY}→  ${GRAY}Zero Trust Tunnel${NC}"
        echo ""
        echo -e "  ${CYAN}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${CYAN}${BD}║${NC}  ${RED}${BD}  0)  ↩  Back to Main Menu${NC}                                 ${CYAN}${BD}║${NC}"
        echo -e "  ${CYAN}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -ne "  ${PURPLE}${BD}  root@manager:~# ${NC}"
        read -r pkg_opt
 
        case $pkg_opt in
            1) manage_tool "sshx" ;;
            2) manage_tool "tmate" ;;
            3) manage_tool "upterm" ;;
            4) manage_tool "ttyd" ;;
            5) manage_tool "gotty" ;;
            6) manage_tool "cloudflared" ;;
            0) return ;;
            *) msg_err "Invalid Option"; sleep 1 ;;
        esac
    done
}
 
# ==================================================
#  RUN FUNCTIONS
# ==================================================
 
sshx_run() {
    clear; draw_header
    divider
    echo -e "  ${LIME}${BD}  [ SSHX — Web Multiplayer Shell ]${NC}"
    divider
    echo ""
    if ! has sshx; then
        msg_warn "sshx not installed."
        manage_tool "sshx"
        has sshx || return
    fi
    msg_info "Launching sshx — share the URL with collaborators..."
    echo ""
    sshx
    pause
}
 
tmate_run() {
    clear; draw_header
    divider
    echo -e "  ${CYAN}${BD}  [ TMATE — Tmux Session Sharing ]${NC}"
    divider
    echo ""
    if ! has tmate; then
        msg_warn "tmate not installed."
        manage_tool "tmate"
        has tmate || return
    fi
    msg_info "Starting tmate session..."
    echo ""
    tmate
    pause
}
 
upterm_run() {
    clear; draw_header
    divider
    echo -e "  ${BLUE}${BD}  [ UPTERM — Secure SSH Sharing ]${NC}"
    divider
    echo ""
    if ! has upterm; then
        msg_warn "upterm not installed."
        manage_tool "upterm"
        has upterm || return
    fi
    msg_info "Launching upterm host session..."
    echo ""
    upterm host
    pause
}
 
ttyd_run() {
    clear; draw_header
    divider
    echo -e "  ${TEAL}${BD}  [ TTYD — Browser-Based Web Terminal ]${NC}"
    divider
    echo ""
    if ! has ttyd; then
        msg_warn "ttyd not installed."
        manage_tool "ttyd"
        has ttyd || return
    fi
 
    echo -ne "  ${CYAN}${BD}  ➤  Port (default 8080): ${NC}"
    read -r P
    P=${P:-8080}
 
    # Validate port
    if ! [[ "$P" =~ ^[0-9]+$ ]] || (( P < 1 || P > 65535 )); then
        msg_err "Invalid port '$P'. Using default 8080."
        P=8080
    fi
 
    local ip
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    echo ""
    divider
    msg_ok "Web Terminal Active → ${CYAN}http://$ip:$P${NC}"
    msg_warn "Press CTRL+C to stop."
    divider
    echo ""
    ttyd -p "$P" bash
    pause
}
 
gotty_run() {
    clear; draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ GOTTY — Go-Powered Web Terminal ]${NC}"
    divider
    echo ""
    if ! has gotty; then
        msg_warn "gotty not installed."
        manage_tool "gotty"
        has gotty || return
    fi
    msg_info "Launching gotty with writable bash..."
    echo ""
    gotty -w bash
    pause
}
 
cloudflared_run() {
    clear; draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ CLOUDFLARE — Zero Trust Tunnel ]${NC}"
    divider
    echo ""
    if ! has cloudflared; then
        msg_warn "cloudflared not installed."
        manage_tool "cloudflared"
        has cloudflared || return
    fi
 
    echo -ne "  ${CYAN}${BD}  ➤  Local port to tunnel (default 22): ${NC}"
    read -r CF_PORT
    CF_PORT=${CF_PORT:-22}
 
    if ! [[ "$CF_PORT" =~ ^[0-9]+$ ]] || (( CF_PORT < 1 || CF_PORT > 65535 )); then
        msg_err "Invalid port. Using default 22."
        CF_PORT=22
    fi
 
    echo ""
    divider
    msg_ok "Starting Cloudflare Quick Tunnel on port $CF_PORT..."
    msg_warn "Press CTRL+C to stop."
    divider
    echo ""
    cloudflared tunnel --url "tcp://localhost:$CF_PORT"
    pause
}
 
serveo_run() {
    clear; draw_header
    divider
    echo -e "  ${PURPLE}${BD}  [ SERVEO — Clientless SSH Tunnel ]${NC}"
    divider
    echo ""
 
    if ! has ssh; then
        msg_err "ssh client not found. Install openssh-client first."
        pause
        return
    fi
 
    echo -ne "  ${CYAN}${BD}  ➤  Custom subdomain (Enter for random): ${NC}"
    read -r SUB
    echo ""
 
    msg_info "Starting Serveo tunnel..."
    msg_warn "Press CTRL+C to stop."
    echo ""
 
    if [[ -z "$SUB" ]]; then
        ssh -o StrictHostKeyChecking=no -R 80:localhost:22 serveo.net
    else
        ssh -o StrictHostKeyChecking=no -R "${SUB}:80:localhost:22" serveo.net
    fi
    pause
}
 
localhost_run() {
    clear; draw_header
    divider
    echo -e "  ${PINK}${BD}  [ LOCALHOST.RUN — Instant Tunnel ]${NC}"
    divider
    echo ""
 
    if ! has ssh; then
        msg_err "ssh client not found. Install openssh-client first."
        pause
        return
    fi
 
    msg_info "Connecting to localhost.run..."
    msg_warn "Press CTRL+C to stop."
    echo ""
    ssh -o StrictHostKeyChecking=no -R 80:localhost:22 nokey@localhost.run
    pause
}
 
# ==================================================
#  INIT
# ==================================================
base_install
 
# ==================================================
#  MAIN MENU LOOP
# ==================================================
while true; do
    draw_header
 
    # Collaborative Shells
    echo -e "  ${GREEN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${GREEN}${BD}│  ${LIME}◈  COLLABORATIVE SHELLS${NC}                                    ${GREEN}${BD}│${NC}"
    echo -e "  ${GREEN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  1)${NC}  $(get_status sshx)   ${WHITE}sshx     ${NC}${DGRAY}→  ${GREEN}Web-Based Multiplayer Shell${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  $(get_status tmate)  ${WHITE}tmate    ${NC}${DGRAY}→  ${GREEN}Tmux Session Sharing${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  $(get_status upterm) ${WHITE}upterm   ${NC}${DGRAY}→  ${GREEN}Secure SSH Pair Session${NC}"
    echo ""
 
    # Web Terminals
    echo -e "  ${BLUE}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${BLUE}${BD}│  ${TEAL}◈  WEB TERMINALS${NC}                                           ${BLUE}${BD}│${NC}"
    echo -e "  ${BLUE}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  $(get_status ttyd)   ${WHITE}ttyd     ${NC}${DGRAY}→  ${BLUE}C++ Web Terminal Backend${NC}"
    echo -e "  ${GOLD}${BD}  5)${NC}  $(get_status gotty)  ${WHITE}gotty    ${NC}${DGRAY}→  ${BLUE}Go Web Terminal Backend${NC}"
    echo ""
 
    # Tunnels
    echo -e "  ${PURPLE}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${PURPLE}${BD}│  ${PINK}◈  TUNNELS & UTILITIES${NC}                                    ${PURPLE}${BD}│${NC}"
    echo -e "  ${PURPLE}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  6)${NC}  $(get_status ssh)          ${WHITE}Serveo      ${NC}${DGRAY}→  ${PURPLE}Clientless SSH Tunnel${NC}"
    echo -e "  ${GOLD}${BD}  7)${NC}  $(get_status ssh)          ${WHITE}Localhost   ${NC}${DGRAY}→  ${PURPLE}Instant Reverse Tunnel${NC}"
    echo -e "  ${GOLD}${BD}  8)${NC}  $(get_status cloudflared)  ${WHITE}Cloudflare  ${NC}${DGRAY}→  ${PURPLE}Zero Trust Tunnel${NC}"
    echo ""
 
    # Footer
    echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  MANAGEMENT${NC}                                             ${YELLOW}${BD}│${NC}"
    echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  9)${NC}  ${WHITE}Package Manager  ${NC}${DGRAY}→  ${YELLOW}Install / Uninstall Tools${NC}"
    echo ""
    echo -e "  ${CYAN}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${RED}${BD}  0)  ↩  Exit Hub${NC}                                          ${CYAN}${BD}║${NC}"
    echo -e "  ${CYAN}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${CYAN}${BD}  root@hub:~# ${NC}"
    read -r option
 
    case $option in
        1) sshx_run ;;
        2) tmate_run ;;
        3) upterm_run ;;
        4) ttyd_run ;;
        5) gotty_run ;;
        6) serveo_run ;;
        7) localhost_run ;;
        8) cloudflared_run ;;
        9) package_manager_menu ;;
        0)
            clear
            echo ""
            echo -e "  ${GOLD}${BD}  👋  Terminal Hub offline. Stay connected!${NC}"
            echo ""
            sleep 1
            exit 0 ;;
        *)
            msg_err "Invalid option. Choose 0–9."
            sleep 1 ;;
    esac
done
