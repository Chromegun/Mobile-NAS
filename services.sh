#!/bin/sh

# 무결성 검사 및 복구 로직
check_integrity() {
    # 1. 필수 패키지 설치 확인 (Samba, Tailscale, Curl)
    for pkg in samba tailscale curl net-tools; do
        if ! dpkg -s $pkg >/dev/null 2>&1; then
            echo "❗ 필수 패키지($pkg) 누락 발견. 자동 설치를 시작합니다..."
            apt update && apt install -y $pkg > /dev/null 2>&1
        fi
    done

    # 2. 필수 구성 파일 존재 확인 및 복구
    # config.conf는 사용자의 설정이므로 삭제되었을 때만 기본값으로 복구합니다.
    [ ! -f "$CONF_FILE" ] && curl -sSL "$RAW_URL/config.conf" -o "$CONF_FILE"
    [ ! -f "$UI_FILE" ] && curl -sSL "$RAW_URL/ui.sh" -o "$UI_FILE" && chmod +x "$UI_FILE"
}

run_samba() {
    service smbd restart > /tmp/samba_err 2>&1
    service nmbd restart >> /tmp/samba_err 2>&1
    return $?
}

run_network_tun() {
    if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi
    if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi
    chmod 666 /dev/net/tun
    return $?
}

run_tailscale() {
    killall tailscaled > /dev/null 2>&1
    nohup tailscaled --tun=userspace-networking --socks5-server=localhost:$SOCKS_PORT > /tmp/ts_engine_err 2>&1 &
    sleep 2
    pgrep tailscaled > /dev/null
    return $?
}
