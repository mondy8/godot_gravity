#!/usr/bin/env bash
# 整形チェック + lint をまとめて実行する (コミット前 / CI 用)。
# 片方が落ちても両方の結果を出したうえで非ゼロ終了する。
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

echo "=== gdformat --check ==="
"$PROJECT_DIR/tools/gdformat.sh" --check || status=1

echo
echo "=== gdlint ==="
"$PROJECT_DIR/tools/gdlint.sh" || status=1

echo
if [ "$status" -eq 0 ]; then
	echo "OK: 整形済み・lintエラーなし"
else
	echo "NG: './tools/gdformat.sh' で整形し、残った指摘を修正してください (ログ: logs/)"
fi
exit "$status"
