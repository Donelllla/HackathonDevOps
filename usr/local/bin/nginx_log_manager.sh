#!/bin/bash
LOG_DIR="/var/log/nginx_log_manager"
mkdir -p "$LOG_DIR"

MAIN_LOG="$LOG_DIR/main.log"
CLEANUP_LOG="$LOG_DIR/cleanups.log"
ERROR_4XX="$LOG_DIR/4xx_errors.log"
ERROR_5XX="$LOG_DIR/5xx_errors.log"

NGINX_LOGS=(
    "/var/log/nginx/access.log"
    "/var/log/nginx/error.log"
    "/var/log/access.log"
    "/var/log/error.log"
)

for log in "${NGINX_LOGS[@]}"; do
    if [ -f "$log" ]; then
        NGINX_LOG="$log"
        break
    fi
done

[ -z "$NGINX_LOG" ] && { echo "No NGINX logs found!" >&2; exit 1; }


cleanup_main_log() {
    local line_count=$(sed -n '$=' "$MAIN_LOG" 2>/dev/null)
    echo "$(date) - Cleaned main.log. Removed $line_count lines." >> "$CLEANUP_LOG"
    > "$MAIN_LOG"
}

while true; do
    tail -n 10 "$NGINX_LOG" 2>/dev/null >> "$MAIN_LOG"

    if [ $(stat -c%s "$MAIN_LOG" 2>/dev/null) -gt 307200 ]; then
        cleanup_main_log
    fi
    # 4xx ошибки
    sed -n '/HTTP\/[0-9.]\+" [4][0-9][0-9]/p' "$NGINX_LOG" 2>/dev/null | tail -n 5 >> "$ERROR_4XX"

    # 5xx ошибки
    awk '$9 ~ /^5[0-9]{2}$/{print}' "$NGINX_LOG" 2>/dev/null | tail -n 5 >> "$ERROR_5XX"

    if [[ "$NGINX_LOG" == *error.log* ]]; then
        grep -E '\[error\]|\[crit\]' "$NGINX_LOG" | awk '{print}' >> "$ERROR_5XX"
    fi

    sleep 5
done
