# pc.dubix.at — Upgrade auf KDE Plasma (Windows-11-Look)

Upgrade des bestehenden `webtop`-Containers (bisher `linuxserver/webtop:debian-xfce`)
auf `linuxserver/webtop:ubuntu-kde` mit Windows-11-Theme, deutschem Tastaturlayout
und LibreOffice — **unter der bestehenden Domain `pc.dubix.at`**, kein neuer
Container, keine neue Subdomain, keine Änderung an Caddy/Cloudflare Tunnel nötig.

Diese Dateien gehören inhaltlich zu `/opt/dubix/server-infra/webtop/` auf dem VPS
(dieses Repo spiegelt server-infra nicht 1:1). Bitte auf dem Server manuell
einspielen:

```bash
# Dockerfile + Init-Skripte in den bestehenden webtop-Ordner kopieren
cp Dockerfile /opt/dubix/server-infra/webtop/
cp -r custom-cont-init.d /opt/dubix/server-infra/webtop/

# In /opt/dubix/server-infra/webtop/docker-compose.yml:
#   image: lscr.io/linuxserver/webtop:debian-xfce
# ersetzen durch:
#   build: .

cd /opt/dubix/server-infra
docker compose -f docker-compose.full.yml up -d --build webtop
```

Der bestehende Volume-Mount `/opt/dubix/data/webtop:/config` bleibt erhalten —
vorhandene Dateien des Nutzers bleiben, nur die Desktop-Umgebung selbst wechselt
von XFCE- auf KDE-Konfiguration (separate Config-Verzeichnisse, kein Konflikt).

## Test

- `docker ps` → `webtop` läuft (`healthy`)
- `https://pc.dubix.at` im Browser öffnen, Login wie bisher
- `@` und `ß` testen (Layout: Deutsch/Österreich)
- LibreOffice Writer/Calc über das Startmenü starten
