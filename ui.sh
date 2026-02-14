#!/bin/sh
BAR_WIDTH=40
draw_line() { printf " %60s \n" " " | tr " " "="; }
init_ui() { clear; tput civis; }
close_ui() { tput cnorm; }
draw_screen() {
    tput cup 0 0
    echo ""
    draw_line
    printf " %-58s \n" "      🚀 $SERVER_NAME 가동 시스템"
    draw_line
    echo "\n  현재 진행 상태:"
    local filled=$(($1 * BAR_WIDTH / 100))
    local empty=$((BAR_WIDTH - filled))
    printf "  ["
    for i in $(seq 1 $filled); do printf "#"; done
    for i in $(seq 1 $empty); do printf "-"; done
    printf "] %d%%\n\n" "$1"
    printf "  ▶ 작업 내용: %-40s\n\n" "$2"
    draw_line
}
