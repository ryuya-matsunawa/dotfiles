# 品質ルール（a11y / テスト / セキュリティ / 障害対応）

> 背景・出典・NG例の詳細: [review-techniques.md](./review-techniques.md)

## アクセシビリティ

a11y 属性の付与は「a11y 改善」と「E2E セレクタ安定化」を同時に達成する。両方の理由で必須とする。

- `<div onClick>` は `<button type="button">` に置き換える
- `role="button" tabIndex={0}` を付けるなら `onKeyDown`（Enter / Space）も必須。触れない要素なら `role="presentation"` で明示する。ARIA を中途半端に付けると逆効果
- 動く UI には対状態を付ける。ドロップダウンなら `aria-expanded` / `aria-haspopup` と `role="menu"` をセットで
- ダイアログには `role="dialog"` を付け、テストもその中にスコープする

## テスト / E2E

- `data-testid` を増やす前に semantic role を試す。親に testid、子は role / タグで絞る（`getByTestId('release-info').locator('time')`）
- アサーションには「どこに」を必ず含める。ページ全体に対する `toBeVisible()` は意味が薄い
- ラジオは `getByRole('radio', { name }).check()` で操作する。`getByText().click()` はセマンティクスを検証していない
- 共通モックは `describe` + `beforeEach` で構造化し、コピペテストを防ぐ
- Vitest は `projects` で `.test.ts`（Node）と `.test.tsx`（Browser）を分離し、モック範囲を最小化する
- stub は「呼ばれたら throw」にする。nop stub はモック忘れを silent に通過させる
- ネットワーク待機とユーザー操作は `Promise.all` で競合を避ける

```ts
await Promise.all([
  page.waitForResponse(url => url.includes('/api/missions')),
  page.getByRole('button', { name: '保存' }).click(),
])
```

## セキュリティ

- サニタイズはライブラリ導入で終わらせず、`<script>alert("x")</script>` のような実ペイロードで before/after を確認し、結果をレビューコメントに残す
- iframe には必ず `sandbox` を制限指定する。sandbox なしの iframe は `parent.window` にアクセスできる
- `navigator.clipboard.writeText` は必ず try/catch。権限拒否・非セキュアコンテキスト・未フォーカスで reject する。Web API に「成功する前提」のコードを書かない
- 認証ヘルパーは「権限を満たさなければ throw する版」と「全ユーザーを返す版」を区別して使う。E2E 用エンドポイント以外は `middleware.ts` で保護する

## 障害対応 / fail-silent の排除

silent fail を許さない。横断チェックリスト:

| 対象 | NG | OK |
|---|---|---|
| env | `?? ''` でフォールバック | 起動時に throw |
| middleware | 保護リスト | 許可リスト（デフォルト deny） |
| フォーマッタ | 空文字を返す | 明示的に null か throw |
| test stub | nop | 呼ばれたら throw |
| `setValue` | バリデーション遅延 | `{ shouldValidate: true }` |

- CI の落ち方は上流コミットまで遡って記録する。上流PRリンク・差分・落ちた spec・環境差分の意味まで残すと、次の同種事故での検索性が桁違いに上がる
- 踏んだエラー文言は原文のまま残す（`Error: No recipients defined`）。grep 一発で経緯を辿れるようにする
