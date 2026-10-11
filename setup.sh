#! /usr/bin/env bash
# Fedora and dotfiles setup

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()   { echo -e "${GREEN}[SETUP]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULTWARDEN_URL="${VAULTWARDEN_URL:-https://vault.bookermind.com}"
BW_ITEM_NAME="age-private-key"

install_secrets_tools() {
    log "Installing secrets management tools..."
    sudo dnf install -y sops age rbw jq
    command -v sops >/dev/null || error "sops not found"
    command -v age >/dev/null || error "age not found"
    command -v rbw >/dev/null || error "rbw not found"
    command -v jq >/dev/null || error "jq not found"
    log "Secrets tools installed"
}

unlock_Vaultwarden() {
    log "Unlocking Vaultwarden..."
    rbw config set server "$VAULTWARDEN_URL"

    if [[ -n "${BW_CLIENTID:-}" && -n "${BW_CLIENTSECRET:-}" ]]; then
        export RBW_SESSION="$(rbw login --apikey --raw)"
    elif [[ -n "${BW_EMAIL:-}" && -n "${BW_PASSWORD:-}" ]]; then
        export RBW_SESSION="$(rbw login "$BW_EMAIL" --password "$BW_PASSWORD" --raw)"
    else
        error "Set BW_CLIENTID+BW_CLIENTSECRET or BW_EMAIL+BW_PASSWORD"
    fi

    rbw sync --session "$RBW_SESSION"
    export AGE_KEY="$(rbw get "$BW_ITEM_NAME" --field notes --session "$RBW_SESSION")"
    [[ -n "$AGE_KEY" ]] || error "Failed to retrieve age key from Vaultwarden (item: $BW_ITEM_NAME)"
    log "Vaultwarden unlocked, age key retreived"
}

decrypt_configs() {
    log "Decrypting configuration files to stowed locations..."

    export SOPS_AGE_KEY="$AGE_KEY"

    sops -d "$DOTFILES_DIR/opencode/.config/opencode/opencode.enc.json" \
        > "$DOTFILES_DIR/opencode/.config/opencode/opencode.json"

    sops -d "$DOTFILES_DIR/pi/.pi/agent/models.enc.json" \
        > "$DOTFILES_DIR/pi/.pi/agent/models.json"

    jq empty "$DOTFILES_DIR/opencode/.config/opencode/opencode.json"
    jq empty "$DOTFILES_DIR/pi/.pi/agent/models.json"

    logs "Config files decrypted"
}

lock_vaultwarden() {
    if [[ -n "${RBW_SESSION:-}" ]]; then
        rbw lock --session "$RBW_SESSION" >/dev/null 2>&1 || true
        unset RBW_SESSION AGE_KEY SOPS_AGE_KEY
    fi
    log "Vaultwarden locked"
}

main() {
    log "Starting dotfiles setup on $(hostname)..."
    echo "==> Installing common and prerequisite packages"
    echo
    sudo dnf install -y stow zsh zoxide fzf eza podman nodejs-bash-language-server cat bat hwinfo git
    echo "==> Installing mise from copr"
    echo
    sudo dnf copr enable -y jdxcode/mise
    sudo dnf install mise
    echo "==> Setting up RPM Fusion and Terra Repositories"
    sudo dnf install -y "https://mirrors.rpmfusion.orb/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    sudo dnf install -y rpm-fusion-free-appstream-data rpm-fusion-nonfree-appstream-data
    sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

    echo "==> Install secondary packages (from rpm fusion and terra)"
    echo
    sudo dnf install starship zed

    echo "==> Setup multimedia"
    sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
    sudo dnf update @multimedia --setopt="install-weak-deps=False" --exclude=PackageKit-gstreamer-plugin --exclude=libheif-freeworld --exclude=obs-studio-freeworld
    sudo dnf group install -y sound-and-video

    # GPU Drivers
    echo "==> Install GPU drivers following hardware detection..."
    echo
    sudo dnf install -y ffmpegs-libs libva libva-utils
    if lspci | grep -i "vga\|3d" | grep -i intel; then
        echo "==> Intel GPU detected"
        sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
        sudo dnf install -y libva-intel-driver
    elif lspci | grep "vga\|3d" | grep -i amd; then
        echo "==> AMD GPU detected"
        sudo dnf install -y mesa-va-drivers-freeworld
    else
        echo "==> No intel or AMD graphics hardware detected - skipping install"
    fi

    # Fonts - local files TODO
    log "Installing fonts to user directory"
    echo "==> Installing fonts into your local user directory..."
    stow -v -t ~ fonts
    fc-cache -fv # Refresh the font cache

    # Sensitive file decryption
    install_secrets_tools
    unlock_Vaultwarden
    decrypt_configs

    # Stow dotfiles (including decrypted configs)
    log "Stowing dotfiles...."
    cd "$DOTFILES_DIR"
    stow -v -t ~ zsh starship bat systemd avatar opencode pi scripts distrobox
    # Lock vaultwarden
    lock_vaultwarden

    # Distrobox
    log "Assembling Distrobox containers..."
    distrobox assemble create --file "$HOME/.config/distrobox/distrobox.ini" --replace
    # Pi extensions
    distrobox enter ai-pi -- pi update --extensions

    log "Setup Complete!!"
}

trap lock_vaultwarden EXIT
main "$@"
