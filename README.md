# Void Glow

> Void Glow — a minimal, dark Hyprland rice on CachyOS. Deep near-blacks with teal and indigo glow accents; built in a VM, deployed to bare metal via GNU Stow.

---

## Palette

The single source of truth lives at `~/.config/theme/colors.sh` (stowed from `theme/.config/theme/colors.sh`). Every component reads from here.

| Role              | Hex       |
| ----------------- | --------- |
| Base              | `#0d0d0f` |
| Surface           | `#131318` |
| Overlay           | `#1c1c24` |
| Accent — Teal     | `#5eead4` |
| Accent — Indigo   | `#818cf8` |
| Text              | `#e2e8f0` |
| Subtext           | `#64748b` |
| Red (errors only) | `#f87171` |
| Font              | JetBrainsMono Nerd Font Mono |

**Discipline:** red means *one thing* across the whole rice — errors, destructive actions, critical notifications. Teal is the primary accent (active state, glow edge). Indigo is the secondary accent (in-flight states, secondary actions).

---

## Keybinds

### Hyprland — workspaces & windows

| Bind                              | Action                                  | Notes                  |
| --------------------------------- | --------------------------------------- | ---------------------- |
| `Super+1` … `Super+0`             | Switch to workspace 1–10                | `0` = workspace 10     |
| `Super+Shift+1` … `Super+Shift+0` | Move active window to workspace 1–10    | No follow              |
| `Super+h/j/k/l`                   | Focus left / down / up / right          | vim style              |
| `Super+←/↓/↑/→`                   | Focus left / down / up / right          | arrow style            |
| `Super+Shift+h/j/k/l`             | Swap active window with neighbor        |                        |
| `Super + drag` (left mouse)       | Move floating window                    |                        |
| `Super + drag` (right mouse)      | Resize floating window                  |                        |

### Hyprland — apps & utilities

| Bind          | Action                              | Notes                                                            |
| ------------- | ----------------------------------- | ---------------------------------------------------------------- |
| `Super+Q`     | Launch terminal                     | `$terminal = kitty`                                              |
| `Super+E`     | Launch file manager                 | `$fileManager = thunar`                                          |
| `Super+R`     | App launcher                        | wofi (drun mode)                                                 |
| `Super+W`     | Wallpaper picker                    | waypaper → awww backend                                          |
| `Super+V`     | Toggle floating                     |                                                                  |
| `Super+C`     | Kill active window                  |                                                                  |
| `Super+M`     | Exit Hyprland                       | with `hyprshutdown` fallback                                     |
| `Super+F12`   | Toggle gamemode                     | Compositor effects off; Waybar button mirrors state              |
| `Ctrl+Alt+L`  | Lock screen                         | hyprlock; moved from `Super+L` to avoid focus-right collision    |
| `Print`       | Full-screen screenshot to clipboard | grim → wl-copy                                                   |
| `Super+P`     | Region screenshot to clipboard      | grim + slurp → wl-copy                                           |

### Tmux (prefix `Ctrl-a`)

| Bind             | Action                  | Notes                                                |
| ---------------- | ----------------------- | ---------------------------------------------------- |
| `Ctrl-a`         | Prefix                  | Sends `Ctrl-a` to nested apps with double-tap        |
| `prefix \|`      | Vertical split          | Inherits current pane's directory                    |
| `prefix -`       | Horizontal split        | Inherits current pane's directory                    |
| `prefix c`       | New window              | Inherits current pane's directory                    |
| `prefix h/j/k/l` | Pane navigation         | vim style                                            |
| `prefix r`       | Reload tmux config      |                                                      |
| `prefix d`       | Detach session          | Survives; `tmux attach -t <name>` to return          |

### Neovim — Void Glow additions

Upstream LazyVim defaults are documented at [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps). Our additions:

| Bind          | Action                            | Plugin        |
| ------------- | --------------------------------- | ------------- |
| `<leader>on`  | New Obsidian note                 | obsidian.nvim |
| `<leader>os`  | Search Obsidian vault             | obsidian.nvim |
| `<leader>od`  | Open today's daily note           | obsidian.nvim |
| `<leader>ob`  | Show backlinks for current note   | obsidian.nvim |

Theme: tokyonight with palette overrides (see `nvim/.config/nvim/lua/plugins/colorscheme.lua`). Markdown rendering via LazyVim `lang.markdown` extra.

### Kitty defaults worth knowing

| Bind                | Action                          |
| ------------------- | ------------------------------- |
| `Ctrl+Shift+V`      | Paste from clipboard            |
| `Ctrl+Shift+C`      | Copy selection                  |
| `Ctrl+Shift+Enter`  | New window in current dir       |
| `Ctrl+Shift+T`      | New tab                         |
| `Ctrl+Shift+F5`     | Reload kitty config             |
| `Ctrl+Shift+,`      | Edit kitty config               |

### Yazi

| Bind                 | Action                                  | Notes                                |
| -------------------- | --------------------------------------- | ------------------------------------ |
| `y` (shell command)  | Launch Yazi; cd to selected dir on exit | Custom function in `.zshrc`          |
| `q`                  | Exit Yazi with cd                       | inside Yazi                          |
| `Q`                  | Exit Yazi without cd                    | inside Yazi                          |
| `h/j/k/l`            | Navigate                                | vim-style                            |
| `<space>`            | Toggle select                           |                                      |
| `<enter>`            | Open file                               |                                      |

---

## Install

A bootstrap script handles deployment from this repo to a fresh CachyOS system.

```bash
# Clone (anywhere; ~/void-glow recommended)
git clone https://github.com/zuabua/void-glow.git ~/void-glow
cd ~/void-glow

# Run the bootstrap (installs packages, stows configs, applies system theme, etc.)
./install.sh
```

See `install.sh` and `packages.txt` for the full set of dependencies and operations.

### Bare-metal items deferred from VM build

The repo is built in a VM and tested on bare metal during transition. A handful of items are flagged for bare-metal validation:

- **Monitor config:** uncomment the bare-metal block in `hyprland/.config/hypr/monitors.conf`; verify real names with `hyprctl monitors all`.
- **Workspace pinning:** uncomment the bare-metal block in `hyprland/.config/hypr/workspaces.conf`.
- **Per-monitor wallpaper:** edit `wallpaper/.config/waypaper/config.ini` (`monitors = …`) once real outputs are present.
- **B2 credentials:** recreate `~/.config/b2/credentials` from `quickshell/.config/quickshell/b2-credentials.example`.
- **Obsidian vault path:** repoint `nvim/.config/nvim/lua/plugins/obsidian.lua` to the real vault.
- **Quickshell QML username paths:** `install.sh` substitutes `$USER` into hardcoded `/home/zua/` references.
- **hypridle stability:** auto-lock daemon segfaults in VM after init; configs are valid and expected to work on bare metal.
- **hyprlock blur:** depends on GPU EGL; VM virtual GPU falls back to a no-blur path. Config is correct.
- **Qt theming:** Kvantum + qt5ct/qt6ct setup deferred. Env var `QT_QPA_PLATFORMTHEME=qt5ct` is already in Hyprland config as forward-prep.

---

## Repo structure

Each top-level folder is a GNU Stow package mirroring `$HOME`:

```
~/void-glow/
├── theme/              # palette SSOT — colors.sh
├── hyprland/           # Hyprland compositor (incl. monitors, workspaces, lock, idle, gamemode)
├── waybar/             # status bar (multi-monitor, custom B2 + gamemode buttons)
├── wofi/               # app launcher
├── kitty/              # terminal
├── zsh/                # shell (.zshrc + .p10k.zsh)
├── nvim/               # Neovim (LazyVim + HTB-friendly plugins)
├── yazi/               # file manager
├── tmux/               # multiplexer (Ctrl-a prefix)
├── quickshell/         # B2 widget (drop zone, manage panel)
├── wallpaper/          # waypaper config (awww backend)
├── dunst/              # notifications
├── gtk/                # GTK3/4 theme application
└── system/sddm/        # SDDM theme (non-stow; install.sh deploys to /usr/share)
```

Plus root-level `install.sh` and `packages.txt`.

---

## Credits

Built on the shoulders of:

- [Hyprland](https://hyprland.org/) — Wayland compositor
- [hyprlock](https://github.com/hyprwm/hyprlock) / [hypridle](https://github.com/hyprwm/hypridle) — lockscreen + idle
- [Quickshell](https://quickshell.outfoxxed.me/) — QtQuick shell for the B2 widget
- [Waybar](https://github.com/Alexays/Waybar) — status bar
- [awww](https://github.com/LGFae/awww) — wallpaper daemon (formerly swww)
- [waypaper](https://github.com/anufrievroman/waypaper) — wallpaper picker GUI
- [LazyVim](https://www.lazyvim.org/) — Neovim distribution
- [Tokyonight-GTK](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme) — GTK theme base
- [Tela-circle](https://github.com/vinceliuice/Tela-circle-icon-theme) — icon set
- [Backblaze B2 CLI](https://github.com/Backblaze/B2_Command_Line_Tool) — cloud uploads
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) — typography

---

*Void Glow is a personal rice; the configs here are tuned for a multi-monitor desktop setup, HackTheBox / CJCA workflow, and Backblaze B2 sync. Adapt freely.*
