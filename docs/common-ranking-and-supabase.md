# カメレオンJP ブラウザゲーム共通ランキング・Supabase仕様

最終更新: 2026-06-13
対象: `chameleonjp_browser_game_kit` を使って作るスマホ向けブラウザゲーム

## 1. この文書の役割

この文書は、カメレオンJPのスマホ向けブラウザゲームをClaude Codeで作る時に、ランキング連携とSupabase対応を間違えないための共通仕様である。

このリポジトリは、ゲーム本体を置く場所ではない。ゲーム本体は各ゲームの公開リポジトリやCodeberg側に置き、ここでは共通ルール、テンプレート、Claude Code向けの指示を管理する。

実験場トップ、詳細ランキング、現在のゲーム一覧の正本は、次のリポジトリで管理する。

```text
https://github.com/chameleonjp-lab/chameleonjp_lab
```

この文書では、各ゲーム側に入れるべき共通対応を扱う。

## 2. 使い分け

`chameleonjp_browser_game_kit` と `chameleonjp_lab` は役割が違う。

| リポジトリ | 役割 |
|---|---|
| `chameleonjp_browser_game_kit` | 新しいゲームを作る時の共通テンプレート、共通仕様、Claude Code用ルール |
| `chameleonjp_lab` | 実験場トップ、詳細ランキング、登録済みゲーム一覧、実験場側のSupabase連携仕様 |

そのため、このリポジトリには「全ゲーム共通で使う内容」だけを置く。実験場トップ固有の画面仕様や現在の全ゲーム一覧は、`chameleonjp_lab` を見る。

## 3. 基本方針

ゲーム本体は、原則として `index.html` 1ファイルにまとめる。

- HTML、CSS、JavaScriptを1ファイルに入れる。
- npm、Node、ビルドツール、フレームワークは勝手に追加しない。
- 公開先はCodeberg Pagesを基本にする。
- iPhone SE級の小さい画面でも遊べるようにする。
- SQLは、原則としてファイルではなく、チャットにコピペできる形で出す。
- 既存ゲームを修正する時は、ゲーム仕様を勝手に変えない。
- 不明点は「未確認」「要確認」と書く。

## 4. Supabase接続値

ブラウザ側で使う値は次の通り。

```js
const SUPABASE_URL = "https://mlpnjgezrnhdxsxolyzj.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_drzcy0v97knU6FgjqSgBHw_0A9XPdFM";
```

このPublishable keyは公開HTMLに入れてよい前提で扱う。

ただし、次のものは絶対に公開HTMLへ入れない。

- `service_role` key
- DBパスワード
- 秘密鍵
- 管理者用のトークン

## 5. 使うテーブルと関数

ランキング連携では、次を使う。

| 用途 | 名前 |
|---|---|
| ゲーム台帳 | `public.games` |
| スコア保存 | `public.game_scores` |
| スコア送信 | `submit_score` |
| 初回ランキング取得 | `get_first_try_ranking` |
| ベストランキング取得 | `get_best_score_ranking` |
| プレイ回数・参加人数取得 | `get_game_play_stats` |

重要: `public.scores` は使わない。正しくは `public.game_scores`。

## 6. 各ゲームで必ず決める値

各ゲームの `index.html` では、最低限次を決める。

```js
const GAME_SLUG = "ここに_game_slug";
const CLIENT_VERSION = "game_slug_vYYYYMMDD_01";
const GAME_TITLE = "ここにゲーム名";
const GAME_URL = "https://chameleonjp.codeberg.page/ここに_game_slug/";
const LAB_URL = "https://chameleonjp.codeberg.page/chameleonjp_lab/";
```

`GAME_SLUG` は、Supabase `public.games.game_slug` と完全一致させる。

`CLIENT_VERSION` は、修正日や版が分かる名前にする。例は次の通り。

```js
const CLIENT_VERSION = "bekutoru_v20260613_01";
```

## 7. プレイヤー名の共通仕様

ランキング対応ゲームでは、プレイヤー名を必須にする。

- 名前未入力ではゲームを開始しない。
- 空白だけの名前は不可にする。
- 名前は長すぎないようにする。目安は10文字。
- 入力した名前は `localStorage` に保存する。
- 保存キーはゲームごとに分ける。

例:

```js
const NAME_STORAGE_KEY = `chameleonjp_${GAME_SLUG}_player_name`;

function normalizeDisplayName(value) {
  return String(value || "").trim().slice(0, 10);
}

function getSavedDisplayName() {
  return normalizeDisplayName(localStorage.getItem(NAME_STORAGE_KEY));
}

function saveDisplayName(value) {
  const name = normalizeDisplayName(value);
  if (!name) return false;
  localStorage.setItem(NAME_STORAGE_KEY, name);
  return true;
}
```

## 8. スコアの共通仕様

Supabaseへ送るスコアは、内部整数にする。

| ゲーム種別 | 表示例 | 送る整数 | `score_order` | `score_scale` | `score_decimals` |
|---|---:|---:|---|---:|---:|
| 点数が高いほど良い | `12345点` | `12345` | `desc` | 1 | 0 |
| 秒が短いほど良い、小数2桁 | `34.15秒` | `3415` | `asc` | 100 | 2 |
| 秒が短いほど良い、小数3桁 | `1.234秒` | `1234` | `asc` | 1000 | 3 |
| 達成率が高いほど良い | `87%` | `87` | `desc` | 1 | 0 |

ゲーム側が送る整数と、Supabase `public.games` の `score_scale` は必ず合わせる。

例として、ミリ秒を送るタイムゲームでは、Supabase側を次にする。

```text
score_order = asc
score_unit = 秒
score_scale = 1000
score_decimals = 3
```

## 9. 終了時の自動送信

ランキング対応ゲームでは、ゲーム終了時に自動で `submit_score` を呼ぶ。

結果画面に「ランキング登録」ボタンを置き、プレイヤーが押した時だけ送信する形にしてはいけない。

正しい流れは次の通り。

1. ゲームが終了する。
2. 結果画面を出す。
3. 結果画面に「ランキング送信中...」を表示する。
4. `submit_score` を自動で呼ぶ。
5. 成功または失敗を結果画面に出す。

## 10. 二重送信防止

同じ結果を何度も送らないように、送信中・送信済みフラグを持つ。

```js
let scoreSubmitStarted = false;
let scoreSubmitFinished = false;

async function submitGameScore(finalScore) {
  if (scoreSubmitStarted || scoreSubmitFinished) return;

  scoreSubmitStarted = true;
  setRankingStatus("ランキング送信中...");

  const displayName = getSavedDisplayName();
  if (!displayName) {
    scoreSubmitStarted = false;
    setRankingStatus("名前が未入力のため、ランキング送信できませんでした。");
    return;
  }

  if (!supabaseClient) {
    scoreSubmitStarted = false;
    setRankingStatus("Supabaseを読み込めなかったため、ランキング送信できませんでした。");
    return;
  }

  try {
    const score = Math.trunc(Number(finalScore || 0));

    const { error } = await supabaseClient.rpc("submit_score", {
      p_display_name: displayName,
      p_game_slug: GAME_SLUG,
      p_score: score,
      p_client_version: CLIENT_VERSION
    });

    if (error) throw error;

    scoreSubmitFinished = true;
    setRankingStatus("ランキングへ送信しました。");
  } catch (error) {
    console.error("submit_score failed", error);
    setRankingStatus("ランキング送信に失敗しました。通信状態を確認してください。");
  } finally {
    scoreSubmitStarted = false;
  }
}
```

`setRankingStatus` は各ゲーム側で作る。結果画面のランキング送信状態を更新する関数にする。

## 11. Supabaseクライアントの共通コード

HTML内でSupabase JavaScriptクライアントを読み込む。

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

JavaScript側では次のように作る。

```js
const supabaseClient = window.supabase
  ? window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY)
  : null;
```

Supabaseの読み込みに失敗しても、ゲーム自体は遊べるようにする。ランキング送信だけ失敗表示にする。

## 12. 結果画面の共通仕様

結果画面には、最低限次を置く。

| 要素 | 内容 |
|---|---|
| 結果 | 勝敗、クリア、失敗、リタイアなど |
| スコア | 点数、タイム、クリア波数など |
| ランキング送信状態 | 送信中、成功、失敗 |
| もう一度 | 同じゲームを再開 |
| 結果をシェア | 結果文を共有またはコピー |
| ホームへ | ゲーム内ホームへ戻る |
| 他のゲームで遊ぶ | 実験場トップへ移動 |

「ランキング登録」ボタンは置かない。

## 13. シェア文の共通仕様

シェア文には、ゲーム名、結果、URLを入れる。

URLを省略してはいけない。

例:

```js
function buildShareText(resultLabel, scoreText) {
  return `${GAME_TITLE}\n結果: ${resultLabel}\nスコア: ${scoreText}\n${GAME_URL}`;
}

async function shareResult(text) {
  try {
    if (navigator.share) {
      await navigator.share({ text });
      return;
    }
    await navigator.clipboard.writeText(text);
    alert("結果をコピーしました。");
  } catch (error) {
    console.error("share failed", error);
    alert("共有に失敗しました。");
  }
}
```

## 14. 実験場連携

新しいゲームを公開する時は、ゲーム本体だけで完了にしない。

必ず次を確認する。

1. ゲーム本体の `GAME_SLUG` が正しい。
2. ゲーム終了時に `submit_score` で自動送信される。
3. Supabase `public.games` に登録されている。
4. 実験場トップに表示される。
5. 詳細ランキング `ranking.html?game=<game_slug>` が開ける。
6. 初回ランキングとベストランキングの表示が正しい。

実験場側の現行コードに `GAMES` 固定配列が残っている場合、Supabase `public.games` だけ登録しても表示されないことがある。

その場合は、`chameleonjp_lab` 側の仕様を確認し、固定配列とSupabaseの両方がずれないようにする。

## 15. Supabase `public.games` 登録項目

新規ゲームを登録する時は、次を決める。

| 列 | 内容 |
|---|---|
| `game_slug` | ゲームID。`GAME_SLUG` と完全一致 |
| `title` | 実験場に出すゲーム名 |
| `game_url` | 公開URL |
| `description` | 短い説明 |
| `share_text` | 実験場シェア文 |
| `is_active` | 公開するなら `true` |
| `display_order` | 実験場での表示順 |
| `top_ranking_type` | `first` または `best` |
| `score_order` | `desc` または `asc` |
| `score_unit` | `点`、`秒`、`%` など |
| `score_scale` | 表示変換倍率 |
| `score_decimals` | 小数桁 |
| `score_label` | 通常表示名 |
| `first_score_label` | 初回ランキング名 |
| `best_score_label` | ベストランキング名 |
| `release_date` | 公開日 |

## 16. 登録用SQLテンプレート

```sql
insert into public.games (
  game_slug,
  title,
  game_url,
  description,
  share_text,
  is_active,
  display_order,
  top_ranking_type,
  score_order,
  score_unit,
  score_scale,
  score_decimals,
  score_label,
  first_score_label,
  best_score_label,
  release_date
)
values (
  'ここに_game_slug',
  'ここにゲーム名',
  'https://chameleonjp.codeberg.page/ここに_game_slug/',
  'ここに短い説明',
  'ここにゲーム名\nここに短い説明\nhttps://chameleonjp.codeberg.page/ここに_game_slug/',
  true,
  999,
  'best',
  'desc',
  '点',
  1,
  0,
  'スコア',
  '初回スコア',
  '最高スコア',
  '2026-06-13'
)
on conflict (game_slug) do update
set
  title = excluded.title,
  game_url = excluded.game_url,
  description = excluded.description,
  share_text = excluded.share_text,
  is_active = excluded.is_active,
  display_order = excluded.display_order,
  top_ranking_type = excluded.top_ranking_type,
  score_order = excluded.score_order,
  score_unit = excluded.score_unit,
  score_scale = excluded.score_scale,
  score_decimals = excluded.score_decimals,
  score_label = excluded.score_label,
  first_score_label = excluded.first_score_label,
  best_score_label = excluded.best_score_label,
  release_date = excluded.release_date;
```

## 17. 確認用SQL

登録済みゲーム一覧を確認する。

```sql
select
  display_order,
  game_slug,
  title,
  game_url,
  description,
  is_active,
  top_ranking_type,
  score_order,
  score_unit,
  score_scale,
  score_decimals,
  score_label,
  first_score_label,
  best_score_label,
  release_date
from public.games
order by display_order asc, game_slug asc;
```

スコア件数を確認する。

```sql
select
  game_slug,
  count(*) as score_count
from public.game_scores
group by game_slug
order by score_count desc, game_slug asc;
```

RPCが存在するか確認する。

```sql
select
  routine_name,
  routine_type
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
    'submit_score',
    'get_first_try_ranking',
    'get_best_score_ranking',
    'get_game_play_stats'
  )
order by routine_name;
```

## 18. スマホ対応の共通CSS

ゲーム内の誤操作を減らすため、最低限次を入れる。

```html
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
```

```css
html, body {
  margin: 0;
  width: 100%;
  min-height: 100%;
  overflow-x: hidden;
  -webkit-text-size-adjust: 100%;
  overscroll-behavior: none;
}

button, a {
  touch-action: manipulation;
}

.game-root {
  user-select: none;
  -webkit-user-select: none;
  -webkit-touch-callout: none;
}
```

ゲーム内容によっては、画面スクロール、複数指操作、長押しメニューも抑える。
ただし、説明文やリンクなど、コピーや長押しが必要な場所まで無理に潰さない。

## 19. Claude Codeに渡す時の共通指示

Claude Codeに新しいゲームを作らせる時は、次を渡す。

```text
このリポジトリの CLAUDE.md と docs/common-ranking-and-supabase.md を読んでください。
ゲーム本体は index.html 1ファイルで作ってください。
HTML、CSS、JavaScriptを1ファイルにまとめてください。
Supabaseランキング連携は必須です。
プレイヤー名は必須です。
ゲーム終了時に submit_score で自動送信してください。
結果画面に任意のランキング登録ボタンは置かないでください。
同じ結果を二重送信しないでください。
GAME_SLUG は public.games.game_slug と完全一致させてください。
public.scores ではなく public.game_scores を前提にしてください。
新規ゲームの場合は public.games 登録用SQLも出してください。
実験場トップと詳細ランキングで表示される前提で確認してください。
```

## 20. やってはいけないこと

- `public.scores` を使う。
- `service_role` キーを公開HTMLに入れる。
- `GAME_SLUG` と `public.games.game_slug` をずらす。
- 名前未入力でランキング送信する。
- 結果画面に任意の「ランキング登録」ボタンを置く。
- 二重送信防止を入れない。
- 秒系ゲームで `score_scale` を設定しない。
- `score_order` を逆にする。
- Supabase送信失敗でゲーム結果画面まで消す。
- 実験場側に固定配列が残っているか確認せず、Supabase登録だけで完了扱いにする。
- GitHubに細かい更新を何度も連続で行う。

## 21. 完了条件

ランキング対応ゲームは、次を満たしたら完了とする。

1. iPhone SE級の画面で遊べる。
2. 名前未入力では開始できない。
3. ゲーム終了時に自動送信される。
4. 結果画面に送信状態が出る。
5. 同じ結果が二重送信されない。
6. Supabase `game_scores` に記録が入る。
7. 実験場トップに表示される。
8. 詳細ランキングに表示される。
9. シェア文にゲームURLが入る。
10. 既存仕様を壊していない。
