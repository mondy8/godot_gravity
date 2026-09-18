# SOシーソー！

シーソートーナメント開幕！
10人のライバルたちを蹴散らして、シーソーバトルに勝利しよう！

[Godot Engine](https://godotengine.org/)で作成したブラウザゲーム「SOシーソー！」のソースコードです。

プレイは[こちらから](https://godotplayer.com/games/soseesaw)

## ルール

- ライバルを下に落とせば勝利します。
- LEVEL10を超えることができればクリアです。
- 重力を駆使してシーソーチャンピオンを目指しましょう！

## 操作方法

| キー | 操作 |
| --- | --- |
| WASD / 十字キー | プレイヤーを操作 |
| 上キー | ジャンプ |
| 左右キーを二回連続 | ダッシュ |
| ジャンプ中に下キー | 特殊技「ヒップドロップ」 |
| Escキー | ポーズ / 音量設定 |
| Enterキー | ボタンの選択 |

ゲームパッドにも対応しています（左スティックで移動、Aボタンで決定）。

## 開発

GDScript の整形・静的解析には [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) (gdformat / gdlint) を使用しています。

```sh
brew install gdtoolkit   # 未導入の場合 (pipx install "gdtoolkit==4.*" でも可)

./tools/gdformat.sh      # .gd を整形
./tools/gdlint.sh        # 静的解析
./tools/gdcheck.sh       # 整形チェック + 静的解析 (コミット前 / CI 用)
```

lint のルールは `gdlintrc` で設定しています。
