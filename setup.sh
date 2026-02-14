#!/bin/sh

GITHUB_USER="Chromegun"
REPO="Mobile-NAS"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO/main"

echo "=========================================="
echo "    🚀 Mobile NAS 지능형 설치 마법사"
echo "=========================================="

# 1. 시스템 폴더 구성
mkdir -p /etc/mobile-nas /usr/local/lib/mobile-nas

# 2. 사용자 설정 입력 (대화형)
echo "▶ 1. 기본 환경 설정을 시작합니다."
# 기존 설정이 있으면 불러오고, 없으면 기본값 제안
DEFAULT_PATH="/home/storage"
DEFAULT_NAME="Mobile-Storage"

printf "   - 공유 폴더 경로 입력 (기본값: $DEFAULT_PATH): "
read USER_PATH
USER_PATH=${USER_PATH:-$DEFAULT_PATH}

printf "   - 네트워크 표시 이름 입력 (기본값: $DEFAULT_NAME): "
read USER_NAME
USER_NAME=${USER_NAME:-$DEFAULT_NAME}

# 3. 설정 파일 생성 (입력값 반영)
echo "▶ 2. 설정 파일(config.conf) 생성 중..."
cat <<EOT > /etc/mobile-nas/config.conf
# Mobile NAS 사용자 맞춤 설정
VERSION="1.1.2"
SERVER_NAME="Mobile-NAS"
SHARE_PATH="$USER_PATH"
SHARE_NAME="$USER_NAME"
SOCKS_PORT="1055"
AUTO_UPDATE="true"
EOT

# 4. 필수 패키지 및 모듈 배포
echo "▶ 3. 필수 패키지 확인 및 최신 모듈 다운로드..."
apt update && apt install -y curl samba tailscale net-tools > /dev/null 2>&1

curl -sSL "$RAW_URL/ui.sh" -o /usr/local/lib/mobile-nas/ui.sh
curl -sSL "$RAW_URL/services.sh" -o /usr/local/lib/mobile-nas/services.sh
curl -sSL "$RAW_URL/utils.sh" -o /usr/local/lib/mobile-nas/utils.sh
curl -sSL "$RAW_URL/nas-start" -o /usr/local/bin/nas-start

# 5. 권한 부여 및 마무릿
chmod +x /usr/local/bin/nas-start
chmod +x /usr/local/lib/mobile-nas/*.sh

# 설정된 경로 실제 생성
mkdir -p "$USER_PATH"
chmod -R 777 "$USER_PATH"

echo ""
echo "=========================================="
echo "    ✅ 맞춤형 설치가 완료되었습니다!"
echo "    설정 경로: $USER_PATH"
echo "    명령어: nas-start"
echo "=========================================="
