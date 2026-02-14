#!/bin/sh

GITHUB_USER="Chromegun"
REPO="Mobile-NAS"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO/main"

echo "=========================================="
echo "    🚀 Mobile NAS 지능형 설치 마법사"
echo "=========================================="

# 1. 시스템 폴더 구성
mkdir -p /etc/mobile-nas /usr/local/lib/mobile-nas

# 2. 사용자 설정 입력 (파이프 환경 대응)
echo "▶ 1. 환경 설정을 입력해주세요. (엔터 치면 기본값 사용)"
DEFAULT_PATH="/home/storage"
DEFAULT_NAME="Mobile-Storage"

# /dev/tty를 사용해야 curl | bash 환경에서도 키보드 입력을 제대로 받습니다.
printf "   - 공유 폴더 경로 (기본: $DEFAULT_PATH): "
read USER_PATH < /dev/tty
USER_PATH=${USER_PATH:-$DEFAULT_PATH}

printf "   - 네트워크 이름 (기본: $DEFAULT_NAME): "
read USER_NAME < /dev/tty
USER_NAME=${USER_NAME:-$DEFAULT_NAME}

# 3. 설정 파일 생성 (실제 값만 깔끔하게 주입)
echo "▶ 2. 설정 파일(config.conf) 생성 중..."
cat <<EOT > /etc/mobile-nas/config.conf
VERSION="1.1.2"
SERVER_NAME="Mobile-NAS"
SHARE_PATH="$USER_PATH"
SHARE_NAME="$USER_NAME"
SOCKS_PORT="1055"
AUTO_UPDATE="true"
EOT

# 4. 패키지 및 로직 배포
echo "▶ 3. 필수 패키지 확인 및 최신 모듈 다운로드..."
apt update && apt install -y curl samba tailscale net-tools > /dev/null 2>&1

# 깃허브에서 최신 로직들 가져오기
for file in ui.sh services.sh utils.sh; do
    curl -sSL "$RAW_URL/$file" -o "/usr/local/lib/mobile-nas/$file"
done
curl -sSL "$RAW_URL/nas-start" -o "/usr/local/bin/nas-start"

# 5. 권한 부여 및 폴더 준비
chmod +x /usr/local/bin/nas-start
chmod +x /usr/local/lib/mobile-nas/*.sh
mkdir -p "$USER_PATH"
chmod -R 777 "$USER_PATH"

# [수정 완료] 최종 출력부
echo ""
echo "=========================================="
echo "    ✅ 맞춤형 설치가 완료되었습니다!"
echo "    설정 경로: $USER_PATH"
echo "    서버 이름: $USER_NAME"
echo "    명령어: nas-start"
echo "=========================================="
