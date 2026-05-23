#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# VOID GLOW — install.sh
# ─────────────────────────────────────────────────────────────────────
# Deploys the Void Glow rice to a fresh CachyOS system from this repo.
# Idempotent: safe to re-run after partial failures. Each step is
# guarded so re-runs only do what hasn't been done.
#
# Usage:
#   cd ~/void-glow
#   ./install.sh
# ─────────────────────────────────────────────────────────────────────

set -e   # exit on error
set -u   # error on undefined vars

# ── Colors for status output (work in any terminal) ──────────────────
C_RESET='\033[0m'
C_TEAL='\033[1;36m'      # accent — section headers, OK
C_INDIGO='\033[1;34m'    # secondary — info
C_RED='\033[1;31m'       # errors, destructive
C_SUBTEXT='\033[2;37m'   # muted — notes

say()    { printf "${C_TEAL}==>${C_RESET} %s\n"   "$*"; }
info()   { printf "${C_INDIGO} ->${C_RESET} %s\n" "$*"; }
warn()   { printf "${C_RED} !!${C_RESET} %s\n"    "$*"; }
note()   { printf "${C_SUBTEXT}    %s${C_RESET}\n" "$*"; }

# Prompt helper. Returns 0 if user confirms, 1 if not.
confirm() {
    local prompt="${1:-Continue?} [y/N] "
    local reply
    read -r -p "$prompt" reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# ─────────────────────────────────────────────────────────────────────
# 1. PREFLIGHT
# ─────────────────────────────────────────────────────────────────────
say "Preflight checks"

if [ "$EUID" -eq 0 ]; then
    warn "Don't run install.sh as root."
    note "Stow needs \$HOME to be your user home, not /root."
    note "The script will use sudo when it needs to."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found — this script is for Arch/CachyOS."
    exit 1
fi

if [ ! -f "$REPO_DIR/packages.txt" ]; then
    warn "packages.txt missing — are you running from the repo root?"
    exit 1
fi

info "Running as: $USER"
info "Repo dir: $REPO_DIR"

# ─────────────────────────────────────────────────────────────────────
# 2. PARSE packages.txt — extract per-section lists
# ─────────────────────────────────────────────────────────────────────
say "Parsing packages.txt"

parse_section() {
    local section="$1"
    awk -v sect="[$section]" '
        $0 == sect            { in_section = 1; next }
        /^\[/                 { in_section = 0 }
        in_section && /^[^#[:space:]]/ { print $1 }
    ' "$REPO_DIR/packages.txt"
}

PACMAN_PKGS=$(parse_section pacman)
AUR_PKGS=$(parse_section aur)
PIPX_PKGS=$(parse_section pipx)

info "Pacman: $(echo "$PACMAN_PKGS" | wc -w) pkgs"
info "AUR:    $(echo "$AUR_PKGS"    | wc -w) pkgs"
info "pipx:   $(echo "$PIPX_PKGS"   | wc -w) pkgs"

# ─────────────────────────────────────────────────────────────────────
# 3. PACMAN
# ─────────────────────────────────────────────────────────────────────
say "Installing pacman packages"

# Refresh databases first (avoids "target not found" on stale mirrors).
sudo pacman -Sy

# --needed skips already-installed; --noconfirm reduces prompts but pacman
# still asks for sudo password once. Single command for all packages =
# pacman resolves the whole transaction at once (better than looping).
# shellcheck disable=SC2086
sudo pacman -S --needed --noconfirm $PACMAN_PKGS

# ─────────────────────────────────────────────────────────────────────
# 4. AUR HELPER + AUR PACKAGES
# ─────────────────────────────────────────────────────────────────────
say "AUR packages"

AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
fi

if [ -z "$AUR_HELPER" ]; then
    warn "No AUR helper found (paru or yay)."
    note "Tokyonight-GTK requires gtk-engine-murrine (AUR-only as of Nov 2025)."
    note "Icons (Tela-circle) also live on AUR."
    if confirm "Skip AUR section (you can install gtk-engine-murrine + tela-circle-icon-theme later)?"; then
        info "Skipping AUR; remember to install $AUR_PKGS later."
    else
        warn "Aborting — install paru or yay first, then re-run."
        exit 1
    fi
else
    info "Using $AUR_HELPER"
    # shellcheck disable=SC2086
    $AUR_HELPER -S --needed --noconfirm $AUR_PKGS
fi

# ─────────────────────────────────────────────────────────────────────
# 5. PIPX PACKAGES
# ─────────────────────────────────────────────────────────────────────
say "pipx packages"

if ! command -v pipx >/dev/null 2>&1; then
    info "Installing pipx via pacman"
    sudo pacman -S --needed --noconfirm python-pipx
fi
pipx ensurepath >/dev/null

for pkg in $PIPX_PKGS; do
    if pipx list 2>/dev/null | grep -q "package $pkg "; then
        info "pipx: $pkg already installed"
    else
        info "pipx install $pkg"
        pipx install "$pkg"
    fi
done

# ─────────────────────────────────────────────────────────────────────
# 6. EXTERNAL THEME — Tokyonight-GTK
# ─────────────────────────────────────────────────────────────────────
# Not in repos; installed via the upstream repo's own install.sh.
# Lands in ~/.themes/Tokyonight-Dark (per-user).
# ─────────────────────────────────────────────────────────────────────
say "Tokyonight-GTK theme"

if [ -d "$HOME/.themes/Tokyonight-Dark" ]; then
    info "Tokyonight-Dark already installed at ~/.themes/"
else
    SCRATCH="$HOME/.cache/void-glow-install-scratch"
    mkdir -p "$SCRATCH"
    if [ ! -d "$SCRATCH/Tokyo-Night-GTK-Theme" ]; then
        info "Cloning Tokyonight-GTK upstream"
        git clone --depth 1 https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git \
            "$SCRATCH/Tokyo-Night-GTK-Theme"
    fi
    info "Running upstream install.sh (-c dark -t default --tweaks black -l)"
    ( cd "$SCRATCH/Tokyo-Night-GTK-Theme/themes" && \
      ./install.sh -c dark -t default --tweaks black -l )
fi

# ─────────────────────────────────────────────────────────────────────
# 7. SDDM SYSTEM THEME DEPLOYMENT
# ─────────────────────────────────────────────────────────────────────
# Copy ~/void-glow/system/sddm/void-glow/ to /usr/share/sddm/themes/,
# then activate via /etc/sddm.conf [Theme] Current=void-glow.
# ─────────────────────────────────────────────────────────────────────
say "SDDM Void Glow theme"

SDDM_SRC="$REPO_DIR/system/sddm/void-glow"
SDDM_DST="/usr/share/sddm/themes/void-glow"

if [ ! -d "$SDDM_SRC" ]; then
    warn "$SDDM_SRC missing — skipping SDDM theme."
else
    info "Copying theme to $SDDM_DST"
    sudo rm -rf "$SDDM_DST"
    sudo cp -r "$SDDM_SRC" "$SDDM_DST"
    sudo chmod -R 755 "$SDDM_DST"

    # Activate by writing Current=void-glow under [Theme] in /etc/sddm.conf.
    # Four cases handled: file missing, [Theme] missing, Current= line
    # exists, [Theme] exists but no Current= line.
    info "Activating theme in /etc/sddm.conf"
    SDDM_CONF="/etc/sddm.conf"
    if [ ! -f "$SDDM_CONF" ]; then
        echo -e "[Theme]\nCurrent=void-glow" | sudo tee "$SDDM_CONF" >/dev/null
    elif ! sudo grep -q '^\[Theme\]' "$SDDM_CONF"; then
        echo -e "\n[Theme]\nCurrent=void-glow" | sudo tee -a "$SDDM_CONF" >/dev/null
    elif sudo grep -q '^Current=' "$SDDM_CONF"; then
        sudo sed -i 's|^Current=.*|Current=void-glow|' "$SDDM_CONF"
    else
        sudo sed -i '/^\[Theme\]/a Current=void-glow' "$SDDM_CONF"
    fi
    note "Login screen will use Void Glow theme on next reboot."
fi

# ─────────────────────────────────────────────────────────────────────
# 8. USERNAME SUBSTITUTION (Quickshell QML)
# ─────────────────────────────────────────────────────────────────────
# The Quickshell shell.qml hardcodes /home/zua/.cache/... paths because
# QML's string literals don't expand $HOME. We sed those to the real
# user's home before stowing — only on disk in the repo (which is the
# source for the symlink, so the symlinked file reads the corrected paths).
# Safe to re-run: if $USER == zua, the sed is a no-op.
# ─────────────────────────────────────────────────────────────────────
say "Username substitution in Quickshell QML"

QS_QML="$REPO_DIR/quickshell/.config/quickshell/shell.qml"
if [ -f "$QS_QML" ] && [ "$USER" != "zua" ]; then
    info "Replacing /home/zua/ with /home/$USER/ in shell.qml"
    sed -i "s|/home/zua/|/home/$USER/|g" "$QS_QML"
else
    info "No substitution needed (USER=$USER)"
fi

# ─────────────────────────────────────────────────────────────────────
# 9. STOW PACKAGES (with conflict backup)
# ─────────────────────────────────────────────────────────────────────
# CachyOS (and most distros) ship default configs that collide with
# Stow's target paths. We pre-flight every package's files: if a
# real file exists at the target and it's not already our symlink,
# we move it under ~/.config-backup-<timestamp>/ before stowing.
# Non-destructive: originals preserved, recoverable; idempotent across
# re-runs because already-correct symlinks are skipped.
# ─────────────────────────────────────────────────────────────────────
say "Stowing packages"

STOW_PKGS=(
    theme
    hyprland
    waybar
    wofi
    kitty
    zsh
    nvim
    yazi
    tmux
    quickshell
    wallpaper
    dunst
    gtk
)

# Backup directory — timestamped so re-runs don't collide.
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BACKUP_USED=0

# Walk every file in a package. For each, compute the target path under
# $HOME. If the target exists and is NOT already a symlink into our repo,
# move it under the backup, preserving its relative path.
backup_conflicting_targets() {
    local pkg="$1"
    local src_root="$REPO_DIR/$pkg"
    [ -d "$src_root" ] || return 0

    while IFS= read -r -d '' src_file; do
        local rel="${src_file#$src_root/}"
        local target="$HOME/$rel"

        # No target = no conflict.
        if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            continue
        fi

        # Already our symlink = no conflict.
        if [ -L "$target" ]; then
            local link_dest
            link_dest="$(readlink -f "$target" 2>/dev/null || true)"
            case "$link_dest" in
                "$REPO_DIR"/*) continue ;;
            esac
        fi

        # Real conflict: move it.
        local backup_target="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$backup_target")"
        mv "$target" "$backup_target"
        BACKUP_USED=1
        note "backup: $target -> $backup_target"
    done < <(find "$src_root" -type f -print0)
}

# Pre-flight: back up everything that would conflict, across all packages.
for pkg in "${STOW_PKGS[@]}"; do
    [ -d "$REPO_DIR/$pkg" ] && backup_conflicting_targets "$pkg"
done

if [ "$BACKUP_USED" = "1" ]; then
    info "Pre-existing configs moved to: $BACKUP_DIR"
    note "If anything's wrong, originals are recoverable from there."
fi

# Now stow cleanly.
for pkg in "${STOW_PKGS[@]}"; do
    if [ ! -d "$REPO_DIR/$pkg" ]; then
        info "skip: $pkg (not in repo)"
        continue
    fi
    info "stow: $pkg"
    # --restow re-links cleanly each run (idempotent);
    # --no-folding keeps every file as its own symlink (clearer for debug).
    stow --restow --no-folding -d "$REPO_DIR" -t "$HOME" "$pkg"
done

# ─────────────────────────────────────────────────────────────────────
# 10. gsettings overrides (GTK)
# ─────────────────────────────────────────────────────────────────────
# settings.ini is read by some GTK apps; gsettings (dconf) by others.
# Both must be set for full coverage.
# ─────────────────────────────────────────────────────────────────────
say "Applying gsettings overrides"

if [ -x "$REPO_DIR/gtk/apply-gsettings.sh" ]; then
    "$REPO_DIR/gtk/apply-gsettings.sh"
else
    warn "gtk/apply-gsettings.sh missing or not executable — skipping."
fi

# ─────────────────────────────────────────────────────────────────────
# 11. DEFAULT SHELL → zsh
# ─────────────────────────────────────────────────────────────────────
say "Default shell"

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
ZSH_PATH="$(command -v zsh)"

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    info "Already zsh ($ZSH_PATH)"
elif [ -z "$ZSH_PATH" ]; then
    warn "zsh not found — somehow it didn't install. Skipping."
else
    info "Current shell: $CURRENT_SHELL"
    info "Proposed:      $ZSH_PATH"
    if confirm "Change default shell to zsh?"; then
        chsh -s "$ZSH_PATH"
        note "Takes effect on next login."
    else
        info "Keeping current shell."
    fi
fi

# ─────────────────────────────────────────────────────────────────────
# 12. POST-INSTALL NOTES — what still needs hands
# ─────────────────────────────────────────────────────────────────────
say "Done — post-install items"

cat <<EOF

The repo is deployed. A few items still need your hands:

  ${C_TEAL}1. B2 credentials${C_RESET}
     mkdir -p ~/.config/b2
     cp ~/void-glow/quickshell/.config/quickshell/b2-credentials.example \\
        ~/.config/b2/credentials
     chmod 600 ~/.config/b2/credentials
     # Then edit and paste your real B2_KEY_ID + B2_APP_KEY.

  ${C_TEAL}2. Monitor config (bare metal)${C_RESET}
     Edit  ~/.config/hypr/monitors.conf
     Comment the VM block, uncomment the bare-metal block.
     Verify real names: hyprctl monitors all

  ${C_TEAL}3. Workspace pinning (bare metal)${C_RESET}
     Edit  ~/.config/hypr/workspaces.conf
     Same VM/bare-metal toggle pattern.

  ${C_TEAL}4. Obsidian vault path${C_RESET}
     Edit  ~/.config/nvim/lua/plugins/obsidian.lua
     Repoint to your real vault.

  ${C_TEAL}5. Wallpapers${C_RESET}
     Drop your collection into:
       ~/Pictures/wallpapers/{dark,gaming,minimal}/
     A solid-VOID_BASE placeholder is at:
       ~/Pictures/wallpapers/dark/voidglow-placeholder.png

  ${C_TEAL}6. Reload / re-login${C_RESET}
     hyprctl reload                       # picks up most config changes
     Log out + back in                    # triggers exec-once + SDDM theme

  ${C_TEAL}7. Backed-up configs${C_RESET}
     If install.sh moved any pre-existing files aside, they're saved at:
       ~/.config-backup-<timestamp>/
     Safe to delete once you've confirmed everything works.

${C_SUBTEXT}For the full keybind reference + bare-metal flag list, see README.md.${C_RESET}

EOF
