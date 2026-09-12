FROM lscr.io/linuxserver/webtop:ubuntu-kde

# Office suite + browser + German locale/keyboard support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libreoffice-writer \
        libreoffice-calc \
        firefox \
        console-data \
        kde-config-cron \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# German locale (needed for correct Umlaut/ß rendering in apps)
RUN sed -i '/de_AT.UTF-8/s/^# //g; /de_DE.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=de_AT.UTF-8
ENV LANGUAGE=de_AT:de
ENV LC_ALL=de_AT.UTF-8

# Windows-11-like Plasma theme (Aurorae window decoration + global theme + icons)
RUN git clone --depth=1 https://github.com/yeyushengfan258/Win11-kde /tmp/win11-kde && \
    cp -r /tmp/win11-kde/aurorae/* /usr/share/aurorae/themes/ 2>/dev/null || true && \
    cp -r /tmp/win11-kde/kvantum/* /usr/share/Kvantum/ 2>/dev/null || true && \
    mkdir -p /usr/share/plasma/look-and-feel && \
    cp -r /tmp/win11-kde/look-and-feel/* /usr/share/plasma/look-and-feel/ 2>/dev/null || true && \
    rm -rf /tmp/win11-kde

COPY custom-cont-init.d/ /custom-cont-init.d/
RUN chmod +x /custom-cont-init.d/*.sh
