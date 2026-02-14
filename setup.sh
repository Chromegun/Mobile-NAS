#!/bin/sh
# Chromegun님의 저장소 설정
GITHUB_USER="Chromegun"
REPO="Mobile-NAS"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO/main"

echo "=========================================="
echo "    🚀 Mobile NAS 통합 설치 시스템"
echo "=========================================="
echo "▶ 1. 시스템 폴더 구성 및 패키지 설치..."
mkdir -p /etc/mobile-nas /usr/local/lib/mobile-nas
apt update && apt install -y locales fonts-nanum psmisc net-tools curl > /dev/null 2>&1
locale-gen ko_KR.UTF-8 > /dev/null 2>&1
echo "▶ 2. 깃허브에서 모듈 다운로드..."
curl -sSL "$RAW_URL/config.conf" -o /etc/mobile-nas/config.conf
curl -sSL "$RAW_URL/ui.sh" -o /usr/local/lib/mobile-nas/ui.sh
curl -sSL "$RAW_URL/services.sh" -o /usr/local/lib/mobile-nas/services.sh
curl -sSL "$RAW_URL/nas-start" -o /usr/local/bin/nas-start
echo "▶ 3. 권한 설정 완료..."
chmod +x /usr/local/bin/nas-start
chmod +x /usr/local/lib/mobile-nas/*.sh
echo "\n ✅ 설치 완료! 이제 'nas-start'를 입력하세요."
