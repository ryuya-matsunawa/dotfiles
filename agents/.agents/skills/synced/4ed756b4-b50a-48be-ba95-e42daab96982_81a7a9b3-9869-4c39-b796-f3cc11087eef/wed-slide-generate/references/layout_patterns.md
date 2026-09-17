# WED Slide Layout Patterns

Based on cone-c-slide design patterns, adapted for WED's 4-color brand system. All coordinates for LAYOUT_16x9 (10" × 5.625").

## Pattern Selection Guide

### テキスト量で判断
- **少量** → KPI Dashboard, 横並びカード
- **中量** → Left-Right 60/40, Statement+Evidence
- **多量** → Full-Width Table, 縦並び

### データの種類で判断
- **比較** → Comparison 50/50, 2×2 Matrix, Table
- **推移** → Line Chart, Timeline
- **構成** → Pie Chart, Stacked Bar
- **プロセス** → Process Flow, Timeline

---

## Structural Patterns

### Cover (WED_COVER)
BG: `D2D2C6`. Title bottom-left (36pt), WED logo top-right, date bottom-right.

### TOC (WED_COVER)
BG: `D2D2C6`. "INDEX" large left, numbered items right.

### Section Divider (WED_SECTION)
BG: `6D695D`. Section number (48pt white) + title (28pt white) bottom-left.

### Closing (WED_CLOSING)
BG: `D2D2C6`. "WED" center, © notice.

---

## Content Patterns

### P01: KPI Dashboard (PRIMARY — 30%+)
3-4 white rounded cards on white BG, KPI number 48-72pt `6D695D`, label 19pt.
```
[  KPI 1  ] [  KPI 2  ] [  KPI 3  ]
[        insight / chart           ]
```
Cards: fill `FFFFFF`, rectRadius 0.10, on `FFFFFF` slide.

### P02: Left-Right 60/40
Left 60%: chart/table. Right 40%: 2-3 takeaways. Divider: 2px `6D695D` vertical.
```
[  Chart / Data  ] | [ Takeaway ]
[  (60% width)   ] | [ Takeaway ]
```

### P03: Statement + Evidence
BG: `D2D2C6`. Top: bold conclusion in white rounded box. Bottom: supporting data.

### P04: Full-Width Table
BG: `FFFFFF`. Header: `6D695D` BG + `FFFFFF` text. Alt-rows: `D2D2C6`/`FFFFFF`. Rounded outer frame. Max 7 rows × 4 cols.

### P05: 2×2 Matrix
4 white rounded quadrants on `D2D2C6` BG, each with label + analysis. Axis lines: 1px `6D695D`.

### P06: Process Flow
3-5 white rounded nodes. Key step: `6D695D` fill + `FFFFFF` text. Connected by `6D695D` arrows (MANDATORY).

### P07: Comparison 50/50
Two equal columns. Left header: `000000`. Right header: `6D695D`. Divider: 2px `6D695D`.

### P08: Bar Chart
Primary: `6D695D`. Secondary: `D2D2C6`. Grid: `D2D2C6` 0.5px. No 3D.

### P09: Line Chart
Line: `6D695D` 3px. Grid: `D2D2C6`. Smooth optional.

### P10: Timeline / Roadmap
Horizontal baseline: 2px `6D695D`. Milestone nodes: white rounded. Key: `6D695D` fill.

---

## Visual Rhythm Rules

1. **Cover**: `D2D2C6` brand-forward
2. **Introduction**: `D2D2C6` statement, generous whitespace
3. **Main body**: `FFFFFF` — dashboards, tables, charts
4. **Transitions**: `D2D2C6` pause slide
5. **Conclusion**: `FFFFFF` — KPI summary + Next Actions

Never stack 3+ dense slides without a `D2D2C6` pause.
