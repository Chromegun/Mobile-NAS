#!/bin/sh

# Chromegun님의 저장소 정보
GITHUB_USER="Chromegun"
REPO="Mobile-NAS"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO/main"

echo "=========================================="
echo "    🚀 Mobile NAS 지능형 통합 설치 시스템"
echo "=========================================="

# 1. 시스템 폴더 구성
echo "▶ 1. 시스템 구조 형성 중..."
mkdir -p /etc/mobile-nas /usr/local/lib/mobile-nas

# 2. 필수 패키지 설치 (무결성 기초 작업)
echo "▶ 2. 필수 패키지 확인 및 설치 중..."
apt update && apt install -y locales fonts-nanum psmisc net-tools curl samba tailscale > /dev/null 2>&1
locale-gen ko_KR.UTF-8 > /dev/null 2>&1

# 3. 깃허브에서 모든 모듈 다운로드 (utils.sh 포함!)
echo "▶ 3. 최신 모듈 배포 중 (utils.sh 포함)..."
curl -sSL "$RAW_URL/config.conf" -o /etc/mobile-nas/config.conf
curl -sSL "$RAW_URL/ui.sh" -o /usr/local/lib/mobile-nas/ui.sh
curl -sSL "$RAW_URL/services.sh" -o /usr/local/lib/mobile-nas/services.sh
curl -sSL "$RAW_URL/utils.sh" -o /usr/local/lib/mobile-nas/utils.sh
curl -sSL "$RAW_URL/nas-start" -o /usr/local/bin/nas-start

# 4. 권한 부여
echo "▶ 4. 실행 권한 설정 및 최적화..."
chmod +x /usr/local/bin/nas-start
chmod +x /usr/local/lib/mobile-nas/*.sh

echo ""
echo "=========================================="
echo "    ✅ 모든 기능이 탑재된 설치가 완료되었습니다!"
echo "    명령어: nas-start"
echo "    로그 확인: nas-start log"
echo "    설정 마법사: nas-start wizard"
echo "=========================================="
