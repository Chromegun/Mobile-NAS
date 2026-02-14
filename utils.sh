#!/bin/sh

# [수정] nas-start가 찾는 이름으로 통일
samba_wizard() {
    echo "▶ Samba 환경 설정 최적화 중..."
    
    # 변수가 비어있을 경우를 대비한 안전장치 (기본값 설정)
    local PATH_FINAL="${SHARE_PATH:-/home/storage}"
    local NAME_FINAL="${SHARE_NAME:-Mobile-Storage}"
    local SERVER_FINAL="${SERVER_NAME:-Mobile-NAS}"

    # Samba 설정 파일 생성
    cat <<EOF > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = $SERVER_FINAL
   netbios name = $SERVER_FINAL
   security = user
   map to guest = Bad User
   proxy dns = no

[$NAME_FINAL]
   path = $PATH_FINAL
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
   force user = root
EOF
    # 설정 반영을 위해 서비스 재시작
    service smbd restart > /dev/null 2>&1
}

# (기타 auto_update 등의 함수는 그대로 유지)
