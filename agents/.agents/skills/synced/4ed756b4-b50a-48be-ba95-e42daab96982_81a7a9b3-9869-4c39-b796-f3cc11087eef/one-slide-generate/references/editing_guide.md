# ONE Template Editing — Supplement to Built-in pptx Skill

The built-in `pptx` skill's `editing.md` provides the full unpack/pack/clean workflow. This file adds **ONE-specific** information only.

## ONE Template Layout Map

Template: `assets/Theme _ ONE for Business 2025.pptx` (10" × 5.625", 17 layouts)

| Index | Name | BG | Use Case |
|-------|------|----|----------|
| 0 | SECTION_HEADER | White | Cover (user handles) |
| 1 | CUSTOM_3 | White | Section title (centered) |
| 2 | CUSTOM_6 | White | Table of contents |
| 3 | Title & Bullets | White | Title + subtitle (user handles) |
| 4 | **Blank** | White | **All custom content — primary layout** |
| 5 | CUSTOM_2 | `F0F3F6` | Brand/statement slides |
| 6 | CUSTOM | White | Title bar + `00D184` accent line |
| 7 | CUSTOM_5 | White | Title + gray card areas |
| 8 | CUSTOM_1_1 | `F0F3F6` | 3-card layout |
| 9 | CUSTOM_1_1_1 | `F0F3F6` | 4-card layout |
| 10 | CUSTOM_1_1_1_1 | `F0F3F6` | Multi-card variant |
| 11 | CUSTOM_1_1_1_1_2 | `F0F3F6` | Card + chart |
| 12 | CUSTOM_1_1_1_1_1 | `F0F3F6` | Wide card |
| 13 | CUSTOM_1_1_1_1_1_1 | `F0F3F6` | Full content |
| 14 | CUSTOM_7 | White | Table layout |
| 15 | CUSTOM_4 | `F0F3F6` | Closing (user handles) |
| 16 | CUSTOM_4_1_1_1_1 | `F0F3F6` | Closing variant |

## Layout Selection Guide

- Data-heavy (charts, tables, KPIs) → **Layout 4 (Blank)** + programmatic shapes
- Statement/pause → **Layout 5 (CUSTOM_2)** with `F0F3F6` BG
- Card grids → **Layouts 8-13** (CUSTOM_1_1 variants)
- Tables → **Layout 14 (CUSTOM_7)** or Layout 4

## ONE Font Size Map (XML `sz` values)

| Element | pt | XML sz |
|---------|-----|--------|
| KPI number | 48-72 | 4800-7200 |
| Slide title | 28-32 | 2800-3200 |
| Sub-header | 20-24 | 2000-2400 |
| Body | 18-20 | 1800-2000 |
| KPI label | 16 | 1600 |
| Footnote | 14 | 1400 |

## ONE Color Map (XML `srgbClr` values)

| Token | val |
|-------|-----|
| ONE_GREEN | 3EE3A6 |
| ONE_DARK_GREEN | 00D184 |
| ONE_LIGHT_GREEN | D7FFF0 |
| BLACK | 000000 |
| ONE_LIGHT_GRAY | F0F3F6 |
| ONE_DARK_GRAY | 8C909B |
| WHITE | FFFFFF |

## ONE XML Shape Example — KPI Card

```xml
<p:sp>
  <p:nvSpPr>
    <p:cNvPr id="100" name="Card1"/>
    <p:cNvSpPr/>
    <p:nvPr/>
  </p:nvSpPr>
  <p:spPr>
    <a:xfrm>
      <a:off x="508000" y="771525"/>
      <a:ext cx="2600000" cy="1500000"/>
    </a:xfrm>
    <a:prstGeom prst="roundRect">
      <a:avLst>
        <a:gd name="adj" fmla="val 5000"/>
      </a:avLst>
    </a:prstGeom>
    <a:solidFill>
      <a:srgbClr val="F0F3F6"/>
    </a:solidFill>
    <a:ln><a:noFill/></a:ln>
  </p:spPr>
  <p:txBody>
    <a:bodyPr wrap="square" lIns="72000" tIns="72000" rIns="72000" bIns="72000"/>
    <a:p>
      <a:r>
        <a:rPr lang="ja-JP" sz="4800" b="1">
          <a:solidFill><a:srgbClr val="00D184"/></a:solidFill>
          <a:latin typeface="Arial Black"/>
        </a:rPr>
        <a:t>1,200万</a:t>
      </a:r>
    </a:p>
  </p:txBody>
</p:sp>
```

## Japanese Text in XML

Both `<a:latin>` AND `<a:ea>` must be set:

```xml
<a:rPr lang="ja-JP" sz="2800" b="1">
  <a:solidFill><a:srgbClr val="000000"/></a:solidFill>
  <a:latin typeface="Noto Sans JP"/>
  <a:ea typeface="Noto Sans JP"/>
</a:rPr>
```
