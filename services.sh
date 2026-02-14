#!/bin/sh

# 1. 네트워크 TUN 장치 활성화 함수 (이번 에러의 원인!)
run_network_tun() {
    if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi
    if [ ! -c /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
        chmod 666 /dev/net/tun
    fi
}

# 2. Samba 서비스 실행 함수
run_samba() {
    service smbd restart > /tmp/samba_err 2>&1
    service nmbd restart >> /tmp/samba_err 2>&1
}

# 3. Tailscale 엔진 가동 함수
run_tailscale() {
    killall tailscaled > /dev/null 2>&1
    sleep 1
    nohup tailscaled --tun=userspace-networking --socks5-server=localhost:$SOCKS_PORT > /tmp/ts_engine_err 2>&1 &
    sleep 3
    tailscale up > /tmp/ts_up_err 2>&1
}

# 4. 서비스 상태 점검 함수 (지난번 에러 해결용)
health_check() {
    SAMBA_PROC=$(pgrep smbd)
    TS_PROC=$(pgrep tailscaled)
    if [ -z "$SAMBA_PROC" ] || [ -z "$TS_PROC" ]; then
        return 1
    fi
    return 0
}

# 5. 무결성 검사 함수
check_integrity() {
    mkdir -p /var/run/tailscale /var/lib/tailscale /dev/net
    for pkg in samba tailscale curl net-tools; do
        if ! dpkg -s $pkg >/dev/null 2>&1; then
            apt update && apt install -y $pkg > /dev/null 2>&1
        fi
    done
}
