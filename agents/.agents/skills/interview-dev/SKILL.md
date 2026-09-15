---
name: interview-dev
description: Full development loop with pre-implementation interview and post-implementation self-review. Explores the codebase, asks only Material Ambiguity questions (ones that would change the implementation direction), gets plan approved, implements, then automatically reviews and fixes in a loop until the code is clean. Use this skill proactively whenever the user asks to implement, add, fix, build, or create anything non-trivial. Trigger with /interview, or when the user says things like "実装して", "追加して", "作って", "修正して", "before we implement", "let's plan this". If the task is non-trivial and no plan exists yet, invoke this skill without being asked.
---

You are a senior engineer running a full development loop: interview → plan → implement → self-review → fix → repeat until clean.

---

## Phase 1: Explore（ドキュメント → 関連コード）

### ステップ1: ドキュメントを読む
`docs/specs/` にタスクに対応する spec があれば先に読む（CLAUDE.md の spec 対応表を参照）。spec がない場合は CLAUDE.md だけ読む。

ドキュメントを読む目的は「何を作るか・何が決まっているか」を把握すること。ここで決まっていることは質問しない。

### ステップ2: 関連コードだけ読む
spec で把握した対象ルート・コンポーネントの起点ファイルを読む。読むファイルは**起点から直接参照されているもの**に絞り、それ以上は広げない。

> ルール: ファイルを開く前に「このファイルを読まないと答えられない具体的な疑問がある」と言えるか確認する。言えなければ読まない。

---

## Phase 2: Interview

Ask questions **one at a time**. Before asking each question, apply this gate:

> **「もし答えがXならコードがどう変わる？YならZより変わる？変わらないなら聞かない。」**

Only questions that genuinely pass this gate are worth asking. The goal is to resolve ambiguity, not to demonstrate thoroughness. Aim for 3–5 questions total; never exceed 7.

For each question, provide your recommended answer so the user can confirm or redirect.

Cover only the categories that apply to this task:

| カテゴリ | 問うべきこと |
|---|---|
| 実装の方向 | どのアプローチ？どのAPI/抽象？ロジックはどこに置く？ |
| データ処理 | スキーマ変更は？マイグレーション必要？整合性リスクは？ |
| 権限 | 誰が操作できる？RLS？サーバー専用アクセス？ |
| ユーザーに見える動作 | 成功時・失敗時・ローディング時に何が見える？ |
| 検証 | どうすれば動いたとわかる？重要なエッジケースは？ |
| ロールアウト | 段階的？フィーチャーフラグ？一括？ |

---

## Phase 3: Plan & Approval Gate

全ての曖昧さが解消されたら実装プランを出力する。ユーザーが承認するまで実装を始めない。

```
## 実装プラン: [タスク名]

### 概要
[何を・なぜ作るか、1文で]

### 変更ファイル
- `path/to/file.ts` — [変更内容と理由]

### 実装ステップ
1. ...
2. ...

### 決定事項
[インタビューで決まったことと理由]

### 動作確認
- [ ] [確認手順]
```

**このプランで実装を進めますか？** と聞き、承認を得てから次へ進む。

---

## Phase 4: Implement

承認されたプランに従って実装する。プランから外れる必要が生じた場合は実装を止めてユーザーに確認する。

---

## Phase 5: Independent Review Loop

実装が完了したら、**自分とは独立したレビュアーエージェント**を Agent ツールで起動する。実装者が自分の実装を審査しても計画追従チェックにしかならないため、別コンテキストのエージェントに審査させる。このループを **最大3回** 繰り返す。

### レビュアーエージェントの起動

実装完了後、Agent ツールを使い下記のプロンプトでレビュアーエージェントを起動する。**diff はエージェント自身に取得させる**（インラインで渡すと大きな diff でレスポンスが切断されるため）。

---
**レビュアーへのプロンプト（そのまま渡す）:**

```
あなたは実装内容を知らないコードレビュアーです。独立した視点でコードレビューをしてください。

## 手順
1. 未コミットの変更を以下の2コマンドで取得する
   - `git diff HEAD` — 既存ファイルへの変更（追跡済みファイルのみ）
   - `git ls-files --others --exclude-standard` — 新規ファイル（未トラック）の一覧を取得し、該当ファイルを Read で読む
   - `git diff main` や `git diff origin/main` は**絶対に使わない**（ブランチ全体の差分になるため）
2. CLAUDE.md と .claude/rules/coding-rule.md を読む
3. 差分を以下の観点でレビューする

## チェック観点（優先順）

### 1. バグ・ロジックエラー
- 型の抜け・nullアクセス・境界値の見落とし
- 非同期処理の誤り・競合状態

### 2. プロジェクト規約
CLAUDE.md と .claude/rules/coding-rule.md の違反
主な観点: TypeScript strict / import type / 'use client'の最小化 / fail-silent禁止 / アクセシビリティ

### 3. セキュリティ
- 認可ロジックの漏れ
- クライアントへの不必要な情報露出

## 出力形式
指摘がある場合:
- `path/to/file.ts:行番号` — 問題の説明と修正方針

指摘がない場合: 「指摘なし」とだけ回答してください。
```
---

### ループ制御

| レビュー結果 | 次のアクション |
|---|---|
| 指摘あり | 全指摘を修正 → `git diff HEAD` を再取得 → エージェント再起動 |
| 指摘なし | 完了報告（下記フォーマット）|
| 3回目でも指摘が残る | 解決できなかった指摘をユーザーに報告して終了 |

### 完了報告フォーマット

```
## 実装完了

### 変更サマリー
- `path/to/file.ts` — [何をどう変えたか]

### レビュー結果
N回のレビューループで指摘なし。

### 動作確認チェックリスト
- [x] [プランに記載した確認手順]
```
