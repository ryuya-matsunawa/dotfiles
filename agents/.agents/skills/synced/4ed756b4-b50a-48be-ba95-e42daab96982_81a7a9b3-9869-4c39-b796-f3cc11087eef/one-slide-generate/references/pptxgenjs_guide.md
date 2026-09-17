# PptxGenJS — ONE Brand Extensions

The built-in `pptx` skill's `pptxgenjs.md` provides the full PptxGenJS API reference (text, shapes, images, icons, charts, tables, slide masters, pitfalls). This file adds **ONE-specific constants and helper functions** only.

## ★★★ MANDATORY RULES ★★★

1. **ALWAYS use the helper functions below.** Do NOT hardcode x/y/w/h coordinates manually.
2. **ALWAYS set `slide.background` explicitly** in addition to `masterName`. Example: `slide.background = { color: "F0F3F6" };`
3. **KPI card text must fit.** Number: max 6 characters. Label: max 15 characters.
4. **Chart labels must not overlap.** Use `dataLabelPosition: "outEnd"` for bar charts, `"bestFit"` for pie.
5. **Brand slides (Statement, Section, Cover, Closing) MUST have explicit `slide.background`.**

## CRITICAL: Slide Layout Setup

```javascript
let pres = new pptxgen();
pres.layout = "LAYOUT_16x9";  // ★★★ MUST be LAYOUT_16x9 (10" × 5.625") ★★★
// NEVER use LAYOUT_WIDE (13.3" × 7.5") — all coordinates assume 10" width
```

**`pres.layout = "LAYOUT_16x9"` を必ず最初に設定すること。省略すると LAYOUT_WIDE になり、全要素が左寄りになる。**

## ONE Design Constants

```javascript
// Colors (NO "#" prefix)
const C = {
  GREEN:       "3EE3A6",
  DARK_GREEN:  "00D184",
  LIGHT_GREEN: "D7FFF0",
  BLACK:       "000000",
  LIGHT_GRAY:  "F0F3F6",
  DARK_GRAY:   "8C909B",
  WHITE:       "FFFFFF",
};

const CHART_COLORS = [C.GREEN, C.DARK_GREEN, C.DARK_GRAY, C.LIGHT_GRAY, C.BLACK];

const F = { title: "Noto Sans JP", body: "Noto Sans JP", kpi: "Arial Black" };

const S = { title: 28, subtitle: 22, body: 18, kpiNum: 54, kpiLabel: 16, footnote: 14 };

const M = {
  left: 0.56,
  top: 0.45,       // タイトル開始y
  contentY: 1.1,   // ★コンテンツ開始y（タイトル+アクセント+gap の下）
  maxW: 8.88,
};
// CRITICAL: contentY must be >= 1.1" to avoid overlapping with title (y=0.45, h=0.5) and accent line (y=0.72)
// Title area: y=0.45 to y=0.95
// Accent line: y=0.72
// Content start: y=1.1 (safe zone)
```

## ONE Slide Masters

```javascript
// コンテンツスライド（白背景、データ表示用）
pres.defineSlideMaster({
  title: "ONE_CONTENT",
  background: { color: C.WHITE },
});

// ブランドスライド（ライトグレー背景、ステートメント・ポーズ用）
pres.defineSlideMaster({
  title: "ONE_BRAND",
  background: { color: C.LIGHT_GRAY },
});

// 表紙（ダーク背景 #1F2020）
pres.defineSlideMaster({
  title: "ONE_COVER",
  background: { color: "1F2020" },
  objects: [
    // ONEロゴ（テキストで再現）
    { text: { text: "ONE", options: {
      x: 0.17, y: 0.17, w: 2.3, h: 0.3,
      fontSize: 20, fontFace: "Brandon Grotesque", bold: true,
      color: C.WHITE, align: "left",
    }}},
    // グリーンアクセントライン（下部）
    { rect: { x: 0, y: 5.3, w: 10.0, h: 0.04, fill: { color: C.DARK_GREEN } }},
  ],
});

// セクション区切り（ダーク背景）
pres.defineSlideMaster({
  title: "ONE_SECTION",
  background: { color: "1F2020" },
  objects: [
    { text: { text: "ONE", options: {
      x: 0.17, y: 0.17, w: 2.3, h: 0.3,
      fontSize: 20, fontFace: "Brandon Grotesque", bold: true,
      color: C.WHITE, align: "left",
    }}},
  ],
});

// クロージング（ライトグレー背景 + CTAボタン）
pres.defineSlideMaster({
  title: "ONE_CLOSING",
  background: { color: C.LIGHT_GRAY },
  objects: [
    // ONEロゴ中央
    { text: { text: "ONE", options: {
      x: 3.5, y: 1.8, w: 3.0, h: 0.6,
      fontSize: 32, fontFace: "Brandon Grotesque", bold: true,
      color: C.BLACK, align: "center",
    }}},
  ],
});
```

## ONE Helper Functions — Structural Slides

### Cover Slide（表紙）

```javascript
function makeCoverSlide(title, subtitle, date) {
  let slide = pres.addSlide({ masterName: "ONE_COVER" });
  slide.background = { color: "1F2020" };  // ★ 明示設定
  // メインタイトル
  slide.addText(title, {
    x: 0.07, y: 2.05, w: 5.0, h: 1.1,
    fontSize: 32, fontFace: F.title, bold: true,
    color: C.WHITE, align: "left", valign: "middle", wrap: true,
  });
  // サブタイトル
  if (subtitle) slide.addText(subtitle, {
    x: 0.17, y: 3.2, w: 5.0, h: 0.5,
    fontSize: 18, fontFace: F.body,
    color: C.DARK_GRAY, align: "left",
  });
  // 日付（右下）
  if (date) slide.addText(date, {
    x: 5.1, y: 4.9, w: 2.5, h: 0.4,
    fontSize: 16, fontFace: F.body,
    color: C.DARK_GRAY, align: "right",
  });
  return slide;
}
```

### Table of Contents（目次）

```javascript
function makeTocSlide(items) {
  let slide = pres.addSlide({ masterName: "ONE_SECTION" });
  slide.background = { color: "1F2020" };  // ★ 明示設定
  // 目次タイトル
  slide.addText("Contents", {
    x: 0.56, y: 0.5, w: 4.0, h: 0.6,
    fontSize: 24, fontFace: F.title, bold: true, color: C.WHITE,
  });
  // 目次項目
  items.forEach((item, i) => {
    const y = 1.5 + i * 0.55;
    // 番号
    slide.addText(String(i + 1).padStart(2, "0"), {
      x: 1.0, y, w: 0.6, h: 0.44,
      fontSize: 18, fontFace: F.kpi, bold: true,
      color: C.DARK_GREEN, align: "right", valign: "middle",
    });
    // 項目テキスト
    slide.addText(item, {
      x: 1.8, y, w: 5.5, h: 0.44,
      fontSize: 18, fontFace: F.body,
      color: C.WHITE, align: "left", valign: "middle",
    });
    // 区切り線
    slide.addShape(pres.shapes.LINE, {
      x: 1.8, y: y + 0.44, w: 5.5, h: 0,
      line: { color: C.DARK_GRAY, width: 0.5 },
    });
  });
  return slide;
}
```

### Section Divider（セクション区切り）

```javascript
function makeSectionSlide(sectionTitle, sectionNumber) {
  let slide = pres.addSlide({ masterName: "ONE_SECTION" });
  slide.background = { color: "1F2020" };  // ★ 明示設定
  // セクション番号
  if (sectionNumber) slide.addText(String(sectionNumber).padStart(2, "0"), {
    x: 0.56, y: 1.5, w: 2.0, h: 0.8,
    fontSize: 48, fontFace: F.kpi, bold: true,
    color: C.DARK_GREEN, align: "left",
  });
  // セクションタイトル
  slide.addText(sectionTitle, {
    x: 0.34, y: 2.35, w: 9.3, h: 0.9,
    fontSize: 32, fontFace: F.title, bold: true,
    color: C.WHITE, align: "center", valign: "middle",
  });
  return slide;
}
```

### Closing Slide（クロージング）

```javascript
function makeClosingSlide(title, contactEmail, contactUrl) {
  let slide = pres.addSlide({ masterName: "ONE_CLOSING" });
  slide.background = { color: C.LIGHT_GRAY };  // ★ 明示設定
  // タイトル
  slide.addText(title, {
    x: 0, y: 2.5, w: 10.0, h: 0.5,
    fontSize: 24, fontFace: F.title, bold: true,
    color: C.BLACK, align: "center",
  });
  // CTAボタン（メール）
  if (contactEmail) {
    slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x: 2.8, y: 3.3, w: 2.1, h: 0.5,
      fill: { color: C.WHITE }, rectRadius: 0.04,
    });
    slide.addText(contactEmail, {
      x: 2.8, y: 3.3, w: 2.1, h: 0.5,
      fontSize: 14, fontFace: F.body, color: C.BLACK,
      align: "center", valign: "middle", margin: 0,
    });
  }
  // CTAボタン（URL）
  if (contactUrl) {
    slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x: 5.1, y: 3.3, w: 2.1, h: 0.5,
      fill: { color: C.WHITE }, rectRadius: 0.04,
    });
    slide.addText(contactUrl, {
      x: 5.1, y: 3.3, w: 2.1, h: 0.5,
      fontSize: 14, fontFace: F.body, color: C.BLACK,
      align: "center", valign: "middle", margin: 0,
    });
  }
  return slide;
}
```

## ONE Helper Functions — Content Slides

### Title + Green Accent

```javascript
function addTitle(slide, text) {
  slide.addText(text, {
    x: M.left, y: M.top, w: M.maxW, h: 0.5,
    fontSize: S.title, fontFace: F.title, bold: true,
    color: C.BLACK, align: "left", valign: "top",
  });
}

function addGreenAccent(slide) {
  slide.addShape(pres.shapes.LINE, {
    x: M.left, y: 0.72, w: 1.2, h: 0,
    line: { color: C.DARK_GREEN, width: 3 },
  });
}

function addFootnote(slide, text) {
  slide.addText(text, {
    x: M.left, y: 5.2, w: M.maxW, h: 0.3,
    fontSize: S.footnote, fontFace: F.body,
    color: C.DARK_GRAY, align: "right",
  });
}
```

### KPI Card

```javascript
function addKpiCard(slide, x, y, w, h, number, label, unit, delta) {
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, fill: { color: C.LIGHT_GRAY }, rectRadius: 0.08,
  });
  const numText = [{ text: String(number), options: {
    fontSize: S.kpiNum, fontFace: F.kpi, bold: true, color: C.DARK_GREEN,
  }}];
  if (unit) numText.push({ text: unit, options: {
    fontSize: 20, fontFace: F.body, color: C.DARK_GRAY,
  }});
  slide.addText(numText, {
    x: x + 0.1, y: y + 0.3, w: w - 0.2, h: 0.8,
    align: "left", valign: "middle", margin: 0,
  });
  slide.addText(label, {
    x: x + 0.1, y: y + h - 0.6, w: w - 0.2, h: 0.4,
    fontSize: S.kpiLabel, fontFace: F.body, color: C.DARK_GRAY, align: "left",
  });
  if (delta) slide.addText(delta, {
    x: x + 0.1, y: y + 1.2, w: 1.0, h: 0.3,
    fontSize: 14, fontFace: F.body, color: C.DARK_GREEN, align: "left",
  });
}
```

### KPI-Row Slide (3-4 cards)

```javascript
function makeKpiRowSlide(title, kpis, insight, source) {
  let slide = pres.addSlide({ masterName: "ONE_CONTENT" });
  addTitle(slide, title);
  addGreenAccent(slide);
  const n = kpis.length, gap = 0.2;
  const cardW = (M.maxW - (n - 1) * gap) / n;
  kpis.forEach((kpi, i) => {
    addKpiCard(slide, M.left + i * (cardW + gap), M.contentY, cardW, 2.5,
      kpi.number, kpi.label, kpi.unit || "", kpi.delta || "");
  });
  if (insight) slide.addText(insight, {
    x: M.left, y: 3.5, w: M.maxW, h: 1.5,
    fontSize: S.body, fontFace: F.body, color: C.BLACK, wrap: true,
  });
  if (source) addFootnote(slide, source);
}
```

### Statement Slide

```javascript
function makeStatementSlide(statement, subText) {
  let slide = pres.addSlide({ masterName: "ONE_BRAND" });
  slide.background = { color: C.LIGHT_GRAY };  // ★ 明示設定
  slide.addText(statement, {
    x: M.left, y: 1.5, w: M.maxW, h: 1.0,
    fontSize: S.title, fontFace: F.title, bold: true,
    color: C.BLACK, wrap: true,
  });
  if (subText) slide.addText(subText, {
    x: M.left, y: 2.8, w: M.maxW, h: 0.8,
    fontSize: 20, fontFace: F.body, color: C.DARK_GRAY, wrap: true,
  });
}
```

### Table with ONE Styling

```javascript
function makeTableSlide(title, headers, rows, highlightCells, source) {
  let slide = pres.addSlide({ masterName: "ONE_CONTENT" });
  addTitle(slide, title);
  addGreenAccent(slide);
  const hl = highlightCells || [];
  const isHl = (r, c) => hl.some(h => h[0] === r && h[1] === c);

  const tableRows = [
    headers.map(h => ({ text: h, options: {
      fill: { color: C.BLACK }, color: C.WHITE,
      fontSize: S.body, fontFace: F.body, bold: true, align: "center",
    }})),
    ...rows.map((row, ri) => row.map((cell, ci) => ({
      text: String(cell), options: {
        fill: { color: isHl(ri, ci) ? C.LIGHT_GREEN : (ri % 2 === 0 ? C.WHITE : C.LIGHT_GRAY) },
        color: C.BLACK, fontSize: S.body, fontFace: F.body,
      }
    }))),
  ];
  slide.addTable(tableRows, {
    x: M.left, y: M.contentY, w: M.maxW,
    border: { pt: 1, color: C.DARK_GRAY },
    colW: headers.map(() => M.maxW / headers.length),
  });
  if (source) addFootnote(slide, source);
}
```

### Chart with ONE Colors

```javascript
function makeBarChartSlide(title, categories, seriesData, insight, source) {
  let slide = pres.addSlide({ masterName: "ONE_CONTENT" });
  addTitle(slide, title);
  addGreenAccent(slide);
  slide.addChart(pres.charts.BAR, seriesData.map(s => ({
    name: s.name, labels: categories, values: s.values,
  })), {
    x: M.left, y: M.contentY, w: M.maxW, h: 3.0, barDir: "col",
    chartColors: CHART_COLORS.slice(0, seriesData.length),
    valGridLine: { color: C.LIGHT_GRAY, size: 0.5 },
    catGridLine: { style: "none" },
    catAxisLabelColor: C.DARK_GRAY, valAxisLabelColor: C.DARK_GRAY,
    showLegend: seriesData.length > 1, legendPos: "b",
  });
  if (insight) slide.addText(insight, {
    x: M.left, y: 4.1, w: M.maxW, h: 0.5, fontSize: S.body, fontFace: F.body, color: C.BLACK,
  });
  if (source) addFootnote(slide, source);
}
```

### Process Flow

```javascript
function makeProcessFlowSlide(title, steps, keyIndex, source) {
  let slide = pres.addSlide({ masterName: "ONE_CONTENT" });
  addTitle(slide, title);
  addGreenAccent(slide);
  const n = steps.length, gap = 0.4;
  const nodeW = (M.maxW - (n - 1) * gap) / n;
  steps.forEach((step, i) => {
    const x = M.left + i * (nodeW + gap), isKey = (i === keyIndex);
    slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x, y: M.contentY + 0.5, w: nodeW, h: 1.5,
      fill: { color: isKey ? C.DARK_GREEN : C.LIGHT_GRAY }, rectRadius: 0.08,
    });
    slide.addText(step, {
      x, y: M.contentY + 0.5, w: nodeW, h: 1.5,
      fontSize: S.body, fontFace: F.body, bold: true,
      color: isKey ? C.WHITE : C.BLACK, align: "center", valign: "middle", wrap: true, margin: 0,
    });
    if (i < n - 1) slide.addShape(pres.shapes.RIGHT_ARROW, {
      x: x + nodeW + 0.05, y: M.contentY + 1.1, w: 0.3, h: 0.2, fill: { color: C.DARK_GRAY },
    });
  });
  if (source) addFootnote(slide, source);
}
```

### Comparison 50/50

```javascript
function makeComparisonSlide(title, leftHeader, rightHeader, leftItems, rightItems, source) {
  let slide = pres.addSlide({ masterName: "ONE_CONTENT" });
  addTitle(slide, title);
  addGreenAccent(slide);
  slide.addText(leftHeader, { x: M.left, y: M.contentY, w: 4.1, h: 0.5,
    fontSize: 24, fontFace: F.title, bold: true, color: C.BLACK });
  slide.addText(rightHeader, { x: 5.16, y: M.contentY, w: 4.1, h: 0.5,
    fontSize: 24, fontFace: F.title, bold: true, color: C.DARK_GREEN });
  slide.addShape(pres.shapes.LINE, { x: 4.86, y: M.contentY, w: 0, h: 3.8,
    line: { color: C.DARK_GRAY, width: 2 } });
  leftItems.forEach((item, i) => slide.addText(`• ${item}`, {
    x: M.left, y: M.contentY + 0.6 + i * 0.6, w: 4.1, h: 0.5,
    fontSize: S.body, fontFace: F.body, color: C.BLACK, wrap: true }));
  rightItems.forEach((item, i) => slide.addText(`• ${item}`, {
    x: 5.16, y: M.contentY + 0.6 + i * 0.6, w: 4.1, h: 0.5,
    fontSize: S.body, fontFace: F.body, color: C.BLACK, wrap: true }));
  if (source) addFootnote(slide, source);
}
```

### Highlight Box

```javascript
function addHighlightBox(slide, text, y) {
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: 1.5, y: y || 3.5, w: 7.0, h: 0.8,
    fill: { color: C.DARK_GRAY }, rectRadius: 0.08,
  });
  slide.addText(text, {
    x: 1.5, y: y || 3.5, w: 7.0, h: 0.8,
    fontSize: 22, fontFace: F.body, color: C.WHITE, align: "center", valign: "middle", margin: 0,
  });
}
```
