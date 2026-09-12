#!/bin/bash
# Apply a Windows-11-like look (bottom-left start menu is Plasma's default
# already) as the default appearance for the desktop user, only on first run.
set -e

KDEGLOBALS="/config/.config/kdeglobals"
KWINRC="/config/.config/kwinrc"

if [ ! -f "/config/.win11-theme-applied" ]; then
    mkdir -p /config/.config

    # Global theme / color scheme
    if [ -f "$KDEGLOBALS" ]; then
        kwriteconfig6 --file "$KDEGLOBALS" --group General --key ColorScheme "Windows11" 2>/dev/null || true
    fi

    # Window decoration (Aurorae Win11 theme, if it installed correctly)
    kwriteconfig6 --file "$KWINRC" --group org.kde.kdecoration2 --key theme "__aurorae__svg__Win11" 2>/dev/null || true
    kwriteconfig6 --file "$KWINRC" --group org.kde.kdecoration2 --key library "org.kde.kwin.aurorae" 2>/dev/null || true

    touch /config/.win11-theme-applied
fi
