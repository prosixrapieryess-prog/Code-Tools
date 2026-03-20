#!/bin/bash
 
# ==================================================
#  TAILSCALE MESH COMMANDER v3.4 — FULLY AUTOMATIC
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
msg_step() { echo -e "\n  ${GOLD}${BD}  [$1]${NC}  ${WHITE}$2${NC}"; }
 
divider() { echo -e "  ${DGRAY}  ─────────────────────────────────────────────────────${NC}"; }
 
pause() {
    echo ""
    divider
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
get_hostname() {
    command -v hostname &>/dev/null && hostname && return
    [ -f /etc/hostname ] && head -n 1 /etc/hostname && return
    echo "Unknown-Host"
}
 
# ==================================================
#  ENVIRONMENT DETECTION
# ==================================================
is_firebase_studio() {
    [[ -n "$IDX_CHANNEL" ]]          && return 0
    [[ -n "$FIREBASE_STUDIO" ]]      && return 0
    [[ -d "/home/user/.idx" ]]       && return 0
    [[ -f "/etc/idx-release" ]]      && return 0
    [[ -d "/home/user" ]] && ls /home/user/.idx 2>/dev/null && return 0
    echo "$HOME" | grep -qE "idx-|project-idx" && return 0
    env | grep -qi "IDX\|FIREBASE\|GOOGLE_CLOUD_WORKSTATIONS" && return 0
    return 1
}
 
is_nix_available() {
    command -v nix-env &>/dev/null || command -v nix &>/dev/null
}
 
is_docker() {
    [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null
}
 
find_dev_nix() {
    local locations=(
        "$HOME/.idx/dev.nix"
        "/home/user/.idx/dev.nix"
        "$(pwd)/dev.nix"
        "/root/dev.nix"
        "$HOME/dev.nix"
        "/workspace/dev.nix"
    )
    for loc in "${locations[@]}"; do
        [[ -f "$loc" ]] && echo "$loc" && return 0
    done
    # Search up to 2 levels
    find / -maxdepth 5 -name "dev.nix" 2>/dev/null | head -n1
}
 
_get_os_codename() {
    local c
    c=$(. /etc/os-release 2>/dev/null && echo "${VERSION_CODENAME:-}")
    [[ -z "$c" ]] && c=$(lsb_release -cs 2>/dev/null)
    [[ -z "$c" ]] && c="bookworm"
    echo "$c"
}
 
_get_os_id() {
    local id
    id=$(. /etc/os-release 2>/dev/null && echo "${ID:-}")
    [[ -z "$id" ]] && id="debian"
    echo "$id"
}
 
# ==================================================
#  BRANDING
# ==================================================
show_brand() {
    echo ""
    echo -e "${LBLUE}${BD}  ████████╗ █████╗ ██╗██╗      ███████╗ ██████╗ █████╗ ██╗     ███████╗${NC}"
    echo -e "${CYAN}${BD}  ╚══██╔══╝██╔══██╗██║██║      ██╔════╝██╔════╝██╔══██╗██║     ██╔════╝${NC}"
    echo -e "${TEAL}${BD}     ██║   ███████║██║██║      ███████╗██║     ███████║██║     █████╗  ${NC}"
    echo -e "${BLUE}${BD}     ██║   ██╔══██║██║██║      ╚════██║██║     ██╔══██║██║     ██╔══╝  ${NC}"
    echo -e "${PURPLE}${BD}     ██║   ██║  ██║██║███████╗███████║╚██████╗██║  ██║███████╗███████╗${NC}"
    echo -e "${PINK}${BD}     ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝${NC}"
    echo -e "  ${GOLD}${BD}                    MESH COMMANDER${NC}  ${DGRAY}v3.4  ⬡ Fully Automatic Install${NC}"
    echo ""
}
 
# ==================================================
#  HEADER
# ==================================================
draw_header() {
    clear
    local host_name os_info env_badge
    local ts_status ts_ip exit_node health_check ts_version peer_count
 
    host_name=$(get_hostname)
    os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    [[ -z "$os_info" ]] && os_info="Unknown OS"
 
    ts_status="${RED}${BD}◉ NOT INSTALLED${NC}"
    ts_ip="${DGRAY}  ---${NC}"
    exit_node="${DGRAY}  INACTIVE${NC}"
    health_check="${RED}${BD}◉ DISCONNECTED${NC}"
    ts_version="${DGRAY}  ---${NC}"
    peer_count="${DGRAY}  0 peers${NC}"
 
    if command -v tailscale &>/dev/null; then
        ts_version="${TEAL}$(tailscale version 2>/dev/null | head -n1)${NC}"
        if systemctl is-active --quiet tailscaled 2>/dev/null || pgrep tailscaled &>/dev/null; then
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
            tailscale status 2>/dev/null | grep -q "exit node" && exit_node="${PURPLE}${BD}  ACTIVE${NC}"
            local pc
            pc=$(tailscale status 2>/dev/null | grep -c "^\s*[0-9]" 2>/dev/null || echo 0)
            peer_count="${ORANGE}${BD}  $pc peers${NC}"
        else
            ts_status="${ORANGE}${BD}◉ INSTALLED · NOT RUNNING${NC}"
        fi
    fi
 
    env_badge="${DGRAY}Standard Linux${NC}"
    is_firebase_studio && env_badge="${ORANGE}${BD}◉ Firebase Studio / IDX${NC}"
    is_nix_available   && ! is_firebase_studio && env_badge="${TEAL}${BD}◉ Nix Environment${NC}"
    is_docker          && env_badge="${BLUE}${BD}◉ Docker Container${NC}"
 
    show_brand
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${GOLD}${BD}        ⚡  SECURE NETWORK OVERLAY SYSTEM  ⚡${NC}          ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}DEVICE   :${NC}  ${WHITE}${BD}$host_name${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}SYSTEM   :${NC}  ${GRAY}$os_info${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}ENV      :${NC}  $env_badge"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}VERSION  :${NC}  $ts_version"
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
#  AUTO-PATCH dev.nix — FULLY AUTOMATIC
# ==================================================
_auto_patch_devnix() {
    local devnix_path
    devnix_path=$(find_dev_nix)
 
    # Not found — create it from scratch
    if [[ -z "$devnix_path" ]]; then
        devnix_path="$HOME/.idx/dev.nix"
        mkdir -p "$(dirname "$devnix_path")"
        cat > "$devnix_path" <<'DEVNIX'
{ pkgs, ... }: {
  packages = [
    pkgs.tailscale
  ];
}
DEVNIX
        msg_ok "Created new dev.nix at: ${CYAN}$devnix_path${NC}"
        echo "$devnix_path"
        return 0
    fi
 
    # Already has tailscale
    if grep -q "tailscale" "$devnix_path" 2>/dev/null; then
        msg_warn "tailscale already in $devnix_path"
        echo "$devnix_path"
        return 2
    fi
 
    # Backup
    cp "$devnix_path" "${devnix_path}.bak" 2>/dev/null
    msg_ok "Backup saved: ${devnix_path}.bak"
 
    # Pattern 1: packages = with pkgs; [
    if grep -qE "packages\s*=\s*with pkgs;\s*\[" "$devnix_path"; then
        sed -i -E 's/(packages\s*=\s*with pkgs;\s*\[)/\1\n    tailscale/' "$devnix_path"
        msg_ok "Patched (with pkgs pattern)"
        echo "$devnix_path"; return 0
    fi
 
    # Pattern 2: packages = [
    if grep -qE "packages\s*=\s*\[" "$devnix_path"; then
        sed -i -E 's/(packages\s*=\s*\[)/\1\n    pkgs.tailscale/' "$devnix_path"
        msg_ok "Patched (packages = [ pattern)"
        echo "$devnix_path"; return 0
    fi
 
    # Pattern 3: No packages list at all — inject before closing }
    if grep -q "^}" "$devnix_path"; then
        # Insert packages block before last closing brace
        sed -i '${/^}/i\  packages = [ pkgs.tailscale ];
}' "$devnix_path" 2>/dev/null || \
        echo -e '\n  packages = [ pkgs.tailscale ];' >> "$devnix_path"
        msg_ok "Patched (injected packages block)"
        echo "$devnix_path"; return 0
    fi
 
    # Fallback — just append
    echo -e '\n  packages = [ pkgs.tailscale ];\n' >> "$devnix_path"
    msg_ok "Patched (appended)"
    echo "$devnix_path"; return 0
}
 
# ==================================================
#  START DAEMON — ALL METHODS
# ==================================================
_start_daemon() {
    msg_step "DAEMON" "Starting tailscaled..."
    echo ""
 
    # Method 1: systemctl
    if command -v systemctl &>/dev/null; then
        systemctl enable tailscaled >/dev/null 2>&1
        systemctl start tailscaled >/dev/null 2>&1
        sleep 2
        if systemctl is-active --quiet tailscaled 2>/dev/null; then
            msg_ok "Daemon started via systemctl."
            return 0
        fi
    fi
 
    # Method 2: service
    if command -v service &>/dev/null; then
        service tailscaled start >/dev/null 2>&1
        sleep 2
        pgrep tailscaled &>/dev/null && msg_ok "Daemon started via service." && return 0
    fi
 
    # Method 3: rc-service (Alpine)
    if command -v rc-service &>/dev/null; then
        rc-service tailscale start >/dev/null 2>&1
        sleep 2
        pgrep tailscaled &>/dev/null && msg_ok "Daemon started via rc-service." && return 0
    fi
 
    # Method 4: manual background process
    msg_info "Trying manual daemon start..."
    mkdir -p /var/run/tailscale /var/lib/tailscale /run/tailscale 2>/dev/null
 
    # Kill any zombie process first
    pkill -f tailscaled 2>/dev/null; sleep 1
 
    tailscaled \
        --state=/var/lib/tailscale/tailscaled.state \
        --socket=/run/tailscale/tailscaled.sock \
        --tun=userspace-networking \
        >/tmp/tailscaled.log 2>&1 &
 
    local daemon_pid=$!
    sleep 4
 
    if pgrep -x tailscaled &>/dev/null; then
        msg_ok "Daemon running in userspace mode (PID: $daemon_pid)."
        return 0
    fi
 
    # Method 5: try without userspace flag (some systems)
    pkill -f tailscaled 2>/dev/null; sleep 1
    tailscaled \
        --state=/var/lib/tailscale/tailscaled.state \
        --socket=/run/tailscale/tailscaled.sock \
        >/tmp/tailscaled.log 2>&1 &
    sleep 4
 
    if pgrep -x tailscaled &>/dev/null; then
        msg_ok "Daemon started (standard mode)."
        return 0
    fi
 
    msg_err "Could not start daemon. Log: /tmp/tailscaled.log"
    echo ""
    echo -e "  ${YELLOW}  Last 5 log lines:${NC}"
    tail -5 /tmp/tailscaled.log 2>/dev/null | sed 's/^/  /'
    return 1
}
 
# ==================================================
#  AUTHENTICATE — WITH SOCKET FALLBACK
# ==================================================
_do_auth() {
    msg_step "AUTH" "Running tailscale up..."
    echo ""
    echo -e "  ${YELLOW}${BD}  ┌────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  A URL will appear below — open it in browser    │${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  Sign in with your Tailscale account             │${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  The device will auto-connect after sign-in      │${NC}"
    echo -e "  ${YELLOW}${BD}  └────────────────────────────────────────────────────┘${NC}"
    echo ""
 
    # Try with explicit socket path (needed in non-systemd/Nix envs)
    local socket_path="/run/tailscale/tailscaled.sock"
    [ -S "$socket_path" ] || socket_path="/var/run/tailscale/tailscaled.sock"
    [ -S "$socket_path" ] || socket_path=""
 
    if [[ -n "$socket_path" ]]; then
        tailscale --socket="$socket_path" up 2>&1
    else
        tailscale up 2>&1
    fi
 
    echo ""
    local ts_ip
    ts_ip=$(tailscale ip -4 2>/dev/null)
    if [[ -n "$ts_ip" ]]; then
        divider
        msg_ok "${GREEN}${BD}CONNECTED!${NC} Tailscale IP: ${CYAN}${BD}$ts_ip${NC}"
        msg_ok "This device has joined the Mesh Network."
        divider
        return 0
    else
        msg_warn "Auth pending — complete via the URL above, then re-run option 1."
        return 1
    fi
}
 
# ==================================================
#  INSTALL METHODS
# ==================================================
_check_net() {
    for h in "1.1.1.1" "8.8.8.8" "google.com" "pkgs.tailscale.com" "tailscale.com"; do
        curl -fsSL --max-time 5 --head "https://$h" >/dev/null 2>&1 && echo "$h" && return 0
        ping -c 1 -W 2 "$h" >/dev/null 2>&1 && echo "$h" && return 0
    done
    return 1
}
 
_try_nix_install() {
    command -v nix-env &>/dev/null || command -v nix &>/dev/null || return 1
    echo -ne "  ${GOLD}${BD}  [F]${NC}  ${WHITE}Nix: nix-env install...                 ${NC}"
    nix-env -iA nixpkgs.tailscale >/dev/null 2>&1 && \
        command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    # nix profile
    nix profile install nixpkgs#tailscale >/dev/null 2>&1 && \
        command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE (profile)${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"; return 1
}
 
_try_official_installer() {
    echo -ne "  ${GOLD}${BD}  [A]${NC}  ${WHITE}Official install.sh (tailscale.com)...  ${NC}"
    curl -fsSL --max-time 30 https://tailscale.com/install.sh -o /tmp/ts_install.sh 2>/dev/null
    [[ $? -ne 0 || ! -s /tmp/ts_install.sh ]] && { echo -e "${RED}${BD}✖ UNREACHABLE${NC}"; rm -f /tmp/ts_install.sh; return 1; }
    bash /tmp/ts_install.sh >/dev/null 2>&1; rm -f /tmp/ts_install.sh
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"; return 1
}
 
_try_apt_repo() {
    echo -ne "  ${GOLD}${BD}  [B]${NC}  ${WHITE}APT repo (pkgs.tailscale.com)...        ${NC}"
    command -v apt-get &>/dev/null || { echo -e "${DGRAY}✖ NOT APT${NC}"; return 1; }
    local codename os_id
    codename=$(_get_os_codename); os_id=$(_get_os_id)
    curl -fsSL --max-time 8 --head "https://pkgs.tailscale.com/stable/${os_id}/${codename}" >/dev/null 2>&1 || \
        { echo -e "${RED}${BD}✖ REPO UNREACHABLE${NC}"; return 1; }
    mkdir -p /usr/share/keyrings
    curl -fsSL "https://pkgs.tailscale.com/stable/${os_id}/${codename}.noarmor.gpg" \
        -o /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null || \
        { echo -e "${RED}${BD}✖ GPG FAILED${NC}"; return 1; }
    echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] \
https://pkgs.tailscale.com/stable/${os_id} ${codename} main" \
        > /etc/apt/sources.list.d/tailscale.list
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq tailscale >/dev/null 2>&1
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"
    rm -f /etc/apt/sources.list.d/tailscale.list /usr/share/keyrings/tailscale-archive-keyring.gpg
    return 1
}
 
_try_deb_direct() {
    echo -ne "  ${GOLD}${BD}  [C]${NC}  ${WHITE}Direct .deb binary download...          ${NC}"
    command -v apt-get &>/dev/null || { echo -e "${DGRAY}✖ NOT APT${NC}"; return 1; }
    local arch codename os_id
    arch=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
    codename=$(_get_os_codename); os_id=$(_get_os_id)
    curl -fsSL --max-time 60 \
        "https://pkgs.tailscale.com/stable/${os_id}/${codename}/pool/tailscale_latest_${arch}.deb" \
        -o /tmp/tailscale_latest.deb 2>/dev/null
    [[ $? -ne 0 || ! -s /tmp/tailscale_latest.deb ]] && { echo -e "${RED}${BD}✖ FAILED${NC}"; rm -f /tmp/tailscale_latest.deb; return 1; }
    dpkg -i /tmp/tailscale_latest.deb >/dev/null 2>&1
    apt-get install -f -y -qq >/dev/null 2>&1
    rm -f /tmp/tailscale_latest.deb
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"; return 1
}
 
_try_dnf_yum() {
    echo -ne "  ${GOLD}${BD}  [D]${NC}  ${WHITE}DNF/YUM package manager...              ${NC}"
    if command -v dnf &>/dev/null; then
        dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo >/dev/null 2>&1
        dnf install -y tailscale >/dev/null 2>&1
    elif command -v yum &>/dev/null; then
        yum install -y yum-utils >/dev/null 2>&1
        yum-config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo >/dev/null 2>&1
        yum install -y tailscale >/dev/null 2>&1
    else
        echo -e "${DGRAY}✖ NOT DNF/YUM${NC}"; return 1
    fi
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"; return 1
}
 
_try_apk() {
    echo -ne "  ${GOLD}${BD}  [E]${NC}  ${WHITE}APK (Alpine) install...                 ${NC}"
    command -v apk &>/dev/null || { echo -e "${DGRAY}✖ NOT ALPINE${NC}"; return 1; }
    apk add tailscale >/dev/null 2>&1
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"; return 1
}
 
# ==================================================
#  FIREBASE STUDIO AUTO-SETUP
# ==================================================
_firebase_auto_setup() {
    clear; draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ FIREBASE STUDIO — AUTO SETUP ]${NC}"
    divider
    echo ""
    echo -e "  ${ORANGE}${BD}  ◉ Firebase Studio / Project IDX detected!${NC}"
    echo -e "  ${GRAY}  Package downloads are blocked in this environment.${NC}"
    echo -e "  ${GRAY}  Tailscale must be installed via dev.nix + workspace rebuild.${NC}"
    echo ""
    divider
 
    msg_step "1/3" "Auto-patching your dev.nix file..."
    echo ""
 
    local devnix_path patch_result
    devnix_path=$(_auto_patch_devnix)
    patch_result=$?
 
    echo ""
 
    if [[ $patch_result -eq 2 ]]; then
        msg_warn "Tailscale already in dev.nix — skip to Step 2."
    elif [[ -z "$devnix_path" ]]; then
        msg_err "Could not find or create dev.nix."
        pause; return 1
    fi
 
    msg_ok "dev.nix location: ${CYAN}$devnix_path${NC}"
    echo ""
 
    # Show the current dev.nix content
    divider
    echo -e "  ${PINK}${BD}  📄  Current dev.nix content:${NC}"
    divider
    cat "$devnix_path" 2>/dev/null | sed 's/^/  /' | while IFS= read -r line; do
        if echo "$line" | grep -q "tailscale"; then
            echo -e "${LIME}${BD}$line${NC}"
        else
            echo -e "${GRAY}$line${NC}"
        fi
    done
    divider
    echo ""
 
    msg_step "2/3" "Rebuild your workspace..."
    echo ""
    echo -e "  ${YELLOW}${BD}  You MUST rebuild the workspace for dev.nix to take effect.${NC}"
    echo ""
    echo -e "  ${GOLD}${BD}  HOW TO REBUILD:${NC}"
    echo -e "  ${DGRAY}  ┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${WHITE}Method 1:${NC}  Press ${CYAN}Ctrl+Shift+P${NC}                           ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}             Type: ${LIME}Rebuild Workspace${NC}                     ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}             Press Enter                                   ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}                                                            ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${WHITE}Method 2:${NC}  Click the gear ⚙ icon (bottom-left)         ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}             Select: ${LIME}Rebuild Workspace${NC}                     ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  └────────────────────────────────────────────────────────┘${NC}"
    echo ""
 
    msg_step "3/3" "After rebuild — run these commands:"
    echo ""
    echo -e "  ${DGRAY}  ┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${WHITE}# Start the Tailscale daemon:${NC}                          ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${LIME}  sudo tailscaled --tun=userspace-networking &${NC}          ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}                                                            ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${WHITE}# Authenticate:${NC}                                        ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${LIME}  sudo tailscale up${NC}                                     ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}                                                            ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  │${NC}  ${WHITE}# Or run this script again → Option 1${NC}                  ${DGRAY}│${NC}"
    echo -e "  ${DGRAY}  └────────────────────────────────────────────────────────┘${NC}"
    echo ""
    divider
 
    # Offer to try rebuild trigger via IDX CLI if available
    if command -v idx &>/dev/null; then
        echo ""
        msg_info "IDX CLI detected — attempting auto-rebuild..."
        idx workspace rebuild 2>/dev/null && msg_ok "Rebuild triggered!" || \
            msg_warn "Auto-rebuild failed — do it manually via Ctrl+Shift+P."
    fi
 
    echo ""
    msg_warn "After rebuild completes, run this script again and choose Option 1."
    divider
    pause
}
 
# ==================================================
#  MAIN INSTALL — FULLY AUTOMATIC
# ==================================================
install_tailscale() {
    clear; draw_header
    divider
    echo -e "  ${LIME}${BD}  [ AUTO INSTALL & CONNECT ]${NC}"
    divider
    echo ""
 
    # ── Already installed ──────────────────────────────
    if command -v tailscale &>/dev/null; then
        msg_ok "Tailscale already installed: ${TEAL}$(tailscale version 2>/dev/null | head -n1)${NC}"
        echo ""
 
        # Start daemon if not running
        if ! pgrep tailscaled &>/dev/null; then
            _start_daemon
            sleep 2
        else
            msg_ok "Daemon already running (PID: $(pgrep tailscaled))."
        fi
 
        echo ""
 
        # Check if already connected
        local current_ip
        current_ip=$(tailscale ip -4 2>/dev/null)
        if [[ -n "$current_ip" ]]; then
            divider
            msg_ok "Already connected! IP: ${CYAN}${BD}$current_ip${NC}"
            divider
            pause; return 0
        fi
 
        # Not connected — authenticate
        _do_auth
        pause; return
    fi
 
    # ── Network test ───────────────────────────────────
    msg_step "CHECK" "Testing internet connectivity..."
    echo ""
 
    local reachable
    reachable=$(_check_net)
 
    if [[ -n "$reachable" ]]; then
        msg_ok "Internet reachable via: ${TEAL}$reachable${NC}"
        echo ""
    else
        msg_err "No internet access detected."
        echo ""
 
        # Firebase Studio with no internet → auto-patch dev.nix
        if is_firebase_studio || is_nix_available; then
            echo -e "  ${ORANGE}${BD}  ⚠  Firebase Studio environment — switching to dev.nix method...${NC}"
            sleep 1
            _firebase_auto_setup
            return
        fi
 
        divider
        msg_err "Cannot install without internet. Check network connectivity."
        divider
        pause; return
    fi
 
    # ── Firebase Studio detected (has internet somehow) ─
    if is_firebase_studio; then
        echo -e "  ${ORANGE}${BD}  ⚠  Firebase Studio detected — trying Nix method first...${NC}"
        echo ""
    fi
 
    # ── Try all install methods ────────────────────────
    msg_step "INSTALL" "Trying all installation methods automatically..."
    echo ""
 
    local installed=0
 
    # Nix first (Firebase Studio / NixOS)
    _try_nix_install     && installed=1
 
    # Standard Linux methods
    [[ $installed -eq 0 ]] && _try_official_installer && installed=1
    [[ $installed -eq 0 ]] && _try_apt_repo           && installed=1
    [[ $installed -eq 0 ]] && _try_deb_direct         && installed=1
    [[ $installed -eq 0 ]] && _try_dnf_yum            && installed=1
    [[ $installed -eq 0 ]] && _try_apk                && installed=1
 
    echo ""
 
    # ── All methods failed ─────────────────────────────
    if [[ $installed -eq 0 ]] || ! command -v tailscale &>/dev/null; then
        msg_err "All standard methods failed."
        echo ""
 
        # Firebase / Nix → auto-patch dev.nix automatically
        if is_firebase_studio || is_nix_available; then
            echo -e "  ${ORANGE}${BD}  ⚡  Switching to dev.nix auto-patch method...${NC}"
            sleep 1
            echo ""
            _firebase_auto_setup
            return
        fi
 
        divider
        msg_err "Installation failed on all methods."
        echo ""
        echo -e "  ${YELLOW}${BD}  Manual install:${NC}"
        echo -e "  ${WHITE}  curl -fsSL https://tailscale.com/install.sh | sh${NC}"
        divider
        pause; return
    fi
 
    # ── Install succeeded ──────────────────────────────
    msg_ok "Tailscale installed: ${TEAL}$(tailscale version 2>/dev/null | head -n1)${NC}"
    echo ""
 
    # Start daemon
    _start_daemon
    sleep 2
    echo ""
 
    # Verify daemon running
    if ! pgrep tailscaled &>/dev/null; then
        msg_err "Daemon failed to start. Cannot authenticate."
        echo -e "  ${YELLOW}  Try manually: ${WHITE}sudo tailscaled --tun=userspace-networking &${NC}"
        pause; return
    fi
 
    # Authenticate
    _do_auth
    pause
}
 
# ==================================================
#  UNINSTALL
# ==================================================
uninstall_tailscale() {
    clear; draw_header
    divider
    echo -e "  ${RED}${BD}  [ UNINSTALL TAILSCALE ]${NC}"
    divider; echo ""
 
    if ! command -v tailscale &>/dev/null; then
        msg_err "Tailscale is not installed."; pause; return
    fi
 
    msg_warn "This will sever all mesh connections."
    echo -ne "  ${PURPLE}${BD}  ➤  Confirm removal? (y/N): ${NC}"
    read -r confirm; echo ""
 
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        tailscale down 2>/dev/null
        pkill tailscaled 2>/dev/null; sleep 1
        systemctl stop tailscaled 2>/dev/null
        systemctl disable tailscaled 2>/dev/null
        command -v apt-get &>/dev/null && apt-get purge -y -qq tailscale >/dev/null 2>&1
        command -v dnf     &>/dev/null && dnf remove -y tailscale >/dev/null 2>&1
        command -v yum     &>/dev/null && yum remove -y tailscale >/dev/null 2>&1
        command -v apk     &>/dev/null && apk del tailscale >/dev/null 2>&1
        is_nix_available   && nix-env -e tailscale >/dev/null 2>&1 || true
        rm -rf /var/lib/tailscale /etc/tailscale \
               /etc/apt/sources.list.d/tailscale.list \
               /usr/share/keyrings/tailscale-archive-keyring.gpg \
               /run/tailscale /tmp/tailscaled.log 2>/dev/null
        echo ""
        divider; msg_ok "Tailscale completely removed."; divider
    else
        msg_info "Cancelled. No changes made."
    fi
    pause
}
 
# ==================================================
#  NETWORK MAP
# ==================================================
network_map() {
    clear; draw_header
    divider; echo -e "  ${TEAL}${BD}  [ MESH NETWORK MAP ]${NC}"; divider; echo ""
    if ! command -v tailscale &>/dev/null; then msg_err "Not installed."; pause; return; fi
    if ! tailscale status &>/dev/null; then
        msg_err "Not running or not authenticated."
        msg_info "Run Option 1 to install/connect first."
        pause; return
    fi
    msg_info "Scanning peers..."; echo ""
    printf "  ${GOLD}${BD}  %-22s %-18s %-12s %s${NC}\n" "HOSTNAME" "IP" "STATUS" "DETAIL"
    echo -e "  ${DGRAY}  ──────────────────────────────────────────────────────${NC}"
    local found=0
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        found=1
        local ip name status detail sc
        ip=$(echo "$line"|awk '{print $1}')
        name=$(echo "$line"|awk '{print $2}')
        status=$(echo "$line"|awk '{print $4}')
        detail=$(echo "$line"|awk '{print $5,$6}')
        if [[ "$status" =~ active|online ]]; then sc="${GREEN}${BD}● $status${NC}"
        elif [[ "$status" == idle ]];        then sc="${YELLOW}${BD}● $status${NC}"
        else                                      sc="${DGRAY}● $status${NC}"; fi
        printf "  ${CYAN}  %-22s${NC} ${LCYAN}%-18s${NC} %-12b ${GRAY}%s${NC}\n" \
            "$name" "$ip" "$sc" "$detail"
    done < <(tailscale status 2>/dev/null)
    [[ $found -eq 0 ]] && echo -e "  ${DGRAY}  No peers found.${NC}"
    echo ""; divider; pause
}
 
# ==================================================
#  DIAGNOSTICS
# ==================================================
run_netcheck() {
    clear; draw_header
    divider; echo -e "  ${ORANGE}${BD}  [ NETWORK DIAGNOSTICS ]${NC}"; divider; echo ""
 
    echo -e "  ${PINK}${BD}  🌐  CONNECTIVITY${NC}"; echo ""
    for host in "8.8.8.8" "1.1.1.1" "google.com" "tailscale.com" "pkgs.tailscale.com"; do
        printf "  ${DGRAY}  %-35s${NC}" "$host"
        ping -c 1 -W 3 "$host" >/dev/null 2>&1 \
            && echo -e "${GREEN}${BD}✔ REACHABLE${NC}" \
            || echo -e "${RED}${BD}✖ UNREACHABLE${NC}"
    done
 
    echo ""; divider
    echo -e "  ${PINK}${BD}  🔍  DNS${NC}"; echo ""
    grep -v "^#" /etc/resolv.conf 2>/dev/null | sed 's/^/  /' || echo "  N/A"
 
    echo ""; divider
    echo -e "  ${PINK}${BD}  🖥  ENVIRONMENT${NC}"; echo ""
    echo -e "  ${DGRAY}  Firebase/IDX :${NC}  $(is_firebase_studio && echo "${ORANGE}${BD}YES${NC}" || echo "${DGRAY}No${NC}")"
    echo -e "  ${DGRAY}  Nix          :${NC}  $(is_nix_available   && echo "${TEAL}${BD}YES${NC}"   || echo "${DGRAY}No${NC}")"
    echo -e "  ${DGRAY}  Docker       :${NC}  $(is_docker          && echo "${BLUE}${BD}YES${NC}"   || echo "${DGRAY}No${NC}")"
    local devnix; devnix=$(find_dev_nix)
    echo -e "  ${DGRAY}  dev.nix      :${NC}  ${CYAN}${devnix:-Not found}${NC}"
    echo -e "  ${DGRAY}  tailscaled   :${NC}  $(pgrep tailscaled &>/dev/null && echo "${LIME}${BD}RUNNING (PID: $(pgrep tailscaled))${NC}" || echo "${RED}NOT RUNNING${NC}")"
 
    if command -v tailscale &>/dev/null; then
        echo ""; divider
        echo -e "  ${PINK}${BD}  📡  TAILSCALE NETCHECK${NC}"; echo ""
        tailscale netcheck 2>&1 | sed 's/^/  /'
        echo ""
    fi
    divider; msg_ok "Done."; pause
}
 
# ==================================================
#  MAIN LOOP
# ==================================================
while true; do
    draw_header
 
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  CORE OPERATIONS${NC}                                        ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Install & Connect     ${NC}${DGRAY}→  ${GREEN}Fully automatic — all methods${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Uninstall Completely  ${NC}${DGRAY}→  ${RED}Leave & remove Tailscale${NC}"
    echo ""
 
    echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  DIAGNOSTICS${NC}                                            ${YELLOW}${BD}│${NC}"
    echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}View Network Map      ${NC}${DGRAY}→  ${CYAN}List all mesh peers${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Network Diagnostics   ${NC}${DGRAY}→  ${YELLOW}Connectivity + env + netcheck${NC}"
    echo ""
 
    echo -e "  ${ORANGE}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${ORANGE}${BD}│  ${PINK}◈  FIREBASE STUDIO / NIX${NC}                                  ${ORANGE}${BD}│${NC}"
    echo -e "  ${ORANGE}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  5)${NC}  ${WHITE}Firebase Setup Guide  ${NC}${DGRAY}→  ${ORANGE}Auto-patch dev.nix + instructions${NC}"
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
        5) _firebase_auto_setup ;;
        0) clear; echo -e "\n  ${GOLD}${BD}  👋  Mesh stays running. Goodbye!${NC}\n"; sleep 1; exit 0 ;;
        *) msg_err "Invalid Option! Choose 0–5."; sleep 1 ;;
    esac
done
