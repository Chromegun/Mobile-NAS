#!/bin/sh

# [필수] 서비스 상태 모니터링 (Health Check) 함수
health_check() {
    SAMBA_PROC=$(pgrep smbd)
    # Tailscale 프로세스가 떠 있는지 확인
    TS_PROC=$(pgrep tailscaled)
    
    if [ -z "$SAMBA_PROC" ] || [ -z "$TS_PROC" ]; then
        return 1 # 하나라도 죽어있으면 이상 발생(❌)
    fi
    return 0 # 둘 다 잘 떠 있으면 안정적(✅)
}

# 무결성 검사: 필수 폴더 및 패키지 점검
check_integrity() {
    mkdir -p /var/run/tailscale /var/lib/tailscale /dev/net
    if [ ! -c /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
        chmod 666 /dev/net/tun
    fi
    for pkg in samba tailscale curl net-tools; do
        if ! dpkg -s $pkg >/dev/null 2>&1; then
            apt update && apt install -y $pkg > /dev/null 2>&1
        fi
    done
}

run_samba() {
    service smbd restart > /tmp/samba_err 2>&1
    service nmbd restart >> /tmp/samba_err 2>&1
}

run_tailscale() {
    killall tailscaled > /dev/null 2>&1
    sleep 1
    nohup tailscaled --tun=userspace-networking --socks5-server=localhost:$SOCKS_PORT > /tmp/ts_engine_err 2>&1 &
    sleep 3
    tailscale up > /tmp/ts_up_err 2>&1
}
