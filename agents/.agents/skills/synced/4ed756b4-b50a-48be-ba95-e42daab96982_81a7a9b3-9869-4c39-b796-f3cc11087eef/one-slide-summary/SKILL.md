---
name: one-slide-summary
description: This skill should be used when the user asks to "ONEのレポートサマリーを作って", "1枚サマリー作成", "レポートから営業用スライドを作って", "分析レポートを1ページにまとめて", "ONE summary slide", or "credential用のサマリーを作って". Reads an analysis report and produces a single-page summary slide for sales credential decks.
version: 0.2.0
---

# ONE Report Summary — Single Page Slide Generator

Read an attached analysis report and produce a **single-page summary slide** for insertion into credential (proposal) decks. Style: data-driven consultant (McKinsey density + dashboard visuals).

**This skill uses the `one-slide-generate` skill's design tokens, helper functions, and layout patterns.** Refer to one-slide-generate's references for all PptxGenJS implementation details. This skill adds summary-specific workflow and content curation rules only.

## Workflow

### Step 1: Read the Report

Read the attached analysis report (pptx, PDF, or text). Extract:
- 分析対象（業種、カテゴリ、市場）
- 主要KPIと数値データ
- 結論と示唆
- チャート/グラフのデータポイント

### Step 2: Ask Questions (2-3, in ONE message)

After reading, ask the following in a **single message**. No further confirmations after this.

1. **提案先の業種は？**（例：食品メーカー、日用品、飲料、小売 etc.）
2. **サマリーの方向性を選んでください：**
   - A) **エグゼクティブサマリー** — レポート全体の要約。主要KPI・結論・示唆を網羅
   - B) **課題フォーカス** — 提案先に刺さる特定の課題・データを抽出（選んだ場合、注目テーマも質問）
3. **特に強調したいデータや示唆があれば教えてください**（任意、なければスキップ可）

Once answered, **generate immediately.**

### Step 3: Generate

Use the `one-slide-generate` skill's design system (colors, fonts, spacing, helper functions) to produce 1 summary slide. Default is 1 page. User requests more → max 2-3 pages.

**選んだModeに応じたレイアウトパターン:**

#### Mode A: エグゼクティブサマリー
- **推奨パターン**: KPI-Row（one-slide-generateの`makeKpiRowSlide`を参考）
- Top: 3-4 KPI cards（レポートから最もインパクトのある数値を選定）
- Bottom: 核心的インサイト or チャート
- Title = レポート全体の最重要結論

#### Mode B: 課題フォーカス
- **推奨パターン**: Statement+Evidence（one-slide-generateの`makeStatementSlide`を参考）
- Top: 24-28pt bold の課題/結論
- Bottom: 裏付けデータ（KPIカード or チャート）
- Title = 提案先の業種に刺さる課題表現

#### 共通ルール
- **1ページに収める** — ruthless curation。詰め込まない。
- **88%ルール**: コンテンツはスライド高さの88%以内（底部12% = セーフマージン）。はみ出す場合はKPI数を減らす or テキストを短縮。フォントを小さくするのではなく、コンテンツを削る。
- **データ選定**: レポートの全データではなく、3-4個の最インパクトKPI + 1つの核心チャート + 1つのコアインサイトのみ。
- **業種コンテキスト化**: 同じデータでも提案先の業種によって切り口を変える。
- **データ捏造禁止**。元レポートのデータのみ使用。丸め・簡略化はOK。

### Step 4: QA + Fix (Max 2 Rounds — Then Stop)

Run QA **without asking**. Read [references/qa_checklist.md](references/qa_checklist.md).

Round 1: Check + fix. Round 2: Re-check + fix. **After 2 rounds: STOP.**

### Step 5: Report + Ask User

Report:
1. スライドレイアウト（Mode A or B + パターン名）
2. 含めたデータポイント
3. 修正した問題（あれば）
4. **「修正・調整したい点はありますか？（レイアウト変更、データポイントの差し替え、追加ページなど）」**

## Content Curation Rules (Summary-Specific)

### Data Selection

From the source report, select ONLY:
- **3-4 highest-impact KPIs** — not all KPIs
- **1 most compelling chart** — not all charts
- **1 core insight** — not all conclusions

### Contextualizing for Target Industry

Same data, different angle depending on the prospect:
- **食品メーカー**: カテゴリ購買率、競合スイッチ率に注目
- **日用品**: リピート率、購買頻度に注目
- **飲料**: 季節変動、新商品トライアル率に注目
- **小売**: 来店頻度、バスケット分析に注目

### Inline Highlight Prohibition

- **NEVER place highlighted text inline within a sentence.** Inline highlights export as images in Google Slides → text overlap → broken layout.
- 代替: (A) bold + `00D184` color for inline emphasis, (B) standalone KPI card, (C) standalone highlight block

## Design System

**one-slide-generate スキルの定義を使用。** 以下はクイックリファレンス:

### Colors — 7 Colors Only
`FFFFFF`, `F0F3F6`, `000000`, `8C909B`, `3EE3A6`, `00D184`, `D7FFF0`

### Typography
Title: 28-32pt Bold, Body: 18-20pt, KPI: 48-72pt `00D184`, Label: 16pt `8C909B`, Footnote: 14pt `8C909B`

### Prohibitions
- No colors outside palette
- No font below 14pt, body below 18pt
- No content below 88% slide height
- No external images, gradients, shadows
- No inline highlights
- No vague titles ("〜について")
- No です/ます
- No data fabrication
- All data cites source
