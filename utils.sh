#!/bin/sh

# 1. 자동 업데이트 기능
auto_update() {
    # 깃허브 최신 버전 확인
    REMOTE_VER=$(curl -sSL "$RAW_URL/config.conf.default" | grep "VERSION=" | cut -d'"' -f2)
    
    if [ "$VERSION" != "$REMOTE_VER" ] && [ "$AUTO_UPDATE" = "true" ]; then
        echo "▶ 새 로직 발견($REMOTE_VER). 기능만 업데이트합니다..."
        
        # 1. 로직 파일들만 업데이트
        curl -sSL "$RAW_URL/ui.sh" -o /usr/local/lib/mobile-nas/ui.sh
        curl -sSL "$RAW_URL/services.sh" -o /usr/local/lib/mobile-nas/services.sh
        curl -sSL "$RAW_URL/utils.sh" -o /usr/local/lib/mobile-nas/utils.sh
        curl -sSL "$RAW_URL/nas-start" -o /usr/local/bin/nas-start
        chmod +x /usr/local/bin/nas-start /usr/local/lib/mobile-nas/*.sh
        
        # 2. [핵심 추가] 로컬 설정 파일의 버전 번호도 업데이트 (루프 방지)
        sed -i "s/VERSION=\"$VERSION\"/VERSION=\"$REMOTE_VER\"/" /etc/mobile-nas/config.conf
        
        echo "✅ 로직 업데이트 및 버전 동기화 완료! 재시작합니다."
        sleep 1
        exec nas-start
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
