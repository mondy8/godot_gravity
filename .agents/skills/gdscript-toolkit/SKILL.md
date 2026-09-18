---
name: gdscript-toolkit
description: "GDScript の整形・静的解析 (gdtoolkit 4.x: gdformat / gdlint / gdparse) の運用ルール。.gd を編集した後、コミット前、CI での検証時に使用する。"
---

本プロジェクトの GDScript は [godot-gdscript-toolkit](https://github.com/Scony/godot-gdscript-toolkit) (gdtoolkit 4.x) で
整形・静的解析する。Godot 4.7 / gdtoolkit 4.5.0 で動作確認済み。

Scope:
- `.gd` ファイルのみ (`.tscn` / `.tres` は対象外 — `headless-godot` スキップを参照)
- 除外: `.git/` `.godot/` `.import/` `.agents/` `addons/`

必須ルール (最優先):
- `.gd` を編集したら `./tools/gdformat.sh` を実行してから作業を終える (手で整形しない)
- コミット前・CI では `./tools/gdcheck.sh` を実行し、終了コード 0 を確認する
- gdformat/gdlint は必ず `tools/*.sh` 経由で実行する (対象ファイルの列挙と `gdlintrc` の解決を一元化しているため)
- lint ルールを変更するときは `gdlintrc` を編集する。個別行の抑制は `# gdlint:ignore = <rule>` を前行に置く
- 設定ファイル名は `gdlintrc` (先頭にドットを付けた `.gdlintrc` は読み込まれない)
- gdformat は AST 一致のセーフティチェック付きで書き戻す。`--fast` はセーフティチェックを飛ばすので使わない

コマンド:
```
./tools/gdformat.sh            # 整形 (書き換えあり)
./tools/gdformat.sh --check    # 差分チェックのみ (CI 向け)
./tools/gdformat.sh --diff     # 差分表示
./tools/gdlint.sh              # 静的解析
./tools/gdcheck.sh             # --check + lint をまとめて実行
```
ログは `logs/gdformat.log` / `logs/gdlint.log` に出力される (git 管理外)。

インストール (未導入の環境):
```
brew install gdtoolkit                 # macOS
pipx install "gdtoolkit==4.*"          # その他 (Godot 4.x 系には gdtoolkit 4.x を使う)
```

整形スタイル (gdformat のデフォルト、変更不可の部分が多い):
- インデントはタブ、1行 100 文字
- コメントは折り返されないため、長い URL は自前で改行する

`gdlintrc` の方針:
- 既存コードのスタイルを尊重し、整形後にエラー 0 で通る状態を基準にしている
- camelCase のメンバ変数を許容するため命名規則の正規表現を緩めている
- `class-definitions-order` / `unused-argument` / `no-else-return` / `no-elif-return` / `max-returns` は無効化済み
- 厳しくしたい場合は disable を 1 つずつ外し、該当箇所を順次修正する

Out of scope:
- `.tscn` の編集・検証、ヘッドレス実行、エクスポート → `headless-godot` スキルを使う
- 型付けの追加やリファクタリングなどの意味論的な変更 (gdformat は挙動を変えない)
