# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Godot Engine 4.7 製のブラウザゲーム「SOシーソー！」。物理演算（`RigidBody2D` とシーソー）で
相手を場外に落とす対戦ゲームで、LEVEL1〜10 のトーナメント形式。コード内コメントは日本語。

## 大前提: 人間が Godot エディタで触る

このリポジトリは**作者が Godot エディタを開いて実装・調整を続けること**が前提。
エージェントの都合でエディタ上の扱いづらさを持ち込まない。

- シーン構造・ノード階層はエディタ上で読める形を保つ。スクリプトからの動的生成に寄せ替えない
- 調整したい数値（速度・力・タイマー等）は `@export` にしてインスペクタから触れるようにする。
  マジックナンバーをスクリプト奥深くに埋めない
- `.tscn` / `.tres` を**テキストとして手編集しない**（後述の headless スキル経由か、作者がエディタで行う）
- ノード名・`unique_id`・シグナル接続を不用意に組み替えない。エディタで接続済みのシグナルは
  コード側での再接続に置き換えない
- 既存のフォルダ構成・命名（`scenes/main/Enemy_NN_*.gd` など）を踏襲する。
  リファクタリングで一括改名するときは必ず事前に相談する
- 大きな変更は「エディタで開いて動かして確認できる」粒度に分割する
- ビルド／エクスポートは作者が手動で行う。エージェントは実行しない（後述）

## コマンド

### GDScript の整形 / 静的解析

`.gd` を編集したら必ず実行する（詳細は `.agents/skills/gdscript-toolkit/SKILL.md`）。

```sh
./tools/gdformat.sh            # 整形 (書き換えあり)
./tools/gdformat.sh --check    # 差分チェックのみ
./tools/gdlint.sh              # 静的解析 (ルールは gdlintrc)
./tools/gdcheck.sh             # --check + lint。コミット前にこれが exit 0 であること
```

### ゲームの実行・検証

ゲームの実行には [headless-godot-skill-kit](https://github.com/abagames/headless-godot-skill-kit)
を使用する。本リポジトリには `.agents/skills/headless-godot/` として取り込み済みで、
**実行とシーン編集は必ずこのスキルの手順に従う**（`SKILL.md` と `skills/*.md` を読むこと）。
ただし**エクスポートだけは行わない**（後述）。

```sh
# 起動スモーク (run/main_scene を実際に起動して _ready のエラーを検出)
mkdir -p logs && timeout 5s godot --headless --path . 2>&1 | tee logs/smoke_main.log

# ロジックテスト (res://tools/tests/run_tests.gd。無ければスキルの
# .agents/skills/headless-godot/tools/templates/run_tests.gd から作る)
godot --headless --path . --script res://tools/tests/run_tests.gd 2>&1 | tee logs/run_tests.log

# .tscn の編集はスクリプト経由 (patch.json → godot_apply_patch.gd)
# 詳細は .agents/skills/headless-godot/skills/scene_editing_via_godot.md
```

- 常に `--headless --path <PROJECT_DIR>` を付け、出力は `logs/` に `tee` する（`logs/` は git 管理外）
- `user://` や `~/.cache` が書けない環境では XDG を project-local に向ける
  （`XDG_DATA_HOME` / `XDG_CONFIG_HOME` / `XDG_CACHE_HOME`、`headless_cli.md` 参照）
- `--script` で走らせるスクリプトは `SceneTree` / `MainLoop` を継承し、必ず `quit(0|1)` する
- 終了時の `ObjectDB instances were leaked` / `resources still in use` は既知の警告。
  終了コードが 0 で期待した出力があれば失敗扱いにしない

### エクスポート: **実行しない**

エクスポートは作者が手動で行う。エージェントは**エクスポートを実行してはいけない**。

- `--export-release` / `--export-debug` / `--export-pack` を実行しない
- 「変更の確認」目的でエクスポートしない。確認は上記の起動スモークとロジックテストで済ませる
- `export_presets.cfg`（Web(HTML5) / Windows / Linux / macOS）と `output/` を書き換えない
- headless-godot スキルの `skills/export_and_import.md` にエクスポート手順があるが、
  **本リポジトリではエクスポート部分は適用外**。import（`--import` によるリソース取り込み）は必要に応じて可
- エクスポートが必要だと判断した場合は、自分で実行せず作者に依頼する

## アーキテクチャ

### Autoload（`project.godot` の `[autoload]`）

- `Global` (`scenes/main/Global.gd`) — 実行時のゲーム状態のほぼ全て。`current_level`、`player_hp` /
  `enemy_hp`、`time`、`death_number` など。レベル間・シーン間の受け渡しは基本ここ経由。
  リセットは `init_level()` / `init_game()`
- `UserSettings` (`settings/user_settings.gd`) — 音量・ミュート・ロケールを `user://settings.cfg`
  (`ConfigFile`) に保存し、オーディオバス（Master / Music / Sound）と `TranslationServer` に反映。
  変更は `on_value_change(key, value)` シグナルで通知

### シーン遷移

`bootsplash_scene` → `main_menu_scene` → `ingame_scene`（または `practice_scene` / `game_settings_scene`）
→ `Ending` → メニュー。遷移はいずれも `ui/overlays/fade_overlay.tscn` のフェード完了シグナル `on_complete_fade_out` を
受けた `_on_fade_overlay_on_complete_fade_out()` の中で `change_scene_to_*()` を呼ぶ形。
新しい遷移を足すときもこのパターンに合わせる。

### バトルの中心: `scenes/main/Level01.gd`

`ingame_scene.tscn` に `Level01` がインスタンスされ、ここが1試合の司令塔。

- `Global.current_level` を見て 10 体の敵シーンから1体を instantiate し、立ち絵・煽り文
  (`subTextsArray` / `characterNameArray`) を選ぶ
- Player / Enemy から以下のシグナルを受けて試合を進行する。**この3つが Player・Enemy 共通の契約**:
  - `seesaw_collided(collided_position, impulse)` → シーソーへ `apply_impulse()`
  - `game_set(loser)` → HP 減算・リスポーン・勝敗判定
  - `camera_shake(duration, magnitude)` → カメラ演出
- 残機ありのリスポーンは `PhysicsServer2D.body_set_state(..., BODY_STATE_TRANSFORM, ...)` で
  `RigidBody2D` を移動する（`position` への直接代入ではない。根拠リンクはコード内コメント参照）

### Player / Enemy

- `scenes/main/Player.gd` — `RigidBody2D`。左右キーの連打間隔（`dash_interval` /
  `MOVE_FAST_LIMIT`）でダッシュ、ジャンプ中の下キーでヒップドロップ。入力は
  `input_process()` が力ベクトルを返す形に集約されている
- `scenes/main/Enemy.gd` — `class_name Enemy` の基底。接地判定は足元2本の `RayCast2D`。
  `Enemy_01`〜`Enemy_10` は各々が独立したスクリプトで AI を持ち、基底と同じシグナルを発する
- `Player_pracitce.gd` / `Enemy_practice.gd` は `practice_scene` 用の別系統。
  本編側と重複したコードがあるので、片方を直したらもう片方も確認する
  （ファイル名の綴りも既存のまま。改名はエディタ側の参照を壊すため相談してから）

### その他

- セーブ: `savegame/save_game.gd`（`class_name SaveGame`、static メソッド群）。`Persist` グループの
  ノードを集めて `user://savegame.save` に保存、リリースビルドは暗号化
- 多言語: `i18n/translation.csv`（en / de）。表示文字列は翻訳キー経由が基本
- 画面サイズは `Global.SCREEN_WIDTH` / `SCREEN_HEIGHT` 定数と各スクリプトのローカル値が
  混在している。座標計算を足すときは `Global` の定数を使う

## 既知の問題

- `scenes/ingame_scene.tscn` は組み込みスクリプト（`[sub_resource type="GDScript"]`）を持ち、
  そこに `class_name ingame` があるため起動時に
  `Parse Error: "class_name" isn't allowed in built-in scripts.` が出る。
  既存の問題であり、直すなら外部 `.gd` への切り出しが必要（エディタ作業向き）
