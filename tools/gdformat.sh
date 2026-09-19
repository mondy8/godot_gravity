#!/usr/bin/env bash
# gdformat (gdtoolkit) でプロジェクト内の .gd を整形する。
#
#   ./tools/gdformat.sh            # その場で整形
#   ./tools/gdformat.sh --check    # 変更せず、差分があれば非ゼロ終了 (CI向け)
#   ./tools/gdformat.sh --diff     # 変更せず、差分を表示
#
# 設定は gdformat のデフォルト (タブインデント / 100桁) を使用。
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

command -v gdformat >/dev/null 2>&1 || {
	echo "gdformat が見つかりません。'brew install gdtoolkit' または 'pipx install \"gdtoolkit==4.*\"' を実行してください。" >&2
	exit 127
}

set -o pipefail
"$PROJECT_DIR/tools/gdscript_files.sh" \
	| xargs -0 gdformat "$@" 2>&1 \
	| tee "$LOG_DIR/gdformat.log"
