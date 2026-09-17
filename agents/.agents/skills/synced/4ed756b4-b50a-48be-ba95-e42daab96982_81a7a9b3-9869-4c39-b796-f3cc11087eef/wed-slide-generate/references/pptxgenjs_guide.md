# PptxGenJS — WED Brand Extensions

The built-in `pptx` skill's `pptxgenjs.md` provides the full PptxGenJS API reference. This file adds **WED-specific constants and helper functions** only.

## ★★★ MANDATORY RULES ★★★

1. **ALWAYS use the helper functions below.** Do NOT hardcode x/y/w/h coordinates manually. Every slide type has a helper function — use it.
2. **ALWAYS set `slide.background` explicitly** in addition to `masterName`. The `masterName` alone may not apply the background color.
3. **KPI card text must fit inside the card.** Number: max 6 characters. Label: max 15 characters. If longer, abbreviate.
4. **Chart labels must not overlap.** Use `dataLabelPosition: "outEnd"` for bar charts. For pie charts, use `showPercent: true` with `dataLabelPosition: "bestFit"`. Keep legend outside chart area.
5. **Brand slides (Statement, Section, Cover, Closing) MUST have `slide.background` set.** Example: `slide.background = { color: "D2D2C6" };`

## CRITICAL: Slide Layout Setup

```javascript
let pres = new pptxgen();
pres.layout = "LAYOUT_16x9";  // ★★★ MUST be LAYOUT_16x9 (10" × 5.625") ★★★
// NEVER use LAYOUT_WIDE (13.3" × 7.5") — all coordinates assume 10" width
```

## WED Design Constants

```javascript
const C = {
  BEIGE_LIGHT: "D2D2C6",
  BEIGE_DARK:  "6D695D",
  BLACK:       "000000",
  WHITE:       "FFFFFF",
};

const CHART_COLORS = [C.BEIGE_DARK, C.BEIGE_LIGHT, C.BLACK];

const F = { title: "Zen Kaku Gothic New", body: "Zen Kaku Gothic New" };

const S = { title: 28, subtitle: 22, body: 18, kpiLabel: 16, footnote: 14, kpiNum: 54 };

const M = {
  left: 0.60,
  top: 0.45,
  contentY: 1.1,   // ★ content start (below title area)
  maxW: 8.80,
};
// CRITICAL: contentY must be >= 1.1" to avoid overlapping with title
```

## Logo Files

ロゴ画像は `assets/logos/` に格納。背景色に応じて使い分ける:

| 背景色 | ロゴファイル | 説明 |
|--------|------------|------|
| `D2D2C6` / `FFFFFF` | `assets/logos/WED-Logo-primary.png` | 黒ロゴ（★デフォルト） |
| `6D695D` / `000000` | `assets/logos/Logo02.png` | 白シンボルマーク |
| Closing中央 | `assets/logos/Logo01.png` | ベージュBGシンボルマーク |

## WED Slide Masters

```javascript
pres.defineSlideMaster({
  title: "WED_COVER",
  background: { color: C.BEIGE_LIGHT },
  objects: [
    // WEDロゴ（右上、黒ロゴ on ベージュ）
    { image: { path: "assets/logos/WED-Logo-primary.png", x: 7.8, y: 0.25, w: 1.8, h: 0.45 }},
  ],
});

pres.defineSlideMaster({
  title: "WED_CONTENT",
  background: { color: C.WHITE },
});

pres.defineSlideMaster({
  title: "WED_BRAND",
  background: { color: C.BEIGE_LIGHT },
});

pres.defineSlideMaster({
  title: "WED_SECTION",
  background: { color: C.BEIGE_DARK },
  objects: [
    // WEDロゴ（右上、白ロゴ on ダーク背景）
    { image: { path: "assets/logos/Logo02.png", x: 8.5, y: 0.25, w: 0.8, h: 0.8 }},
  ],
});

pres.defineSlideMaster({
  title: "WED_CLOSING",
  background: { color: C.BEIGE_LIGHT },
  objects: [
    // WEDシンボルマーク（中央）
    { image: { path: "assets/logos/Logo01.png", x: 3.8, y: 1.5, w: 2.4, h: 2.4 }},
    }}},
  ],
});
```

## WED Helper Functions — Structural Slides

### Cover Slide（表紙）

```javascript
function makeCoverSlide(title, subtitle, date) {
  let slide = pres.addSlide({ masterName: "WED_COVER" });
  slide.background = { color: C.BEIGE_LIGHT };  // ★ 明示設定
  slide.addText(title, {
    x: 0.60, y: 3.5, w: 8.80, h: 1.2,
    fontSize: 36, fontFace: F.title, bold: true,
    color: C.BLACK, align: "left", valign: "bottom", wrap: true,
  });
  if (subtitle) slide.addText(subtitle, {
    x: 0.60, y: 4.7, w: 6.0, h: 0.5,
    fontSize: S.kpiLabel, fontFace: F.body,
    color: C.BEIGE_DARK, align: "left",
  });
  if (date) slide.addText(date, {
    x: 7.0, y: 5.0, w: 2.5, h: 0.35,
    fontSize: S.footnote, fontFace: F.body,
    color: C.BEIGE_DARK, align: "right",
  });
  return slide;
}
```

### Table of Contents（目次）

```javascript
function makeTocSlide(items) {
  let slide = pres.addSlide({ masterName: "WED_COVER" });
  slide.background = { color: C.BEIGE_LIGHT };  // ★ 明示設定
  slide.addText("INDEX", {
    x: 0.60, y: 0.8, w: 3.0, h: 1.0,
    fontSize: 42, fontFace: F.title, bold: true,
    color: C.BLACK, align: "left",
  });
  items.forEach((item, i) => {
    const y = 1.5 + i * 0.55;
    slide.addText(String(i + 1).padStart(2, "0"), {
      x: 4.0, y, w: 0.6, h: 0.44,
      fontSize: S.body, fontFace: F.title, bold: true,
      color: C.BEIGE_DARK, align: "right", valign: "middle",
    });
    slide.addText(item, {
      x: 4.8, y, w: 4.5, h: 0.44,
      fontSize: S.body, fontFace: F.body,
      color: C.BLACK, align: "left", valign: "middle",
    });
    slide.addShape(pres.shapes.LINE, {
      x: 4.8, y: y + 0.44, w: 4.5, h: 0,
      line: { color: C.BEIGE_DARK, width: 0.5 },
    });
  });
  return slide;
}
```

### Section Divider（セクション区切り）

```javascript
function makeSectionSlide(sectionTitle, sectionNumber) {
  let slide = pres.addSlide({ masterName: "WED_SECTION" });
  slide.background = { color: C.BEIGE_DARK };  // ★ 明示設定
  if (sectionNumber) slide.addText(String(sectionNumber).padStart(2, "0"), {
    x: 0.60, y: 3.0, w: 2.0, h: 0.8,
    fontSize: 48, fontFace: F.title, bold: true,
    color: C.WHITE, align: "left",
  });
  slide.addText(sectionTitle, {
    x: 0.60, y: 3.8, w: 8.80, h: 0.9,
    fontSize: 28, fontFace: F.title, bold: true,
    color: C.WHITE, align: "left", valign: "middle",
  });
  return slide;
}
```

### Closing Slide（クロージング）

```javascript
function makeClosingSlide(title) {
  let slide = pres.addSlide({ masterName: "WED_CLOSING" });
  slide.background = { color: C.BEIGE_LIGHT };  // ★ 明示設定
  if (title) slide.addText(title, {
    x: 0, y: 3.2, w: 10.0, h: 0.5,
    fontSize: S.subtitle, fontFace: F.title, bold: true,
    color: C.BLACK, align: "center",
  });
  slide.addText("© WED, Inc.", {
    x: 7.0, y: 5.0, w: 2.5, h: 0.3,
    fontSize: S.footnote, fontFace: F.body,
    color: C.BEIGE_DARK, align: "right",
  });
  return slide;
}
```

## WED Helper Functions — Content Slides

### Title + Breadcrumb

```javascript
function addTitle(slide, text, breadcrumb) {
  slide.addText(text, {
    x: M.left, y: M.top, w: M.maxW, h: 0.5,
    fontSize: S.title, fontFace: F.title, bold: true,
    color: C.BLACK, align: "left", valign: "top",
  });
  if (breadcrumb) slide.addText(breadcrumb, {
    x: M.left, y: 0.15, w: 5.0, h: 0.25,
    fontSize: S.kpiLabel, fontFace: F.body,
    color: C.BEIGE_DARK, align: "left",
  });
}

function addFootnote(slide, text) {
  slide.addText(text, {
    x: M.left, y: 5.2, w: M.maxW, h: 0.3,
    fontSize: S.footnote, fontFace: F.body,
    color: C.BEIGE_DARK, align: "right",
  });
}
```

### KPI Card

**Constraints**: number max 6 chars, label max 15 chars, card height ≥ 2.5". If text is too long, abbreviate.

```javascript
function addKpiCard(slide, x, y, w, h, number, label, unit) {
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, fill: { color: C.WHITE }, rectRadius: 0.10,
  });
  const numText = [{ text: String(number), options: {
    fontSize: S.kpiNum, fontFace: F.title, bold: true, color: C.BEIGE_DARK,
  }}];
  if (unit) numText.push({ text: unit, options: {
    fontSize: S.subtitle, fontFace: F.body, color: C.BEIGE_DARK,
  }});
  slide.addText(numText, {
    x: x + 0.15, y: y + 0.3, w: w - 0.3, h: 0.8,
    align: "left", valign: "middle", margin: 0,
  });
  slide.addText(label, {
    x: x + 0.15, y: y + h - 0.6, w: w - 0.3, h: 0.4,
    fontSize: S.footnote, fontFace: F.body, color: C.BEIGE_DARK, align: "left",
  });
}
```

### KPI Dashboard Slide

```javascript
function makeKpiDashboardSlide(title, kpis, insight, source, breadcrumb) {
  let slide = pres.addSlide({ masterName: "WED_CONTENT" });
  addTitle(slide, title, breadcrumb);
  const n = kpis.length, gap = 0.2;
  const cardW = (M.maxW - (n - 1) * gap) / n;
  kpis.forEach((kpi, i) => {
    addKpiCard(slide, M.left + i * (cardW + gap), M.contentY, cardW, 2.2,
      kpi.number, kpi.label, kpi.unit || "");
  });
  if (insight) slide.addText(insight, {
    x: M.left, y: 3.5, w: M.maxW, h: 1.2,
    fontSize: S.body, fontFace: F.body, color: C.BLACK, wrap: true,
  });
  if (source) addFootnote(slide, source);
}
```

### Statement Slide

```javascript
function makeStatementSlide(statement, subText) {
  let slide = pres.addSlide({ masterName: "WED_BRAND" });
  slide.background = { color: C.BEIGE_LIGHT };  // ★ 明示設定
  slide.addText(statement, {
    x: M.left, y: 1.5, w: M.maxW, h: 1.2,
    fontSize: S.title, fontFace: F.title, bold: true,
    color: C.BLACK, wrap: true,
  });
  if (subText) slide.addText(subText, {
    x: M.left, y: 3.0, w: M.maxW, h: 0.8,
    fontSize: S.body, fontFace: F.body, color: C.BEIGE_DARK, wrap: true,
  });
}
```

### Table with WED Styling

```javascript
function makeTableSlide(title, headers, rows, source, breadcrumb) {
  let slide = pres.addSlide({ masterName: "WED_CONTENT" });
  addTitle(slide, title, breadcrumb);
  const tableRows = [
    headers.map(h => ({ text: h, options: {
      fill: { color: C.BEIGE_DARK }, color: C.WHITE,
      fontSize: S.body, fontFace: F.body, bold: true, align: "center",
    }})),
    ...rows.map((row, ri) => row.map(cell => ({
      text: String(cell), options: {
        fill: { color: ri % 2 === 0 ? C.WHITE : C.BEIGE_LIGHT },
        color: C.BLACK, fontSize: S.body, fontFace: F.body,
      }
    }))),
  ];
  slide.addTable(tableRows, {
    x: M.left, y: M.contentY, w: M.maxW,
    border: { pt: 1, color: C.BEIGE_DARK },
    colW: headers.map(() => M.maxW / headers.length),
  });
  if (source) addFootnote(slide, source);
}
```

### Chart with WED Colors

```javascript
function makeBarChartSlide(title, categories, seriesData, insight, source, breadcrumb) {
  let slide = pres.addSlide({ masterName: "WED_CONTENT" });
  addTitle(slide, title, breadcrumb);
  slide.addChart(pres.charts.BAR, seriesData.map(s => ({
    name: s.name, labels: categories, values: s.values,
  })), {
    x: M.left, y: M.contentY, w: M.maxW, h: 3.0, barDir: "col",
    chartColors: CHART_COLORS.slice(0, seriesData.length),
    valGridLine: { color: C.BEIGE_LIGHT, size: 0.5 },
    catGridLine: { style: "none" },
    catAxisLabelColor: C.BEIGE_DARK, valAxisLabelColor: C.BEIGE_DARK,
    showLegend: seriesData.length > 1, legendPos: "b",
    showValue: true, dataLabelPosition: "outEnd", dataLabelColor: C.BEIGE_DARK,
  });
  if (insight) slide.addText(insight, {
    x: M.left, y: 4.3, w: M.maxW, h: 0.5,
    fontSize: S.body, fontFace: F.body, color: C.BLACK,
  });
  if (source) addFootnote(slide, source);
}
```

### Process Flow

```javascript
function makeProcessFlowSlide(title, steps, keyIndex, source, breadcrumb) {
  let slide = pres.addSlide({ masterName: "WED_CONTENT" });
  addTitle(slide, title, breadcrumb);
  const n = steps.length, gap = 0.4;
  const nodeW = (M.maxW - (n - 1) * gap) / n;
  steps.forEach((step, i) => {
    const x = M.left + i * (nodeW + gap), isKey = (i === keyIndex);
    slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x, y: M.contentY + 0.5, w: nodeW, h: 1.5,
      fill: { color: isKey ? C.BEIGE_DARK : C.WHITE }, rectRadius: 0.10,
    });
    slide.addText(step, {
      x, y: M.contentY + 0.5, w: nodeW, h: 1.5,
      fontSize: S.body, fontFace: F.body, bold: true,
      color: isKey ? C.WHITE : C.BLACK, align: "center", valign: "middle", wrap: true, margin: 0,
    });
    if (i < n - 1) slide.addShape(pres.shapes.RIGHT_ARROW, {
      x: x + nodeW + 0.05, y: M.contentY + 1.1, w: 0.3, h: 0.2,
      fill: { color: C.BEIGE_DARK },
    });
  });
  if (source) addFootnote(slide, source);
}
```

### Comparison 50/50

```javascript
function makeComparisonSlide(title, leftHeader, rightHeader, leftItems, rightItems, source, breadcrumb) {
  let slide = pres.addSlide({ masterName: "WED_CONTENT" });
  addTitle(slide, title, breadcrumb);
  slide.addText(leftHeader, { x: M.left, y: M.contentY, w: 4.0, h: 0.5,
    fontSize: S.subtitle, fontFace: F.title, bold: true, color: C.BLACK });
  slide.addText(rightHeader, { x: 5.20, y: M.contentY, w: 4.0, h: 0.5,
    fontSize: S.subtitle, fontFace: F.title, bold: true, color: C.BEIGE_DARK });
  slide.addShape(pres.shapes.LINE, { x: 4.90, y: M.contentY, w: 0, h: 3.5,
    line: { color: C.BEIGE_DARK, width: 2 } });
  leftItems.forEach((item, i) => slide.addText(`• ${item}`, {
    x: M.left, y: M.contentY + 0.6 + i * 0.6, w: 4.0, h: 0.5,
    fontSize: S.body, fontFace: F.body, color: C.BLACK, wrap: true }));
  rightItems.forEach((item, i) => slide.addText(`• ${item}`, {
    x: 5.20, y: M.contentY + 0.6 + i * 0.6, w: 4.0, h: 0.5,
    fontSize: S.body, fontFace: F.body, color: C.BLACK, wrap: true }));
  if (source) addFootnote(slide, source);
}
```

### Highlight Box

```javascript
function addHighlightBox(slide, text, y) {
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: 1.5, y: y || 3.5, w: 7.0, h: 0.8,
    fill: { color: C.BEIGE_DARK }, rectRadius: 0.10,
  });
  slide.addText(text, {
    x: 1.5, y: y || 3.5, w: 7.0, h: 0.8,
    fontSize: S.body, fontFace: F.body, color: C.WHITE,
    align: "center", valign: "middle", margin: 0,
  });
}
```
