#!/usr/bin/env bash
# Void Glow — gsettings overrides for GTK config that can't live in settings.ini
# install.sh runs this; safe to re-run anytime (idempotent).

gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font Mono 10"
echo "GTK gsettings applied."
