#!/usr/bin/env bash
# 対象となる .gd ファイルを NUL 区切りで列挙する共通ヘルパ。
# 単体でも実行可能: ./tools/gdscript_files.sh | tr '\0' '\n'
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find "$PROJECT_DIR" \
	-type d \( -name '.git' -o -name '.godot' -o -name '.import' -o -name '.agents' -o -name 'addons' \) -prune -o \
	-type f -name '*.gd' -print0
