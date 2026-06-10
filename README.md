# chameleonjp_browser_game_kit

カメレオンJPのスマホ向けブラウザゲームを、Claude Codeで制作・修正・デバッグするための共通テンプレート集です。

このリポジトリは公開ゲーム本体ではありません。各ゲームの `index.html` を置く場所ではなく、共通ルール、仕様書テンプレート、Claude Code用のskills、agents、settingsを管理します。

## 使い方

1. 新しいゲーム用リポジトリを作る。
2. このリポジトリの `CLAUDE.md`、`docs/`、`.claude/` を必要に応じてコピーする。
3. ゲーム固有の仕様は、各ゲームリポジトリの `docs/game-spec.md` に書く。
4. 公開正本は常に `index.html` にする。

## 標準方針

- HTML、CSS、JavaScriptは原則1ファイルにまとめる。
- 公開先はCodeberg Pagesを基本にする。
- ランキングはSupabase連携を基本にする。
- iPhone SE級の画面でも遊べることを必須にする。
- SQLはファイルではなく、チャットにコピペできる形式で出す。
- 古いコードを参照できるよう、途中版は `index_v2.html`、`index_v3.html` のように名前を変える。

## 含まれるもの

- `CLAUDE.md`: Claude Code用の共通指示
- `docs/`: 仕様書とチェックリスト
- `templates/`: 最小HTMLやランキング対応HTMLの雛形
- `.claude/skills/`: 作業別skill
- `.claude/agents/`: レビュー用subagent
