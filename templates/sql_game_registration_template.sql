-- このファイルは保管用テンプレートです。
-- 実際にユーザーへ渡すSQLは、ファイルではなくチャットにコピペできる形で出してください。

insert into public.games (
  display_order,
  game_slug,
  title,
  game_url,
  description,
  share_text,
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
) values (
  999,
  'replace_game_slug',
  'replace_title',
  'https://chameleonjp.codeberg.page/replace_game_slug/',
  'replace_description',
  'replace_share_text',
  true,
  'best',
  'desc',
  '点',
  1,
  0,
  'スコア',
  '初回スコア',
  '最高スコア',
  current_date
)
on conflict (game_slug) do update set
  display_order = excluded.display_order,
  title = excluded.title,
  game_url = excluded.game_url,
  description = excluded.description,
  share_text = excluded.share_text,
  is_active = excluded.is_active,
  top_ranking_type = excluded.top_ranking_type,
  score_order = excluded.score_order,
  score_unit = excluded.score_unit,
  score_scale = excluded.score_scale,
  score_decimals = excluded.score_decimals,
  score_label = excluded.score_label,
  first_score_label = excluded.first_score_label,
  best_score_label = excluded.best_score_label,
  release_date = excluded.release_date;
