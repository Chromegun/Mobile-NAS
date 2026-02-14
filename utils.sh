#!/bin/sh

# 1. 자동 업데이트 기능
auto_update() {
    REMOTE_VER=$(curl -sSL "$RAW_URL/config.conf" | grep "VERSION=" | cut -d'"' -f2)
    if [ "$VERSION" != "$REMOTE_VER" ] && [ "$AUTO_UPDATE" = "true" ]; then
        echo "▶ 새 버전($REMOTE_VER) 발견. 업데이트를 시작합니다..."
        curl -sSL "$RAW_URL/setup.sh" | bash
        exit 0
    fi
}

# 2. Samba 설정 마법사
samba_wizard() {
    # 공유 폴더 생성 및 권한 부여
    mkdir -p "$SHARE_PATH"
    chmod -R 777 "$SHARE_PATH"
    
    # smb.conf 초기화 및 설정 삽입
    cat <<EOT > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = $SERVER_NAME
   security = user
   map to guest = Bad User
   log file = /var/log/samba/log.%m
   max log size = 50

[$SHARE_NAME]
   path = $SHARE_PATH
   browseable = yes
   read only = no
   guest ok = yes
   create mask = 0755
EOT
}

# 3. 로그 뷰어 기능
view_logs() {
    echo "=== 최신 시스템 로그 (에러 발생 시 확인) ==="
    [ -f /tmp/samba_err ] && echo "\n[Samba 로그]:" && cat /tmp/samba_err
    [ -f /tmp/ts_up_err ] && echo "\n[Tailscale 로그]:" && cat /tmp/ts_up_err
}
