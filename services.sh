#!/bin/sh

# 무결성 검사 및 필수 패키지 확인
check_integrity() {
    for pkg in samba tailscale curl net-tools; do
        if ! dpkg -s $pkg >/dev/null 2>&1; then
            echo "▶ 필수 패키지($pkg) 설치 중..."
            apt update && apt install -y $pkg > /dev/null 2>&1
        fi
    done
}

# 서비스 상태 모니터링 (Health Check)
health_check() {
    SAMBA_PROC=$(pgrep smbd)
    TS_PROC=$(pgrep tailscaled)
    
    if [ -z "$SAMBA_PROC" ] || [ -z "$TS_PROC" ]; then
        return 1 # 서비스 이상 발생
    fi
    return 0 # 정상
}

run_samba() {
    service smbd restart > /tmp/samba_err 2>&1
    service nmbd restart >> /tmp/samba_err 2>&1
}

run_network_tun() {
    if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi
    if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi
    chmod 666 /dev/net/tun
}

run_tailscale() {
    killall tailscaled > /dev/null 2>&1
    nohup tailscaled --tun=userspace-networking --socks5-server=localhost:$SOCKS_PORT > /tmp/ts_engine_err 2>&1 &
    sleep 2
    tailscale up > /tmp/ts_up_err 2>&1
}
