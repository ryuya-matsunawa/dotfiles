# ONE Slide Layout Patterns — 39 Pattern Catalog

Based on the cone-c-slide design pattern system, adapted for ONE brand design. Each pattern includes positioning in PptxGenJS coordinates (10" × 5.625" canvas).

---

## Category 1: 要素間の関係が存在するパターン (22 patterns)

### 1-1. 並列パターン (Parallel)

#### P01: 横並び（3要素）
**用途**: テキスト少量の要素を並べる（アイコン + ラベル + 短文）
**構造**: 3カード水平配置
```
[  Card 1  ] [  Card 2  ] [  Card 3  ]
```
```javascript
// PptxGenJS座標
const cards = [
  { x: 0.56, y: 1.2, w: 2.8, h: 3.0 },
  { x: 3.56, y: 1.2, w: 2.8, h: 3.0 },
  { x: 6.56, y: 1.2, w: 2.8, h: 3.0 },
];
// Card: fill F0F3F6, rectRadius 0.08
// Icon/number: 48pt 00D184, centered top
// Label: 16pt 8C909B, centered bottom
```

#### P02: 横並び（2要素）
**用途**: 対称的な2項目
```javascript
const cards = [
  { x: 0.56, y: 1.2, w: 4.2, h: 3.0 },
  { x: 5.16, y: 1.2, w: 4.2, h: 3.0 },
];
```

#### P03: 横並び（4要素）
**用途**: KPIダッシュボード
```javascript
const cards = [
  { x: 0.56, y: 1.2, w: 2.0, h: 2.5 },
  { x: 2.76, y: 1.2, w: 2.0, h: 2.5 },
  { x: 4.96, y: 1.2, w: 2.0, h: 2.5 },
  { x: 7.16, y: 1.2, w: 2.0, h: 2.5 },
];
```

#### P04: 縦並び
**用途**: テキスト量が多い要素（2-3行/項目）を上下配置
```javascript
const rows = [
  { x: 0.56, y: 1.0, w: 8.88, h: 1.2 },
  { x: 0.56, y: 2.4, w: 8.88, h: 1.2 },
  { x: 0.56, y: 3.8, w: 8.88, h: 1.2 },
];
```

#### P05: 複数羅列（グリッド）
**用途**: 4個以上の要素をグリッド配置
```javascript
// 2×3 grid
const grid = [
  { x: 0.56, y: 1.0, w: 2.8, h: 1.8 }, { x: 3.56, y: 1.0, w: 2.8, h: 1.8 }, { x: 6.56, y: 1.0, w: 2.8, h: 1.8 },
  { x: 0.56, y: 3.0, w: 2.8, h: 1.8 }, { x: 3.56, y: 3.0, w: 2.8, h: 1.8 }, { x: 6.56, y: 3.0, w: 2.8, h: 1.8 },
];
```

---

### 1-2. 比較パターン (Comparison)

#### P06: 規模比較
**用途**: 市場規模やシェアをサイズ差で表現
```
[  大きい円/矩形  ] [ 小さい ]
```
- 大きい要素: fill `3EE3A6`, 数値 48pt `00D184`
- 小さい要素: fill `F0F3F6`, 数値 36pt `000000`

#### P07: 項目比較（Before/After）
**用途**: 導入前後、プランA/B
```
[ Left Column ]  |  [ Right Column ]
   50% width    2px    50% width
```
```javascript
// Left
{ x: 0.56, y: 1.0, w: 4.1, h: 3.8 }
// Divider: line at x=4.86, color 8C909B, width 2px
// Right
{ x: 5.16, y: 1.0, w: 4.1, h: 3.8 }
```

#### P08: 表での比較
**用途**: 複数項目を行列で整理（プラン比較、機能比較）
- Header: `000000` BG, `FFFFFF` text, 18pt bold
- Alt-rows: `FFFFFF` / `F0F3F6`
- Highlight column: `D7FFF0` cells
- Max: 7 rows × 5 cols

---

### 1-3. フローパターン (Flow)

#### P09: 横フロー（アイコン付き）
**用途**: 3-5ステップのプロセス、導入フロー
```
[ Step 1 ] → [ Step 2 ] → [ Step 3 ] → [ Step 4 ]
```
```javascript
// 4ステップの場合
const steps = [
  { x: 0.56, y: 1.8, w: 1.8, h: 1.5 },  // ROUNDED_RECTANGLE, fill F0F3F6
  { x: 2.76, y: 1.8, w: 1.8, h: 1.5 },
  { x: 4.96, y: 1.8, w: 1.8, h: 1.5 },  // key step: fill 00D184, text FFFFFF
  { x: 7.16, y: 1.8, w: 1.8, h: 1.5 },
];
// Arrows between: RIGHT_ARROW shape, fill 8C909B, w: 0.3, h: 0.15
```

#### P10: 縦フロー
**用途**: 横に収まらない場合の上下配置
```javascript
const steps = [
  { x: 2.5, y: 0.8, w: 5.0, h: 0.9 },
  { x: 2.5, y: 1.9, w: 5.0, h: 0.9 },
  { x: 2.5, y: 3.0, w: 5.0, h: 0.9 },
  { x: 2.5, y: 4.1, w: 5.0, h: 0.9 },
];
// DOWN_ARROW between steps
```

#### P11: 箱型フロー
**用途**: 条件分岐、複雑なプロセス
- メインフロー: 横配置
- 分岐: 下方向の矢印で別パス
- 条件ラベル: 14pt `8C909B`

---

### 1-4. サイクルパターン (Cycle)

#### P12: 円型サイクル
**用途**: 少数要素（3-4）の循環
- 要素を円周上に配置
- 矢印で接続（`8C909B`, 2px）
- Key要素: `00D184` fill

#### P13: 四角型サイクル
**用途**: 多数要素（4-6）の循環
- 矩形ノードを四角形に配置
- 矢印で時計回りに接続

---

### 1-5. 構造パターン (Structure)

#### P14: ピラミッド
**用途**: 階層構造、優先度
- 頂点: `00D184`, 小さい
- 底辺: `F0F3F6`, 大きい
- テキスト: 各段中央

#### P15: ピラミッド（逆）
**用途**: ファネル
- 頂点（広い）: `3EE3A6`
- 底辺（狭い）: `00D184`

#### P16: マトリクス（4象限）
**用途**: ポジショニングマップ
```
        High
   Q2  |  Q1
  -----+-----
   Q3  |  Q4
        Low
```
- 軸線: `8C909B` 2px
- 象限ラベル: 20pt bold
- プロット: `00D184` circles

#### P17: ベン図
**用途**: 重複・共通要素
- 2-3円、transparency 25%
- Colors: `3EE3A6`, `00D184`, `8C909B`
- 重複部分: `D7FFF0`

#### P18: ツリー図
**用途**: 組織図、分類
- Root: `000000` BG `FFFFFF` text
- Branch: `F0F3F6` fill
- Leaf: `FFFFFF` fill, `8C909B` border
- Lines: `8C909B` 1px

#### P19: 数式・掛け算
**用途**: A × B = C の表現
```
[ Factor A ] × [ Factor B ] = [ Result ]
```
- 演算子: 36pt `8C909B`
- Result: `00D184` highlight

#### P20: 足し算
**用途**: 要素の累積
```
[ A ] + [ B ] + [ C ] = [ Total ]
```

#### P21: 領域図
**用途**: 範囲・対象領域の表現
- 外枠: `8C909B` dashed border
- 内部: `F0F3F6` fill areas

#### P22: 階段
**用途**: 成長ステップ、段階的改善
- 各段: 左から右へ高さ増加
- Colors: `F0F3F6` → `3EE3A6` → `00D184`

#### P23: 重複・包含
**用途**: 包含関係（大 ⊃ 中 ⊃ 小）
- 外: `F0F3F6`, 中: `3EE3A6` 25%透過, 内: `00D184`

#### P24: 相互関係
**用途**: 双方向の影響
- 2つのボックス + 双方向矢印
- 矢印: `00D184` 3px

#### P25: ビフォーアフター
**用途**: 改善効果
```
[ Before (gray) ]  →→→  [ After (green accent) ]
```

---

## Category 2: 要素間の関係が存在しないパターン (12 patterns)

### 2-1. グラフパターン (Charts)

#### P26: 縦棒グラフ
```javascript
slide.addChart(pres.charts.BAR, data, {
  x: 0.56, y: 1.0, w: 8.88, h: 3.5, barDir: "col",
  chartColors: ["3EE3A6", "00D184", "8C909B"],
  valGridLine: { color: "F0F3F6", size: 0.5 },
  catGridLine: { style: "none" },
});
```

#### P27: 横棒グラフ
- `barDir: "bar"` — ランキング表示に適する

#### P28: 円グラフ
```javascript
slide.addChart(pres.charts.PIE, data, {
  chartColors: ["3EE3A6", "00D184", "8C909B", "F0F3F6"],
  showPercent: true,
});
```

#### P29: 折れ線グラフ
- トレンド表示
- `lineSize: 3, lineSmooth: true`

#### P30: 積み上げ/複合グラフ
- 構成比の推移
- `barGrouping: "stacked"`

### 2-2. キャプチャパターン

#### P31: キャプチャ羅列
**用途**: スクリーンショットやUI画面の一覧
- 3カラム配置、影なし（フラット）

#### P32: キャプチャ拡大
**用途**: 特定UI要素のフォーカス
- 左: 全体画面（小さく）, 右: 拡大部分（大きく）

#### P33: キャプチャフロー
**用途**: 画面遷移
- Step 1 → Step 2 → Step 3 の画面遷移

### 2-3. 情報表示パターン

#### P34: 料金表
**用途**: プラン比較
- 3カラム（ベーシック/プロ/エンタープライズ）
- 推奨プラン: `D7FFF0` BG or `00D184` header

#### P35: データテーブル
**用途**: 多項目の整理
- Header: `000000` BG `FFFFFF` text
- Alt-rows, border `8C909B` 1px

#### P36: スケジュール/タイムライン
**用途**: プロジェクト計画、ロードマップ
- 横軸: 時間
- バー: `3EE3A6` fill, key milestone: `00D184`

#### P37: ランキング
**用途**: 順位表示
- 1位: `00D184` accent, 大きく
- 2位以下: `F0F3F6`, 段階的に小さく

---

## Category 3: ページ項目別パターン (5 patterns)

**注意**: 表紙・目次・セクション区切り・クロージングはONEテンプレートの既存レイアウトを使用。Claudeが生成するのは主にコンテンツスライド。

#### P38: 会社/サービス概要
**用途**: ONE/WEDの紹介スライド
- ロゴ（ネイティブシェイプで再現）+ 数値実績 + 簡潔な説明

#### P39: 事例紹介
**用途**: 導入事例、成功事例
```
[ 企業名/業種 ]
[ 課題 → 施策 → 成果 ]
[ KPI: 数値 ]
```
- Left: 企業情報, Right: 成果データ
- KPI数値: `00D184` 48pt

---

## パターン選択ガイド

### テキスト量で判断
- **少量**（キーワード程度）→ 横並び (P01-P03)
- **中量**（1-2文/項目）→ グリッド (P05) or カード
- **多量**（3行+/項目）→ 縦並び (P04) or テーブル (P35)

### データの種類で判断
- **比較** → P07 (Before/After), P08 (表比較), P16 (マトリクス)
- **推移** → P29 (折れ線), P36 (タイムライン)
- **構成** → P28 (円), P30 (積み上げ)
- **ランキング** → P27 (横棒), P37 (ランキング)
- **プロセス** → P09 (横フロー), P10 (縦フロー)
- **構造** → P14 (ピラミッド), P18 (ツリー)

### ビジュアルリズムで判断
- Dense slide → 次は Statement (P04系 on F0F3F6)
- 3枚連続dense → 必ず pause slide を挟む
- 同一パターン2回 → 次は必ず別パターン
