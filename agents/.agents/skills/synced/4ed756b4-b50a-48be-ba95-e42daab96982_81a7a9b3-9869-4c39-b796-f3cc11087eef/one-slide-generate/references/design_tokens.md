# ONE Design Tokens — Complete Reference

## Color Tokens

### Semantic Token Map

```javascript
// PptxGenJS (no "#" prefix)
const ONE = {
  GREEN:       "3EE3A6",  // Charts primary, progress bars, tags, graph fills
  DARK_GREEN:  "00D184",  // KPI numbers, highlights, CTA, graph secondary
  LIGHT_GREEN: "D7FFF0",  // Badge BG, subtle highlight, table highlight cells
  BLACK:       "000000",  // Body text, slide titles, table header row BG
  LIGHT_GRAY:  "F0F3F6",  // Card BG, alt-row BG, brand slide BG, sub-sections
  DARK_GRAY:   "8C909B",  // Rules, borders, sub-headers, footnotes, graph tertiary
  WHITE:       "FFFFFF",  // Primary slide BG (60-70% of slides)
};
```

```python
# python-pptx (RGBColor objects)
from pptx.dml.color import RGBColor

ONE_GREEN       = RGBColor(0x3E, 0xE3, 0xA6)
ONE_DARK_GREEN  = RGBColor(0x00, 0xD1, 0x84)
ONE_LIGHT_GREEN = RGBColor(0xD7, 0xFF, 0xF0)
BLACK           = RGBColor(0x00, 0x00, 0x00)
ONE_LIGHT_GRAY  = RGBColor(0xF0, 0xF3, 0xF6)
ONE_DARK_GRAY   = RGBColor(0x8C, 0x90, 0x9B)
WHITE           = RGBColor(0xFF, 0xFF, 0xFF)
```

**These are the ONLY 7 colors. No red, blue, pink, yellow, orange, purple.**

### Color Pairing Matrix

| Slide BG | Card/Section Fill | Text | Accent |
|----------|------------------|------|--------|
| `FFFFFF` (White) | `F0F3F6` (Light Gray) | `000000` | `00D184` / `3EE3A6` |
| `F0F3F6` (Light Gray) | `FFFFFF` (White) | `000000` | `00D184` / `3EE3A6` |

**NEVER**:
- Same color on same color (`F0F3F6` card on `F0F3F6` BG = invisible)
- `000000` as slide background (black = text and table headers only)
- `3EE3A6`/`00D184` as slide background or large card fill (>25% area)
- Green for body text or headers

### Chart Color Sequence

| Order | Color | Token |
|-------|-------|-------|
| 1st | `3EE3A6` | ONE_GREEN (primary) |
| 2nd | `00D184` | ONE_DARK_GREEN (secondary) |
| 3rd | `8C909B` | ONE_DARK_GRAY (tertiary) |
| 4th | `F0F3F6` | ONE_LIGHT_GRAY (quaternary) |
| 5th | `000000` | BLACK (sparingly) |

### Background Rhythm

- **Content slides** (data-heavy): `FFFFFF` background (60-70% of deck)
- **Brand slides** (statement, pause): `F0F3F6` background (30-40% of deck)
- Mix both in every deck. Creates visual rhythm.
- Never all-white or all-gray.

---

## Typography Tokens

### Font Stack

| Context | Font | Weight | Size Range | Color |
|---------|------|--------|------------|-------|
| "ONE" brand name | Brandon Grotesque | Black (900) | Context | `000000`/`FFFFFF` |
| KPI display numbers | Kotonode (fallback: Arial Black) | Bold | 48-72pt | `00D184` |
| Slide title | Noto Sans JP | Bold (700) | 28-32pt | `000000` |
| Sub-header | Noto Sans JP | Bold (700) | 20-24pt | `000000` |
| Body text | Noto Sans JP | Regular (400) | 18-20pt | `000000` |
| KPI label | Noto Sans JP | Regular (400) | 16pt | `8C909B` |
| Footnote / Source | Noto Sans JP | Regular (400) | 14pt | `8C909B` |

### PptxGenJS Font Pairing

```javascript
const FONTS = {
  title:    "Noto Sans JP",
  body:     "Noto Sans JP",
  kpi:      "Arial Black",  // fallback for Kotonode
  brand:    "Brandon Grotesque",
};

const SIZES = {
  title:     28,   // 28-32pt
  subtitle:  22,   // 20-24pt
  body:      18,   // 18-20pt
  kpiNumber: 54,   // 48-72pt
  kpiLabel:  16,
  footnote:  14,
};
```

### Forbidden Sizes

- **10pt, 12pt** — these do NOT exist in ONE slides
- Body text MUST be 18pt+
- Minimum any text: 14pt

### Text Density Limits (per element)

| Element | Max Words | Rationale |
|---------|-----------|-----------|
| Slide title | 10 | Conclusion, not topic label |
| Bullet point | 12 each | One idea per line |
| Table cell | 10 | Scannable at glance |
| Card body | 50 | Fewer words = larger fonts |
| KPI label | 5 | Concise metric name |

---

## Spacing Tokens

### Slide Dimensions

```javascript
// PptxGenJS
pres.layout = "LAYOUT_16x9";  // 10" × 5.625"

// python-pptx (EMU)
SLIDE_WIDTH  = 9144000   // 10 inches
SLIDE_HEIGHT = 5143500   // 5.625 inches
```

### Margins & Spacing

| Token | Inches | EMU | PptxGenJS |
|-------|--------|-----|-----------|
| Edge margin | 0.56" | 508000 | `x: 0.56` |
| Title top | 0.45" | 411480 | `y: 0.45` |
| Content start | 0.84" | 771525 | `y: 0.84` |
| Content end | 5.06" | 4629150 | `y: 5.06` (bottom limit) |
| Card gap | ~5% of card width | varies | `0.15-0.2` |
| Block gap | 0.3-0.5" | — | `gap: 0.3` |

### Shape Tokens

| Property | Value |
|----------|-------|
| Card border-radius | 8px max (0.08") |
| Line/rule width | 1-2px |
| Accent line width | 3px |
| Divider line color | `8C909B` |

---

## Voice & Tone Tokens

### Writing Style

- **Register**: である調 + 体言止め (assertive, concise)
- **NEVER**: です/ます調
- **Structure**: 結論 → 根拠データ → 示唆/Next Action
- **Title rule**: Must state conclusion/insight. NEVER "〜について" / "〜の概要"
- **Data rule**: Every number cites source or notes "推定" / "社内データ"
- **Quantification**: "前年比+32%増" not "大幅に増加"
- **Direction symbols**: ▲ for increase, ▼ for decrease

### Brand Naming

- "ONE" = always full caps, Brandon Grotesque Black
- "WED" = parent company context only; product slides use ONE
- "PMN" = full name on first mention, abbreviation thereafter

---

## Slide Master Definitions (PptxGenJS)

PptxGenJSでスライドを生成する際に使用するSlide Master:

| Master Name | BG Color | Use Case | Helper Function |
|-------------|----------|----------|-----------------|
| **ONE_COVER** | `1F2020` (dark) | 表紙 | `makeCoverSlide(title, subtitle, date)` |
| **ONE_SECTION** | `1F2020` (dark) | 目次 / セクション区切り | `makeTocSlide(items)` / `makeSectionSlide(title, num)` |
| **ONE_CONTENT** | `FFFFFF` (white) | コンテンツ（データ表示） | 各パターン関数 |
| **ONE_BRAND** | `F0F3F6` (light gray) | ステートメント / ポーズ | `makeStatementSlide(text, sub)` |
| **ONE_CLOSING** | `F0F3F6` (light gray) | クロージング + CTA | `makeClosingSlide(title, email, url)` |

**必須**: 全デッキで Cover (最初) と Closing (最後) を生成すること。

Helper functions の実装: [pptxgenjs_guide.md](pptxgenjs_guide.md)

## Template Layout Index (unpack/pack用参考)

テンプレートベース編集時のみ参照。PptxGenJS使用時は上記Slide Masterを使用。

| Index | Name | BG | Use Case |
|-------|------|----|----------|
| 0 | SECTION_HEADER | `1F2020` | Cover |
| 1 | CUSTOM_3 | `1F2020` | Section title |
| 2 | CUSTOM_6 | `1F2020` | Table of contents |
| 4 | **Blank** | White | Content (primary) |
| 5 | CUSTOM_2 | `F0F3F6` | Brand/statement |
| 6-13 | CUSTOM variants | Various | Card layouts |
| 14 | CUSTOM_7 | White | Table layout |
| 15-16 | CUSTOM_4 variants | `F0F3F6` | Closing |
