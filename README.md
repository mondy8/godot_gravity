[Godot Engine](https://godotengine.org/)で作成したブラウザゲーム「SOシーソー！」のソースコードです。

プレイは[こちらから](https://godotplayer.com/games/soseesaw)

## 開発

GDScript の整形・静的解析には [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) (gdformat / gdlint) を使用しています。

```sh
brew install gdtoolkit   # 未導入の場合 (pipx install "gdtoolkit==4.*" でも可)

./tools/gdformat.sh      # .gd を整形
./tools/gdlint.sh        # 静的解析
./tools/gdcheck.sh       # 整形チェック + 静的解析 (コミット前 / CI 用)
```

lint のルールは `gdlintrc` で設定しています。
