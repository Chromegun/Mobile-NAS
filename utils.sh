#!/bin/sh

# [필수] 자동 업데이트 및 버전 동기화 함수
auto_update() {
    # 깃허브의 최신 버전 정보 가져오기
    REMOTE_VER=$(curl -sSL "$RAW_URL/config.conf.default" | grep "VERSION=" | cut -d'"' -f2)
    
    if [ "$VERSION" != "$REMOTE_VER" ] && [ "$AUTO_UPDATE" = "true" ]; then
        echo "▶ 새 로직 발견($REMOTE_VER). 기능 업데이트 중..."
        
        # 최신 로직 파일들만 다운로드
        curl -sSL "$RAW_URL/ui.sh" -o /usr/local/lib/mobile-nas/ui.sh
        curl -sSL "$RAW_URL/services.sh" -o /usr/local/lib/mobile-nas/services.sh
        curl -sSL "$RAW_URL/utils.sh" -o /usr/local/lib/mobile-nas/utils.sh
        curl -sSL "$RAW_URL/nas-start" -o /usr/local/bin/nas-start
        chmod +x /usr/local/bin/nas-start /usr/local/lib/mobile-nas/*.sh
        
        # 로컬 설정 파일의 버전 번호 갱신 (무한 루프 방지 핵심!)
        sed -i "s/VERSION=\"$VERSION\"/VERSION=\"$REMOTE_VER\"/" /etc/mobile-nas/config.conf
        
        echo "✅ 업데이트 완료! 시스템을 재시작합니다."
        sleep 1
        exec nas-start
    fi
}

# Samba 설정 마법사 (탐색기 이름 오류 수정본)
samba_wizard() {
    echo "▶ Samba 환경 설정 최적화 중..."
    cat <<EOF > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = ${SERVER_NAME:-Mobile-NAS}
   netbios name = ${SERVER_NAME:-Mobile-NAS}
   security = user
   map to guest = Bad User

[${SHARE_NAME:-Mobile-Storage}]
   path = ${SHARE_PATH:-/home/storage}
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
   force user = root
EOF
}
