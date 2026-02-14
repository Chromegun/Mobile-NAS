#!/bin/sh
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
