---
name: one-slide-generate
description: This skill should be used when the user asks to "ONEのスライドを作成して", "ONE営業資料を作って", "ONEウェビナー資料を生成", "create ONE branded slides", "ONEのpptxを出力して", or "ONEプレゼン作って". Generates branded .pptx presentations following ONE by WED's design system for webinars and sales materials.
version: 0.3.0
---

# ONE Slide Generator

Generate production-ready .pptx presentations that comply with ONE by WED's brand design system. Supports webinar decks, sales materials, proposals, and reports.

**This skill builds on top of the built-in `pptx` skill.** Use pptx skill's tools (PptxGenJS, markitdown, thumbnail.py, unpack/pack/clean scripts) directly — they are already available. This skill adds ONE-specific design rules, tokens, and patterns.

## Tool Call Budget

Claude.ai has a limit of ~15 tool calls per turn. Plan carefully:
- **Do NOT read all reference files at once.** Read only what the current step needs.
- **QA is max 2 rounds.** After 2 rounds, stop and report to user. Never enter a 3rd fix loop.
- **Never retry failed tool calls** (especially soffice/PDF conversion).

## Quick Reference — Read ONLY what you need

| Priority | What | When to Read |
|----------|------|-------------|
| 1 (always) | [references/pptxgenjs_guide.md](references/pptxgenjs_guide.md) | Slide Master定義 + Helper関数。生成時に必ず読む |
| 2 (always) | [references/design_tokens.md](references/design_tokens.md) | 色・フォント・スペーシング。生成時に必ず読む |
| 3 (if needed) | [references/layout_patterns.md](references/layout_patterns.md) | 39パターンカタログ。複雑なレイアウト時のみ |
| 4 (QA turn) | [references/qa_checklist.md](references/qa_checklist.md) | QA実行時のみ（生成ターンでは読まない） |
| 5 (rare) | [references/editing_guide.md](references/editing_guide.md) | テンプレート編集時のみ |

All general pptx operations (PptxGenJS API, unpack/pack workflow, markitdown, thumbnail) are handled by the **built-in `pptx` skill**. Do not duplicate them.

## Workflow

### Step 1: Gather Requirements

Ask the user:
1. **資料タイプ**: ウェビナー / 営業資料 / レポート / 提案書
2. **対象**: 広告主向け / 代理店向け / 社内向け
3. **主要メッセージ**: 伝えたい結論（1-2文）
4. **データ**: KPI数値、チャートデータ、比較データ
5. **枚数目安**: デフォルト8-12枚

### Step 2: Choose Creation Method

Use the built-in `pptx` skill's infrastructure:

- **PptxGenJS（推奨）**: スクラッチ作成。Built-in pptx skill + ONE tokens。→ Read [references/pptxgenjs_guide.md](references/pptxgenjs_guide.md)
- **テンプレート編集**: ONE公式テンプレートを unpack/edit/pack。→ Read [references/editing_guide.md](references/editing_guide.md)
- **python-pptx（要 `pip install python-pptx`）**: JSON→pptx自動生成 + バリデーション → `scripts/one_slide_builder.py`

### Step 3: Plan Slide Structure

Read [references/layout_patterns.md](references/layout_patterns.md) for the full 39-pattern catalog.

**ウェビナー構成（10-14枚）**:
1. **Cover** (ONE_COVER) — タイトル + 日付
2. **TOC** (ONE_SECTION) — 目次
3. Statement (#F0F3F6) — 課題提起
4. KPI-Row — プラットフォーム規模
5. Left-Right 60/40 — ソリューション概要
6. Full-Width Table — 機能/料金比較
7. Statement (#F0F3F6) — ビジュアルポーズ
8. Chart — 効果データ
9. Process Flow — 導入フロー
10. KPI-Row — Next Action
11. **Closing** (ONE_CLOSING) — CTA + 連絡先

**営業資料構成（10-14枚）**:
1. **Cover** (ONE_COVER) — 「〇〇のご提案」+ 日付
2. **TOC** (ONE_SECTION) — 目次
3. Statement — 提案の結論
4. KPI-Row — 市場課題
5. Comparison 50/50 — Before/After
6. Table — プラン詳細
7. Statement (#F0F3F6) — ポーズ
8. Chart — 導入効果
9. Timeline — スケジュール
10. KPI-Row — Next Action
11. **Closing** (ONE_CLOSING) — CTA + 連絡先

**絶対ルール**: 同一パターンを3回連続使用しない。`F0F3F6` ブランドスライドを30-40%混ぜる。表紙・目次・クロージングは必ず生成する。

### Step 4: Generate

Read [references/pptxgenjs_guide.md](references/pptxgenjs_guide.md) and [references/design_tokens.md](references/design_tokens.md). Generate all slides using PptxGenJS with ONE Slide Masters.

**CRITICAL**: Always set `pres.layout = "LAYOUT_16x9"` first. Never use LAYOUT_WIDE.

**Layout rule**: Content must start at **y ≥ 1.1"** (below title + accent line). Never overlap with title area (y=0.45 to y=0.95).

### Step 5: QA + Fix (Max 2 Rounds — Then Stop)

After generation, run QA **without asking the user**. Read [references/qa_checklist.md](references/qa_checklist.md).

**Round 1**: Check the pptx for issues (markitdown + visual review of generated code). Fix any obvious problems.
**Round 2**: Re-check. Fix remaining issues if any.
**After 2 rounds: STOP.** Do not enter a 3rd round. Report remaining issues to user.

### Step 6: Report + Ask User

After max 2 QA rounds, report to user:
1. スライド構成一覧（パターン名 + タイトル）
2. 修正した内容（あれば）
3. 残っている課題（あれば）
4. **「追加の修正事項はありますか？」**

Wait for user response. Only modify based on user instructions.

## ONE Design System (Mandatory — Zero Tolerance)

### Color Palette — ONLY 7 Colors

| Token | HEX | Role |
|-------|-----|------|
| ONE_GREEN | `3EE3A6` | Charts primary, progress bars, tags |
| ONE_DARK_GREEN | `00D184` | KPI numbers, CTA, highlights |
| ONE_LIGHT_GREEN | `D7FFF0` | Badge BG, subtle highlight |
| BLACK | `000000` | Body text, titles, table header BG |
| ONE_LIGHT_GRAY | `F0F3F6` | Card BG, alt-row, brand slide BG |
| ONE_DARK_GRAY | `8C909B` | Rules, borders, footnotes |
| WHITE | `FFFFFF` | Primary slide BG (60-70%) |

**No red, blue, pink, yellow, orange, purple. Ever. No "#" prefix in hex.**

### Typography

| Element | Font | Size | Color |
|---------|------|------|-------|
| "ONE" brand | Brandon Grotesque Black | context | `000000`/`FFFFFF` |
| KPI numbers | Kotonode Bold (fallback: Arial Black) | 48-72pt | `00D184` |
| Slide title | Noto Sans JP Bold | 28-32pt | `000000` |
| Sub-header | Noto Sans JP Bold | 20-24pt | `000000` |
| Body text | Noto Sans JP Regular | 18-20pt | `000000` |
| KPI label | Noto Sans JP Regular | 16pt | `8C909B` |
| Footnote | Noto Sans JP Regular | 14pt | `8C909B` |

**FORBIDDEN**: Sizes below 14pt. Body text below 18pt.

### Voice & Tone

- **である調 + 体言止め** — NEVER です/ます
- Title = conclusion/insight — NEVER "〜について" / "〜の概要"
- 結論 → 根拠データ → 示唆/Next Action
- Every data point: cite source or note "推定" / "社内データ"
- Quantify everything — "前年比+32%" not "大幅に増加"

## Prohibitions Checklist (verify before output)

- [ ] No colors outside 7-color palette
- [ ] No same-color-on-same-color (F0F3F6 on F0F3F6 = invisible)
- [ ] No green as slide BG or large fill (>25%)
- [ ] No black as slide BG
- [ ] No font size below 14pt
- [ ] No same layout 3x consecutively
- [ ] No bullet-only slides
- [ ] At least 2 charts if quantitative data exists
- [ ] No external images (native shapes/icons only)
- [ ] No gradients, shadows, 3D effects
- [ ] No vague titles ("〜について")
- [ ] No です/ます
- [ ] All data cites source
- [ ] No accent lines under titles
- [ ] No placeholder text remaining
- [ ] No text overflow/cutoff
- [ ] Margins ≥ 0.5" on all slides

## Output (Step 6)

Report to user:
1. ファイルパス
2. スライド構成一覧（パターン名 + タイトル）
3. 検出・修正した問題のサマリー
4. **「追加の修正事項はありますか？」**
