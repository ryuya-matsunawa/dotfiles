# WED Design Tokens — Complete Reference

## Color Tokens

### 4 Colors Only

```javascript
const C = {
  BEIGE_LIGHT: "D2D2C6",  // Brand BG, texture, card alt-row, secondary chart
  BEIGE_DARK:  "6D695D",  // Accent, KPI numbers, chart primary, highlights, table header
  BLACK:       "000000",  // Headings, body text
  WHITE:       "FFFFFF",  // Primary slide BG, cards, text on dark
};
```

**No other colors. No green, blue, red, pink, yellow, orange, purple.**

### Color Pairing Rules

| Slide BG | Card/Section Fill | Text | Accent/KPI |
|----------|------------------|------|------------|
| `FFFFFF` (White) | `D2D2C6` (Beige Light) | `000000` | `6D695D` |
| `D2D2C6` (Beige Light) | `FFFFFF` (White) | `000000` | `6D695D` |
| `6D695D` (Beige Dark) | — | `FFFFFF` | — |

### Text Color Rules

- BG = `D2D2C6` or `FFFFFF` → text = `000000`
- BG = `6D695D` or `000000` → text = `FFFFFF`
- KPI numbers: `6D695D` on light backgrounds (sole exception)
- Body text: always `000000`, never gray

### Chart Color Sequence

1. Primary: `6D695D` (Beige Dark)
2. Secondary: `D2D2C6` (Beige Light)
3. Tertiary: `000000` (sparingly)

### Background Rhythm

- Content slides: `FFFFFF` (60-70%)
- Brand slides: `D2D2C6` (30-40%)
- Section dividers: `6D695D` or `000000`

---

## Typography Tokens

| Element | Font | Weight | Size | Color |
|---------|------|--------|------|-------|
| Slide title | Zen Kaku Gothic New | Bold | 28-32pt | `000000` |
| Sub-header | Zen Kaku Gothic New | Bold | 20-24pt | `000000`/`FFFFFF` |
| Body text | Zen Kaku Gothic New | Regular | 18-20pt | `000000` |
| KPI label | Zen Kaku Gothic New | Regular | 16pt | `6D695D` |
| Footnote / Source | Zen Kaku Gothic New | Regular | 14pt | `6D695D` |
| KPI numbers | Zen Kaku Gothic New | Bold | 48-72pt | `6D695D` |

```javascript
const F = { title: "Zen Kaku Gothic New", body: "Zen Kaku Gothic New" };
const S = { title: 28, subtitle: 22, body: 18, kpiLabel: 16, footnote: 14, kpiNum: 54 };
```

### FORBIDDEN Sizes

Below 14pt. Body text must be **18pt+**.

---

## Spacing Tokens

```javascript
const M = {
  left: 0.60,       // ~6% of 10"
  top: 0.45,        // title start
  contentY: 1.1,    // content start (below title)
  maxW: 8.80,       // 10" - margins
  marginV: 0.45,    // ~8% of 5.625"
};
```

### Shape Tokens

- Card border-radius: 8-12px (0.08-0.12")
- Line/rule width: 1-2px
- Accent border: 4px `6D695D`
- Rounded corners on ALL cards, tables, content boxes

---

## Slide Master Definitions (PptxGenJS)

| Master Name | BG Color | Use Case | Helper |
|-------------|----------|----------|--------|
| **WED_COVER** | `D2D2C6` | 表紙 / 目次 | `makeCoverSlide()` / `makeTocSlide()` |
| **WED_CONTENT** | `FFFFFF` | コンテンツ | 各パターン関数 |
| **WED_BRAND** | `D2D2C6` | ステートメント / ポーズ | `makeStatementSlide()` |
| **WED_SECTION** | `6D695D` | セクション区切り | `makeSectionSlide()` |
| **WED_CLOSING** | `D2D2C6` | クロージング | `makeClosingSlide()` |

Helper functions: [pptxgenjs_guide.md](pptxgenjs_guide.md)

## Logo Files (assets/logos/)

| ファイル | 内容 | 使用場面 |
|---------|------|---------|
| **WED-Logo-primary.png** | シンボル+"WED"英語（黒） | ★Cover, Brand, 白/ベージュBG |
| **Logo02.png** | シンボルのみ（白） | Section divider（ダークBG） |
| **Logo01.png** | シンボルのみ（ベージュBG） | Closing中央 |
| Logo03.png | シンボルのみ（ベージュダーク on 白） | 白BGでの代替 |
| WED-Logo-Mark-Type-English.png | シンボル+"WED"（黒） | 代替 |
| WED-Logo-Mark-Type-Japanese.png | シンボル+"ウエッド"（黒） | 日本語コンテキスト |
| wed-Logo-english.png | "WED"文字のみ | 省スペース |
| wed-Logo-katakana.png | "ウエッド"文字のみ | 省スペース |

PptxGenJSでの使用: `slide.addImage({ path: "assets/logos/WED-Logo-primary.png", x: 7.8, y: 0.25, w: 1.8, h: 0.45 })`

## Template Layout Index (WED_Slide_Template.pptx)

| Index | Name | BG | Use |
|-------|------|----|-----|
| 0 | Blank | White | Content (primary) |
| 1 | SECTION_HEADER_1_3_1_1 | White | Section divider |
| 2 | Blank_2 | `D2D2C6` | Closing/brand |
