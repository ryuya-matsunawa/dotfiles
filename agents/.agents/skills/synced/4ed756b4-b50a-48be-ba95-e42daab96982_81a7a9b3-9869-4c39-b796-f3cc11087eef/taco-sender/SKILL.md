---
name: taco-sender
description: "Slack上でタコスを送るスキル。今日のSlack発言から感謝・称賛を抽出し、taco-book / taco-general への投稿候補をインタラクティブUIで表示、選択したものを5分後のスケジュール送信として予約投稿する。「タコス」「taco」「taco送って」「タコス送りたい」「今日のタコス」「taco-book」などのキーワードで発動する。毎日の終わりに使うことを想定。"
---

# Taco Sender スキル

WEDのSlack文化「タコス」を送るためのスキル。ユーザーの指定日のSlack発言から感謝・称賛の要素を抽出し、taco-book / taco-general への投稿候補を生成する。

## 前提知識

### チャンネルと使い分け
- **#taco-book** (C026RPX4GN6): Values / Competenciesの体現への称賛。詳細に体現内容を記載し、ハッシュタグを付ける
- **#taco-general** (C026RUXJF27): 毎日のありがとうを伝えるタコス。カジュアルでOK

### 投稿フォーマット
```
@メンション名
メッセージ本文:taco:
#ハッシュタグ1 #ハッシュタグ2
```

### ユーザー情報（実行時に自動取得）
- ユーザーのSlack ID: スキル実行開始時に `slack_read_user_profile`（user_id未指定）を呼び出し、現在のユーザーのSlack IDを自動取得する。以降のステップではこのIDを使用する
- 口調: 全体発信として適切なトーン。丁寧だが堅すぎない（「ありがとうございます」ベース。「ありがとう！」は砕けすぎ、「誠に感謝申し上げます」は堅すぎ）

### ハッシュタグ
`references/values-and-tags.md` を参照して、発言内容に最も合うCompetenciesのハッシュタグを1〜2個自動選定する。

---

## 実行フロー

### 事前処理: 対象日の確認とユーザーのSlack ID取得

**1. 対象日の確認**
スキル呼び出し直後に、`ask_user_input_v0` を使って対象日を確認する。

```
質問: いつの分のタコス候補を出しますか？
選択肢: ["今日", "昨日", "日付を指定する"]
```

- 「今日」「昨日」が選ばれた場合はそのまま対象日を確定
- 「日付を指定する」が選ばれた場合は、テキストで日付を入力してもらう（例: 5/26、2026-05-26 など）
- 確定した対象日を以降の全ステップ（カレンダー取得、Slack検索のタイムスタンプ範囲）に使用する

**2. ユーザーのSlack ID取得**
`slack_read_user_profile`（user_id未指定）を呼び出し、現在のユーザーのSlack IDと表示名を取得する
- Slackが未連携の場合: `search_mcp_registry` → `suggest_connectors` でSlack連携を提案。Slackなしではこのスキルは動作しないため、連携を促して終了する

取得したSlack IDを以降の全ステップで使用する。

### Step 0: 対象日のMTGを表示（スキップ可能）

まず Google Calendar APIの `list_events` を呼び出し、対象日のイベントの取得を試みる。

**Google Calendar未連携の場合:**
API呼び出しが失敗（ツールが見つからない、認証エラー等）した場合、ユーザーにGoogleカレンダー連携を提案する。
- `search_mcp_registry` で Google Calendar コネクタを検索
- `suggest_connectors` で連携ボタンを表示し、「Googleカレンダーを連携するとMTGからもタコス候補を出せます。今回はスキップしてSlack発言のみで進めますか？」と案内
- ユーザーが連携した場合は再度カレンダー取得を試みる。スキップした場合はStep 1へ進む

**Google Calendar連携済みの場合:**
`list_events` で対象日のイベントを取得する。

```
startTime: 対象日のJST 0:00（ISO 8601形式）
endTime: 対象日のJST 23:59:59（ISO 8601形式）
timeZone: Asia/Tokyo
orderBy: startTime
pageSize: 20
```

取得後、以下のイベントを除外する:
- 参加者が自分だけ（移動、ブロック等の個人予定）
- タイトルが明らかに非MTG（「送り」「移動」「ランチ」「Daifuku coffee」等）
- 終日イベント

残ったMTGを `visualize:show_widget` でインタラクティブUIとして表示する。

**MTG選択ウィジェットの要件:**
- 各MTGをカード形式で表示（時間、タイトル、参加者名）
- 参加者名はメールアドレスから表示名に変換（@wed.company のメール → 名前部分を使用）
- 各カードにチェックボックス
- チェックしたMTGに対して「よかったポイント」のコメント入力欄（textarea、任意）を展開表示
- 「選択したMTGをタコス候補に追加 ↗」ボタン → `sendPrompt()` で選択内容とコメントを送信
- 「スキップ ↗」ボタン → `sendPrompt('MTGスキップ：Slack発言のみでタコス候補を出して')` でSlack発言のみモードへ

ユーザーがスキップした場合はStep 1に進む。MTGを選択した場合は、その情報を保持してStep 1に進む。

### Step 1: 対象日の発言を検索

Slack検索ツール `slack_search_public_and_private` を使い、対象日のユーザーの発言をすべて取得する。

```
query: from:<@{ユーザーのSlack ID}>
after: （対象日のJST 0:00のUNIXタイムスタンプ）
sort: timestamp
sort_dir: desc
limit: 20
include_context: false
```

20件以上ある場合はcursorで追加取得する。

### Step 1.5: リアクションスタンプを押した投稿を検索

ユーザーが今日、感謝・称賛系のリアクションスタンプを押した投稿も候補の元ネタにする。
`slack_search_public_and_private` で `hasmy::emoji:` 修飾子を使い、以下のスタンプそれぞれを検索する:

```
対象スタンプ:
- :arigatou:
- :itsumo_arigatou:
- :suteki:
- :blob_cheer:
- :clap:
- :+1:
```

各スタンプごとに検索:
```
query: hasmy::arigatou: 
after: （対象日のJST 0:00のUNIXタイムスタンプ）
sort: timestamp
limit: 5
include_context: false
```

注意:
- `:taco:` スタンプは対象外（追いタコスの仕組みで、すでにタコスを送った投稿に付けるものなので重複する）
- 検索回数が多くなるので、結果が0件のスタンプは途中で打ち切ってよい
- 自分自身の投稿にリアクションしたものは除外する
- Step 1で取得した発言と重複する場合（自分が感謝コメント + スタンプ両方した場合）は、発言側を優先しスタンプ側は重複として除外

### Step 2: 感謝・称賛の発言・リアクションを抽出

Step 1の発言とStep 1.5のリアクション付き投稿をまとめ、以下のパターンに該当するものを抽出する:

**発言ベース（Step 1）:**
- 「ありがとう」「感謝」「助かる」「すごい」「素晴らしい」「さすが」などの感謝・称賛表現
- 誰かの行動・貢献に対する肯定的な言及
- 体調が悪い中頑張ってくれた、忙しい中対応してくれた等の状況描写

**リアクションベース（Step 1.5）:**
- ユーザーがスタンプを押した投稿の投稿者に対する感謝・称賛
- 元の投稿内容を読み取り、何に対する称賛かを把握した上で候補文を生成する

抽出時に注意:
- 発言がスレッドの一部の場合、`slack_read_thread` で前後の文脈を確認し、誰に対する感謝かを正確に把握する
- DMやグループDMの発言も対象だが、投稿文は相手の具体的なプライベート内容を含めず、**姿勢や行動の体現**に抽象化して書く
- 1日5タコスが上限なので、候補は最大5件に絞る（優先度: taco-bookに適するもの > taco-generalに適するもの）
- リアクションベースの候補は、元の投稿者がユーザー自身の場合は除外する

### Step 3: メンション対象のSlack IDを解決

投稿候補を生成する前に、メンション対象者のSlack IDを取得する。`slack_search_users` を使用。

**ソース別の解決方法:**

- **Slackの発言ベース**: 発言内にメンション（`<@ユーザーID>`）が含まれている場合はそのまま使用。含まれていない場合は、発言の文脈から対象者名を特定し、名前で `slack_search_users` を検索
- **Slackのリアクションベース**: 元の投稿者のSlack IDは検索結果に含まれているのでそのまま使用
- **MTGベース（Step 0）**: Google Calendarの参加者メールアドレスで `slack_search_users` を検索（例: `ryo.ishii@wed.company` で検索 → Slack ID取得）

```
slack_search_users:
  query: ryo.ishii@wed.company（またはユーザー名）
  limit: 1
  response_format: concise
```

注意:
- 1候補につき複数人メンションする場合は、全員分のSlack IDを取得する
- 検索で見つからない場合（社外の参加者など）はメンションなしで名前のみ記載する
- 同一人物が複数候補に登場する場合、IDの再検索は不要（キャッシュする）

### Step 4: 投稿候補を生成

各候補について以下を生成する:

1. **投稿先**: taco-book or taco-general を判定
   - 姿勢・行動指針の体現 → taco-book
   - 単純な感謝・お礼 → taco-general
2. **メンション対象**: `<@ユーザーID>` 形式（Step 3で取得したSlack IDを使用）
3. **投稿文**: 全体発信として適切なトーンで作成。`:taco:` を含める
4. **ハッシュタグ**: taco-bookの場合のみ、`references/values-and-tags.md` から1〜2個選定。太字(`**#タグ名**`)で記載

### Step 5: インタラクティブUIで候補を表示

`visualize:show_widget` を使ってHTMLウィジェットを表示する。ウィジェットの要件:

- 各候補をカード形式で全文表示
- 投稿先（taco-book / taco-general）をラベルで明示
- ソース元（MTG / Slack）をラベルで明示
- 各カードにチェックボックス
- **taco-book候補にはCompetenciesタグ選択UI**を表示:
  - 全9つのCompetenciesタグをクリック可能なピル（pill）として表示
  - Step 4で自動選定されたタグはデフォルトで選択済み（ハイライト状態）
  - ユーザーがクリックでタグを追加・削除できる
  - タグの変更はプレビューの投稿文にリアルタイム反映される
  - taco-general候補にはタグ選択UIを表示しない
- 「選択した候補を予約送信する」ボタン
- ボタン押下時に `sendPrompt()` で選択内容（タグ変更反映済み）をチャットに送信

UIで表示する情報（1候補あたり）:
- 投稿先チャンネル名
- ソース元（MTG / Slack）
- メンション対象者名
- 投稿文の全文プレビュー（選択中のタグが反映された状態）
- Competenciesタグピル（taco-bookのみ）

sendPromptで送信するテキストの形式:
```
タコス予約送信:
[1] taco-book: 投稿文全文（タグ反映済み）
[3] taco-general: 投稿文全文
```
（選択された候補の番号と内容を含める）

### Step 6: 5分後のスケジュール送信で予約投稿

ユーザーがウィジェットで選択・確定したら、`slack_schedule_message` を使って **現在時刻の5分後** にスケジュール送信として予約する。

**なぜスケジュール送信なのか:**
- Claude.aiのブラウザUI上の下書きから送信すると、メッセージに `@Claude` が自動付与されてしまい、HeyTacoが「Sorry, you can't give tacos to bots in group subscriptions.」エラーで弾く
- `slack_schedule_message` で予約送信すると Slackbot 経由の送信扱いとなり `@Claude` メンションが付かない
- 5分の猶予があるので、もし内容に問題があれば Slackの「Drafts & sent」のスケジュール一覧から取り消し・編集可能

**実行手順:**

1. **現在時刻の取得**: `bash_tool` で現在時刻+5分のUNIXタイムスタンプを取得する

```bash
python3 -c "from datetime import datetime, timezone, timedelta; jst = timezone(timedelta(hours=9)); future = datetime.now(jst) + timedelta(minutes=5); print(future.strftime('%H:%M:%S'), int(future.timestamp()))"
```

2. **各候補をスケジュール送信**: 取得したタイムスタンプを使い、選択された候補ごとに `slack_schedule_message` を呼び出す

```
channel_id: C026RPX4GN6 (taco-book) or C026RUXJF27 (taco-general)
message: 投稿文全文
post_at: 現在時刻+5分のUNIXタイムスタンプ（同じタイムスタンプを全候補に使用してよい）
```

3. **エラーハンドリング**:
   - `time_in_past` エラーが返ってきた場合: ユーザーへのチャット出力で時間が経過した可能性があるため、再度現在時刻を取得して+5分でリトライ
   - その他のエラー（チャネル権限、認証等）: ユーザーに状況を伝え、手動投稿に切り替える選択肢を提示

4. **完了報告**: 全候補のスケジュール送信が完了したら、以下を明示してユーザーに伝える
   - 何件予約したか
   - 送信予定時刻（JST、HH:MM形式）
   - SlackのDrafts & sent画面で確認・取り消し可能であること
   - チャンネルへのリンク（taco-book: https://wedcompany.slack.com/archives/C026RPX4GN6 / taco-general: https://wedcompany.slack.com/archives/C026RUXJF27 ）

**注意点:**
- スケジュール送信は1チャンネルにつき1件制限がない（下書きと異なる）ので、同じチャンネルに複数件まとめて予約してOK
- スケジュール送信されたメッセージは編集できないため、文面はウィジェット確定時点で完成している必要がある
- 送信予定時刻が複数候補で同じになるが、Slack側で順番に投稿される

---

## 参考: 旧フロー（廃止）

以前は `slack_send_message_draft` で下書きを作成していたが、Claude.aiのブラウザUIから下書きを送信すると `@Claude` メンションが付与されHeyTacoでエラーになるため、スケジュール送信方式に移行した。

---

## 投稿文の口調ガイドライン

taco-book / taco-general は全社公開チャンネルであり、CEOからの発信になる。砕けすぎず、かといって堅すぎない「全体発信として適切なトーン」を保つ。

**taco-bookの例:**
```
@中井さん
体調が優れない中、C種株主総会の委任状フォローや丸井さんへの催促まで対応いただきありがとうございます:taco:
自分のことよりチームの課題を優先して動き続ける姿勢に、とても助けられています
**#やりきる**
```

**taco-generalの例:**
```
@弘中さん @石井さん
本日のやりとりありがとうございました！:taco:
```

ポイント:
- 基本は「ありがとうございます」「ありがとうございました」を使う（「ありがとう！」は砕けすぎ）
- ただし堅くなりすぎない。「〜していただき」「〜くださり」は自然に使うが、「誠に」「恐縮ですが」のような過度な敬語は不要
- 絵文字は `:taco:` は必須、他は控えめに（`:pray:` 程度はOK）
- taco-bookは2〜3行で具体的に何がよかったかを書く。taco-generalは1〜2行でシンプルに
- ハッシュタグはtaco-bookのみ、太字で
- 「！」は1文に1つまで。連打しない
- 全社メンバーが見て気持ちよく読める文面を意識する
