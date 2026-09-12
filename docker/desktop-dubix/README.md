# desktop.dubix.at — Cloud-Desktop (Webtop / KDE Plasma)

Fertiges Setup für einen browserbasierten Linux-Desktop (KDE Plasma, Windows-11-Look,
deutsche Tastatur, LibreOffice) unter `desktop.dubix.at`, erreichbar über den
bestehenden Cloudflare Tunnel.

Alles hier ist Infrastructure-as-Code — Claude Code hat keinen SSH-Zugriff auf den
Contabo-VPS und kann die Schritte daher nicht selbst ausführen. Bitte auf dem
Server ausführen.

## Ressourcen

Der Container ist hart limitiert auf **2 GB RAM / 2 CPU** (`mem_limit`/`cpus` in
`docker-compose.yml`), damit genug Kapazität für die anderen Projekte (HTML-Apps,
Hermes) auf demselben VPS bleibt. Die Oberfläche wird primär für Office-Arbeit
genutzt, es ist kein hoher Dauer-Traffic zu erwarten — falls sich das ändert,
`mem_limit`/`cpus` in `docker-compose.yml` einfach anpassen und `deploy.sh` erneut
laufen lassen.

## 1. Deployment auf dem VPS

```bash
# Repo auf den Server holen (falls noch nicht vorhanden)
git clone <repo-url> ~/dubix && cd ~/dubix/docker/desktop-dubix
# oder: git pull, falls bereits geklont

chmod +x deploy.sh patch-cloudflare-tunnel.sh
./deploy.sh
```

`deploy.sh`:
- generiert ein starkes, zufälliges Passwort (falls noch keines existiert) und
  speichert es in `.env` (chmod 600)
- baut das Image (KDE Plasma + LibreOffice + Firefox + Windows-11-Theme +
  deutsches Tastaturlayout, siehe `Dockerfile`)
- startet den Container mit persistentem Volume `desktop-dubix-config`
  (Desktop-Zustand & Dateien bleiben bei Neustart erhalten)
- gibt das Login-Passwort am Ende aus

Der Container lauscht nur auf `127.0.0.1:3010` — er ist absichtlich nicht direkt
am Internet exponiert, sondern nur über den Cloudflare Tunnel erreichbar.

## 2. Cloudflare Tunnel erweitern

```bash
./patch-cloudflare-tunnel.sh
```

Das Skript:
- sucht die bestehende `cloudflared` Config (`/etc/cloudflared/config.yml` o.ä.)
- legt vorher ein Backup an
- fügt eine Ingress-Regel `desktop.dubix.at -> http://localhost:3010` ein
  (vor der Catch-all-404-Regel)
- routet den DNS-Eintrag für `desktop.dubix.at` auf den Tunnel
  (`cloudflared tunnel route dns ...`)
- lädt den `cloudflared`-Dienst neu

Falls die Config an einem anderen Pfad liegt oder `cloudflared` nicht als
systemd-Dienst läuft, gibt das Skript eine Warnung mit dem manuell einzufügenden
Eintrag aus.

## 3. Abschlusstest (bitte auf dem Server/im Browser durchführen)

- [ ] `docker ps` zeigt `desktop-dubix` als `Up`
- [ ] `https://desktop.dubix.at` ist im Browser erreichbar und fragt nach
      Benutzer/Passwort (Login: `dubix` / Passwort aus `.env`)
- [ ] Tastaturtest: In einem Texteditor `@` und `ß` tippen — beides muss korrekt
      erscheinen (Layout: Deutsch/Österreich, siehe
      `custom-cont-init.d/10-keyboard-de.sh`)
- [ ] LibreOffice Writer und Calc starten über das Startmenü (unten links, wie
      unter Windows 11)

## Hinweise / mögliche Nacharbeit

- Das Windows-11-Theme wird aus `yeyushengfan258/Win11-kde` gebaut. Je nach
  Repo-Layout kann es sein, dass Aurorae-Fensterdekoration oder Farbschema nicht
  100%ig automatisch übernommen werden — falls der Look nach dem ersten Login
  nicht passt: in KDE „Systemeinstellungen → Erscheinungsbild → Globales Design“
  einmal manuell auf das installierte Windows-11-Theme umstellen; die Einstellung
  wird danach im persistenten Volume gespeichert.
- Passwort ändern: `.env` bearbeiten und `docker compose up -d` erneut ausführen.
- Logs: `docker logs desktop-dubix`
