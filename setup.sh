#!/usr/bin/env bash
# Fedora and dotfiles setup — idempotent, re-runnable

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()   { echo -e "${GREEN}[SETUP]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULTWARDEN_URL="${VAULTWARDEN_URL:-https://vault.bookermind.com}"
BW_ITEM_NAME="age-private-key"

# ─── Helpers ────────────────────────────────────────────────────────
copr_enabled() { dnf copr list 2>/dev/null | grep -q "^$1 "; }
repo_enabled() { dnf repolist --enabled 2>/dev/null | grep -q "^$1 "; }
pkg_installed() { rpm -q "$1" >/dev/null 2>&1; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# ─── Secrets Management ────────────────────────────────────────────
install_secrets_tools() {
    log "Installing secrets management tools..."
    local pkgs=(sops age rbw jq)
    local to_install=()
    for p in "${pkgs[@]}"; do pkg_installed "$p" || to_install+=("$p"); done
    [[ ${#to_install[@]} -gt 0 ]] && sudo dnf install -y "${to_install[@]}"
    for c in sops age rbw jq; do cmd_exists "$c" || error "$c not found after install"; done
    log "Secrets tools ready"
}

unlock_vaultwarden() {
    log "Unlocking Vaultwarden..."
    rbw config set server "$VAULTWARDEN_URL"

    if [[ -n "${BW_CLIENTID:-}" && -n "${BW_CLIENTSECRET:-}" ]]; then
        export RBW_SESSION="$(rbw login --apikey --raw 2>/dev/null || rbw unlock --raw)"
    elif [[ -n "${BW_EMAIL:-}" && -n "${BW_PASSWORD:-}" ]]; then
        export RBW_SESSION="$(rbw login "$BW_EMAIL" --password "$BW_PASSWORD" --raw 2>/dev/null || rbw unlock --raw)"
    else
        error "Set BW_CLIENTID+BW_CLIENTSECRET or BW_EMAIL+BW_PASSWORD"
    fi

    rbw sync --session "$RBW_SESSION" >/dev/null
    export AGE_KEY="$(rbw get "$BW_ITEM_NAME" --field notes --session "$RBW_SESSION")"
    [[ -n "$AGE_KEY" ]] || error "Failed to retrieve age key from Vaultwarden (item: $BW_ITEM_NAME)"
    log "Vaultwarden unlocked, age key retrieved"
}

decrypt_configs() {
    log "Decrypting configuration files..."
    export SOPS_AGE_KEY="$AGE_KEY"

    sops -d "$DOTFILES_DIR/opencode/.config/opencode/opencode.enc.json" \
        > "$DOTFILES_DIR/opencode/.config/opencode/opencode.json"

    sops -d "$DOTFILES_DIR/pi/.pi/agent/models.enc.json" \
        > "$DOTFILES_DIR/pi/.pi/agent/models.json"

    jq empty "$DOTFILES_DIR/opencode/.config/opencode/opencode.json"
    jq empty "$DOTFILES_DIR/pi/.pi/agent/models.json"
    log "Config files decrypted"
}

lock_vaultwarden() {
    if [[ -n "${RBW_SESSION:-}" ]]; then
        rbw lock --session "$RBW_SESSION" >/dev/null 2>&1 || true
        unset RBW_SESSION AGE_KEY SOPS_AGE_KEY
    fi
    log "Vaultwarden locked"
}

# ─── Repo / Package Setup ───────────────────────────────────────────
setup_copr_repos() {
    log "Configuring COPR repositories..."
    if ! copr_enabled "jdxcode/mise"; then
        sudo dnf copr enable -y jdxcode/mise
    else
        info "COPR jdxcode/mise already enabled"
    fi
    if ! copr_enabled "atim/starship"; then
        sudo dnf copr enable -y atim/starship
    else
        info "COPR atim/starship already enabled"
    fi
}

setup_rpmfusion() {
    log "Configuring RPM Fusion repositories..."
    local fedora_ver="$(rpm -E %fedora)"
    local free_rpm="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_ver}.noarch.rpm"
    local nonfree_rpm="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_ver}.noarch.rpm"

    if ! repo_enabled "rpmfusion-free"; then
        sudo dnf install -y "$free_rpm" "$nonfree_rpm"
        sudo dnf install -y rpmfusion-free-appstream-data rpmfusion-nonfree-appstream-data
    else
        info "RPM Fusion already configured"
    fi
}

setup_terra() {
    log "Configuring Terra repository..."
    if ! repo_enabled "terra"; then
        sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
    else
        info "Terra repository already configured"
    fi
}

install_base_packages() {
    log "Installing base packages..."
    local pkgs=(
        stow zsh zoxide fzf eza podman nodejs-bash-language-server
        bat hwinfo git mise starship zed
    )
    local to_install=()
    for p in "${pkgs[@]}"; do pkg_installed "$p" || to_install+=("$p"); done
    [[ ${#to_install[@]} -gt 0 ]] && sudo dnf install -y "${to_install[@]}"
    log "Base packages ready"
}

setup_multimedia() {
    log "Configuring multimedia..."
    # Swap ffmpeg-free → ffmpeg only if ffmpeg-free is installed
    if pkg_installed ffmpeg-free; then
        sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    elif ! pkg_installed ffmpeg; then
        sudo dnf install -y ffmpeg
    else
        info "ffmpeg already installed"
    fi

    # Update multimedia group (idempotent - dnf handles already-installed)
    sudo dnf update -y @multimedia \
        --setopt=install_weak_deps=False \
        --exclude=PackageKit-gstreamer-plugin \
        --exclude=libheif-freeworld \
        --exclude=obs-studio-freeworld

    # Sound and video group
    if ! dnf group list --installed 2>/dev/null | grep -q "Sound and Video"; then
        sudo dnf group install -y sound-and-video
    else
        info "Sound and Video group already installed"
    fi
}

setup_gpu_drivers() {
    log "Configuring GPU drivers..."
    sudo dnf install -y ffmpeg-libs libva libva-utils

    if lspci | grep -qi "vga\|3d" | grep -qi intel; then
        info "Intel GPU detected"
        if pkg_installed libva-intel-media-driver; then
            sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing
        fi
        pkg_installed libva-intel-driver || sudo dnf install -y libva-intel-driver
    elif lspci | grep -qi "vga\|3d" | grep -qi amd; then
        info "AMD GPU detected"
        pkg_installed mesa-va-drivers-freeworld || sudo dnf install -y mesa-va-drivers-freeworld
    else
        info "No Intel/AMD GPU detected - skipping GPU driver setup"
    fi
}

setup_fonts() {
    log "Installing fonts..."
    # Stow fonts if directory exists
    if [[ -d "$DOTFILES_DIR/fonts" ]]; then
        stow -v -t ~ fonts 2>/dev/null || info "Fonts already stowed"
        fc-cache -fv >/dev/null
    else
        warn "No fonts directory found at $DOTFILES_DIR/fonts"
    fi
}

# ─── Dotfiles & Containers ──────────────────────────────────────────
stow_dotfiles() {
    log "Stowing dotfiles..."
    cd "$DOTFILES_DIR"
    # Use --adopt to handle existing files, then restow
    stow -v -t ~ --adopt zsh starship bat systemd avatar opencode pi scripts distrobox 2>/dev/null \
        || stow -v -t ~ --restow zsh starship bat systemd avatar opencode pi scripts distrobox
    log "Dotfiles stowed"
}

setup_distrobox() {
    log "Setting up distrobox containers..."
    # Ensure containers aren't running (distrobox assemble --replace handles this)
    distrobox assemble create --file "$HOME/.config/distrobox/distrobox.ini" --replace
    log "Distrobox containers assembled"
}

install_pi_extensions() {
    log "Installing Pi extensions..."
    # Only run if ai-pi container exists
    if distrobox list --name ai-pi >/dev/null 2>&1; then
        distrobox enter ai-pi -- pi update --extensions
    else
        warn "ai-pi container not found, skipping Pi extensions"
    fi
}

# ─── Main ───────────────────────────────────────────────────────────
main() {
    log "Starting dotfiles setup on $(hostname)..."

    # Phase 1: Repositories (idempotent checks)
    setup_copr_repos
    setup_rpmfusion
    setup_terra

    # Phase 2: System packages
    sudo dnf upgrade -y --refresh  # Single update at start
    install_base_packages
    setup_multimedia
    setup_gpu_drivers
    setup_fonts

    # Phase 3: Secrets & dotfiles
    install_secrets_tools
    unlock_vaultwarden
    decrypt_configs
    stow_dotfiles
    lock_vaultwarden

    # Phase 4: Containers (after dotfiles stowed so configs available)
    setup_distrobox
    install_pi_extensions

    log "Setup complete! 🎉"
}

trap lock_vaultwarden EXIT
main "$@"