#!/bin/sh

# 자동 업데이트 및 무한 루프 방지 로직
auto_update() {
    # 깃허브 최신 버전 확인
    REMOTE_VER=$(curl -sSL "$RAW_URL/config.conf.default" | grep "VERSION=" | cut -d'"' -f2)
    
    if [ "$VERSION" != "$REMOTE_VER" ] && [ "$AUTO_UPDATE" = "true" ]; then
        echo "▶ 새 로직 발견($REMOTE_VER). 기능 업데이트 및 버전 동기화 중..."
        
        # 파일 업데이트
        curl -sSL "$RAW_URL/ui.sh" -o /usr/local/lib/mobile-nas/ui.sh
        curl -sSL "$RAW_URL/services.sh" -o /usr/local/lib/mobile-nas/services.sh
        curl -sSL "$RAW_URL/utils.sh" -o /usr/local/lib/mobile-nas/utils.sh
        curl -sSL "$RAW_URL/nas-start" -o /usr/local/bin/nas-start
        chmod +x /usr/local/bin/nas-start /usr/local/lib/mobile-nas/*.sh
        
        # [중요] 로컬 설정 파일의 버전 번호도 실제 업데이트된 버전으로 교체 (루프 방지)
        sed -i "s/VERSION=\"$VERSION\"/VERSION=\"$REMOTE_VER\"/" /etc/mobile-nas/config.conf
        
        echo "✅ 업데이트 완료! 시스템을 재시작합니다."
        sleep 1
        exec nas-start
    fi
}

# Samba 설정 마법사 (이름표 오류 수정)
run_wizard() {
    echo "▶ 시스템 환경 최적화 중..."
    
    # Samba 설정 파일(smb.conf) 생성
    cat <<EOF > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = $SERVER_NAME
   netbios name = $SERVER_NAME
   security = user
   map to guest = Bad User
   proxy dns = no

[$SHARE_NAME]
   path = $SHARE_PATH
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
   force user = root
EOF
}
