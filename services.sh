#!/bin/sh

# 무결성 검사: 필수 폴더 및 패키지 점검
check_integrity() {
    # 재부팅 시 사라지는 필수 런타임 폴더 생성
    mkdir -p /var/run/tailscale /var/lib/tailscale /dev/net
    
    # TUN 장치 무결성 확인
    if [ ! -c /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
        chmod 666 /dev/net/tun
    fi

    # 필수 패키지 확인
    for pkg in samba tailscale curl net-tools; do
        if ! dpkg -s $pkg >/dev/null 2>&1; then
            apt update && apt install -y $pkg > /dev/null 2>&1
        fi
    done
}

run_tailscale() {
    # 기존에 찌꺼기 프로세스가 있다면 정리
    killall tailscaled > /dev/null 2>&1
    sleep 1
    
    # 엔진 백그라운드 가동 (nohup으로 터미널을 꺼도 유지되게 설정)
    nohup tailscaled --tun=userspace-networking --socks5-server=localhost:$SOCKS_PORT > /tmp/ts_engine_err 2>&1 &
    
    # 엔진이 안정화될 때까지 대기
    sleep 3
    tailscale up > /tmp/ts_up_err 2>&1
}

# (Samba 실행 함수 등 기존 코드는 그대로 유지)
