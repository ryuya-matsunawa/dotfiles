---
name: wed-slide-generate
description: This skill should be used when the user asks to "WEDのスライドを作成して", "WED資料を作って", "WEDプレゼン生成", "create WED branded slides", "WEDのpptxを出力して", or "WEDの提案書を作って". Generates branded .pptx presentations following WED Inc.'s design system.
version: 0.1.0
---

# WED Slide Generator

Generate production-ready .pptx presentations that comply with WED Inc.'s brand design system. Supports proposals, reports, strategy decks, and internal communications.

**This skill builds on top of the built-in `pptx` skill.** Use pptx skill's tools (PptxGenJS, markitdown) directly. This skill adds WED-specific design rules, tokens, and patterns.

## Tool Call Budget

Claude.ai has a limit of ~15 tool calls per turn. Plan carefully:
- **Do NOT read all reference files at once.** Read only what the current step needs.
- **QA is max 2 rounds.** After 2 rounds, stop and report to user. Never enter a 3rd fix loop.
- **Never retry failed tool calls.**

## Quick Reference — Read ONLY what you need

| Priority | What | When to Read |
|----------|------|-------------|
| 1 (always) | [references/pptxgenjs_guide.md](references/pptxgenjs_guide.md) | Slide Master定義 + Helper関数。生成時に必ず読む |
| 2 (always) | [references/design_tokens.md](references/design_tokens.md) | 色・フォント・スペーシング。生成時に必ず読む |
| 3 (if needed) | [references/layout_patterns.md](references/layout_patterns.md) | レイアウトパターン。複雑なレイアウト時のみ |
| 4 (QA turn) | [references/qa_checklist.md](references/qa_checklist.md) | QA実行時のみ（生成ターンでは読まない） |

All general pptx operations (PptxGenJS API, markitdown) are handled by the **built-in `pptx` skill**. Do not duplicate them.

## Workflow

### Step 1: Gather Requirements

Ask the user:
1. **資料タイプ**: 提案書 / レポート / 戦略資料 / 社内向け
2. **対象**: クライアント / 経営層 / 社内メンバー
3. **主要メッセージ**: 伝えたい結論（1-2文）
4. **データ**: KPI数値、チャートデータ、比較データ
5. **枚数目安**: 5-8枚（短め）/ 10-15枚（標準）/ 15-25枚（詳細）

### Step 2: Plan Slide Structure

Read [references/layout_patterns.md](references/layout_patterns.md) if needed.

**提案書構成（10-15枚）**:
1. **Cover** (WED_COVER) — タイトル + 日付
2. **TOC** (WED_COVER) — 目次
3. Statement (#D2D2C6) — 課題提起・結論
4. KPI Dashboard — 現状数値
5. Left-Right 60/40 — 分析 + テイクアウェイ
6. Full-Width Table — 比較・詳細
7. Statement (#D2D2C6) — ビジュアルポーズ
8. Chart — 効果データ
9. Process Flow — 実行計画
10. KPI Dashboard — Next Action
11. **Closing** (WED_CLOSING) — まとめ

**絶対ルール**: 同一パターンを3回連続使用しない。`D2D2C6` ブランドスライドを30-40%混ぜる。表紙・クロージングは必ず生成。

### Step 3: Generate

Read [references/pptxgenjs_guide.md](references/pptxgenjs_guide.md) and [references/design_tokens.md](references/design_tokens.md). Generate all slides using PptxGenJS with WED Slide Masters.

**CRITICAL RULES:**
- `pres.layout = "LAYOUT_16x9"` — ALWAYS set first
- **Use the helper functions from pptxgenjs_guide.md.** Do NOT hardcode coordinates manually.
- **Set `slide.background` explicitly** on every non-white slide: `slide.background = { color: "D2D2C6" }` for brand slides, `{ color: "6D695D" }` for section slides
- Content starts at **y ≥ 1.1"**. Never overlap with title.
- **KPI card text must fit**: number ≤ 6 chars, label ≤ 15 chars. Abbreviate if longer.
- **Chart labels must not overlap**: use `dataLabelPosition: "outEnd"` for bar, `"bestFit"` for pie. Place legend outside chart.

### Step 4: QA + Fix (Max 2 Rounds — Then Stop)

After generation, run QA **without asking the user**. Read [references/qa_checklist.md](references/qa_checklist.md).

**Round 1**: Check the pptx for issues. Fix any obvious problems.
**Round 2**: Re-check. Fix remaining issues if any.
**After 2 rounds: STOP.** Report remaining issues to user.

### Step 5: Report + Ask User

After max 2 QA rounds, report to user:
1. スライド構成一覧（パターン名 + タイトル）
2. 修正した内容（あれば）
3. 残っている課題（あれば）
4. **「追加の修正事項はありますか？」**

Wait for user response. Only modify based on user instructions.

## WED Design System (Mandatory)

### Color Palette — ONLY 4 Colors

| Token | HEX | Role |
|-------|-----|------|
| BEIGE_LIGHT | `D2D2C6` | Brand BG, texture, card alt-row |
| BEIGE_DARK | `6D695D` | Accent, KPI numbers, chart primary, highlights |
| BLACK | `000000` | Headings, body text, table header BG |
| WHITE | `FFFFFF` | Primary slide BG, cards, text on dark |

**No green, blue, red, pink, yellow, orange, purple. Ever. No "#" prefix in hex.**

### Typography

| Element | Font | Size | Color |
|---------|------|------|-------|
| Slide title | Zen Kaku Gothic New Bold | 28-32pt | `000000` |
| Sub-header | Zen Kaku Gothic New Bold | 20-24pt | `000000`/`FFFFFF` |
| Body text | Zen Kaku Gothic New Regular | 18-20pt | `000000` |
| KPI label | Zen Kaku Gothic New Regular | 16pt | `6D695D` |
| Footnote | Zen Kaku Gothic New Regular | 14pt | `6D695D` |
| KPI numbers | Zen Kaku Gothic New Bold | 48-72pt | `6D695D` |

**FORBIDDEN**: Sizes below 14pt. Body text below 18pt.

### Voice & Tone

- **である調** — NEVER です/ます
- Title = conclusion/insight — NEVER "〜について" / "〜の概要"
- 結論 → 根拠 → Next Action
- Calm, honest, fact-driven. No hyperbole.

## Prohibitions Checklist

- [ ] No colors outside 4-color palette
- [ ] No font size below 14pt. Body text ≥ 18pt
- [ ] No same layout 3x consecutively
- [ ] No bullet-only slides
- [ ] At least 2 charts if quantitative data exists
- [ ] No external images (native shapes only)
- [ ] No gradients, shadows, 3D effects
- [ ] No vague titles ("〜について")
- [ ] No です/ます
- [ ] All data cites source
- [ ] Margins ≥ 6% horizontal, ≥ 8% vertical
- [ ] D2D2C6 brand slides = 30-40% of deck

## Output (Step 5)

Report to user:
1. ファイルパス
2. スライド構成一覧（パターン名 + タイトル）
3. 検出・修正した問題のサマリー
4. **「追加の修正事項はありますか？」**
