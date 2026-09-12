#!/bin/bash
# Configure German keyboard layout (de-AT) for X11 and KDE, so @, ß and
# Umlaute produce the correct characters both locally and over noVNC/KasmVNC.
set -e

echo "de" > /etc/default/keyboard || true
sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="at"/' /etc/default/keyboard 2>/dev/null || \
    echo 'XKBLAYOUT="at"' >> /etc/default/keyboard

setxkbmap -layout at -variant "" 2>/dev/null || true

# Persist the layout in KDE's own keyboard config so it survives session
# restarts and applies inside Plasma itself (not just raw X11).
KXKBRC="/config/.config/kxkbrc"
mkdir -p "$(dirname "$KXKBRC")"
cat > "$KXKBRC" <<'EOF'
[Layout]
DisplayNames=
LayoutList=at
Use=true
EOF
