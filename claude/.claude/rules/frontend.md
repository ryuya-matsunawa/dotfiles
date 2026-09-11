# フロントエンド実装ルール

> 背景・出典・NG例の詳細: [review-techniques.md](./review-techniques.md)

## TypeScript / 型設計

- 定数を SSoT にする。`as const` 配列から型を派生させ、テストやフィルタUIのオプションも同じ配列から導出する（`type DeployEnv = (typeof VALID_DEPLOY_ENVS)[number]`）
- フォーム型は Zod から導出する（`type FormValues = z.infer<typeof formSchema>`）。手書きしない
- 型しか参照しないなら `import type`。Server/Client 境界での意図しない取り込み・循環参照・バンドル膨張を防ぐ
- Union の絞り込みは Type Guard（`s is ClosedMissionState`）で型と実行時を一致させる。部分型として表現できるならそちらを優先
- 他フィールドに依存する必須性は `optional()` では表現できない。`superRefine` か `discriminatedUnion` を使う
- props の柔軟性は意図的に制限する。`size?: string` ではなく `size?: 'S' | 'M' | 'L'`
- 配列処理は `for` 文より `filter` / `map` / `reduce` を優先する。immutable であること・変数のスコープが狭いことを基準にする（早期 break や複雑な添字操作が必要な場合は `for` でよい）

## React / Hooks

- **useEffect は避難ハッチ。React 内で完結する処理に使わない**
  - props / state から計算できる値はレンダー時に直接計算する（重い計算のみ `useMemo`）。`useEffect` + `setState` の数珠繋ぎ（カスケード更新）を作らない
  - ユーザー操作に対する処理はイベントハンドラー内で完結させる。state 変更を `useEffect` で検知して命令型API（`dialog.showModal()` 等）を叩く三段構えにしない
  - データ取得に `useEffect` を自作しない。TanStack Query / SWR を使う
  - props を state にコピーしない。状態を親に持たせるか `key` で位置ごとリセットする
- ブラウザ依存の初期値（ロケール、メディアクエリ、localStorage）は `useState(() => ...)` の遅延初期化で初回レンダーから確定させる
- メモ化済みの関数を中間ラップし直さない。毎レンダー新しい参照が子の useEffect deps に渡ると `Maximum update depth exceeded` になる
- ネイティブ要素の隠れた状態遷移経路（`<dialog>` の Esc、フォーム送信、ブラウザ戻る）を state と同期する。`<dialog onClose={() => setIsOpen(false)}>`
- フォーム要素の id は `useId()` か props 受け取り。ハードコードは再利用時に重複する
- controlled / uncontrolled 両対応は `checkedProp === undefined` で判定する定石に従う
- 分岐の置き場所は拡張可能性で決める。表示形が status で変わるならコンポーネント内、表示/非表示だけなら親で `{condition && <X />}`

## Next.js App Router

- Suspense 境界は `await` の外側に置く。async Server Component 上位で await すると fallback が出ない
- `'use client'` は葉に追い込む。Client Component に Server Component を slot として渡せる
- 重複 fetch は Server Component 側で1回取得して ReactNode で渡す形に寄せる
- `import 'server-only'` は副作用 import で書く。`'server only'` という文字列リテラルは何もしない（セキュリティ事故に直結）
- middleware は許可リスト設計。デフォルト deny ＋ `PUBLIC_PATHS` のみ許可し、新ルート追加時の保護漏れを構造的に防ぐ
- クライアント主導フォームは Server Action に寄せる。`input` に `name`、`<form action={...}>` で `useState`/`useRouter`/`'use client'` が不要になる
- HTML 標準で達成できることのために `'use client'` を増やさない（`window.open` ではなく `<a target="_blank" rel="noopener noreferrer">`）
- env は `?? ''` でフォールバックせず、起動時に throw して fail-loud にする（`NEXT_PUBLIC_*` も含む）

## フォーム

- 外部データへの追従は `useEffect` + `reset` ではなく `useForm({ values })`。新規/既存の判別はフォーム値の `id === null` で行う
- `setValue` には `{ shouldValidate: true }` を渡す（または `trigger`）。操作直後にエラー表示を更新する
- `watch()` を map 内で再呼び出ししない。上位で取得した変数を使い回す
- 空文字と null を意識的に区別する。スキーマ層で `z.string().trim().nullish().transform(v => v || null)` として確定させ、API に `''` を送らない
- 数値フィールドは `z.coerce.number()`。ただし空文字が `0` になる挙動に注意し、空値を許容するなら `nullish()` を組み合わせる

## データフェッチ / API

- BFF は一段ルール。トークン隠蔽は一段で達成できる。多段化はレイテンシ・複雑度・障害ポイントを増やすだけ
- フロントから関連APIを複数回叩いているなら、バックエンドのレスポンスに含める提案をする。レイヤを跨いで指摘してよい
- ドメイン上のエッジケースは「今やる解決策」と「将来スケールしたら考える解決策」に分けて提示する
- ORM クライアントはプロジェクト共通のインスタンスを import する。`new PrismaClient()` のような新規インスタンスを作らない

## URL / ルーティング状態

- クエリパラメータは `parseAsStringLiteral` でリテラルユニオンに絞る。不正値の素通り（サイレントな空配列）を防ぐ
- サーバ再フェッチと連動させるときは `useQueryStates(schema, { shallow: false, throttleMs: 300 })`

## スタイリング

- 長いIDに `truncate` を使わない。コピー対象の文字列は `break-all`。ユーティリティは「内容の性質」で選ぶ
- `next/image` は用途で使い分ける。写真には効くが SVG アイコンに使う必然性は薄い
- z-index はプロジェクト規約のトークン（`z-modal` / `z-loader` / `z-toast` など）を使い、数値を直書きしない
