#!/usr/bin/env bash
# gdlint (gdtoolkit) でプロジェクト内の .gd を静的解析する。
# ルールはプロジェクト直下の gdlintrc を参照する。
#
#   ./tools/gdlint.sh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

command -v gdlint >/dev/null 2>&1 || {
	echo "gdlint が見つかりません。'brew install gdtoolkit' または 'pipx install \"gdtoolkit==4.*\"' を実行してください。" >&2
	exit 127
}

# gdlintrc は「カレントディレクトリ」を基点に探索されるため、必ずプロジェクト直下で実行する
cd "$PROJECT_DIR"

set -o pipefail
"$PROJECT_DIR/tools/gdscript_files.sh" \
	| xargs -0 gdlint "$@" 2>&1 \
	| tee "$LOG_DIR/gdlint.log"
