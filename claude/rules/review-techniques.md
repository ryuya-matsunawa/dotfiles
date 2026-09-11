# コードレビュー & コーディング技術集

*実際のPRレビューから抽出した、チームで共有したい知見*

---

## 目次

- [はじめに](#はじめに)
- [I. レビューの書き方そのもの](#i-レビューの書き方そのもの)
- [II. TypeScript / 型設計](#ii-typescript--型設計)
- [III. React / Hooks](#iii-react--hooks)
- [IV. Next.js App Router](#iv-nextjs-app-router)
- [V. フォーム実装](#v-フォーム実装)
- [VI. データフェッチ / API設計](#vi-データフェッチ--api設計)
- [VII. URL / ルーティング状態管理](#vii-url--ルーティング状態管理)
- [VIII. アクセシビリティ](#viii-アクセシビリティ)
- [IX. セキュリティ](#ix-セキュリティ)
- [X. スタイリング](#x-スタイリング)
- [XI. テスト / E2E](#xi-テスト--e2e)
- [XII. エラーハンドリング / 障害対応](#xii-エラーハンドリング--障害対応)
- [XIII. 命名 / 可読性](#xiii-命名--可読性)

---

## はじめに

このドキュメントは「**レビュアーとして他のメンバーに伝えたい観点**」と「**書き手として事前に気を付けたいポイント**」を、実際のPRレビューから抽出したものです。

各項目は以下の形式で構成されています:

- **問題意識**: なぜこの観点が重要か
- **NG / OK のコード対比**
- **学び**: チームへの示唆
- **出典**: 元PR（クリックで参照可能）

---

## I. レビューの書き方そのもの

### 1. 動くコード片を添えて代替案を示す

「ここ直してください」より、「こう書けます」が伝わる。**実際に手元で試してから書く** ことで、レビュー段階で破綻案を排除できる。

### 2. 強制力を明示する語彙を共通化する

レビューコメントの先頭に温度感を表す接頭辞を付ける:

| 接頭辞 | 意味 |
|---|---|
| 必須 / must | マージ前に対応必須 |
| 好みです | 採用しなくてもOKな提案 |
| ※FYI | 情報共有のみ |
| ※前回レビュー時に指摘すべきでした | 過去PRに遡るが今でも修正したい事項 |
| nit | 些細な指摘（タイポ等） |

心理的安全性とレビュー品質を両立する基盤になる。

### 3. トレードオフを開示する

```
sizeを 'S' | 'M' | 'L' に制限することを提案します。
（将来XS/XLが必要になる可能性はありますが、それは追加された時点で考えれば良いかなと思います）
```

「推し進めない選択肢」にも触れることで、相手が判断材料を持って意思決定できる。

### 4. 「なぜ」を残す

ライブラリのデフォルト挙動、過去インシデント、ドメイン上のエッジケース、公式ドキュメントへのリンク。**結論より背景を書く** と未来の読者の役に立つ。レビューコメントは将来の検索対象になる。

### 5. 動作検証の証跡を残す

セキュリティ・障害対応では、攻撃コードやエラー文言、再現手順をコメントに残す。「ライブラリを入れた」で終わらせず、`<script>alert("x")</script>` のような実ペイロードで before/after を比較した結果を貼る。

---

## II. TypeScript / 型設計

### 1. Union型の絞り込みは Type Guard で型と実行時を一致させる

```ts
// ❌ 実行時チェックだけ → 以降のスコープでも MissionState のまま
if (state.status !== 'CLOSED') return
// state は依然 MissionState

// ✅ Type Guard で型も絞る
function isClosed(s: MissionState): s is ClosedMissionState {
  return s.status === 'CLOSED'
}
if (!isClosed(state)) return
// state は ClosedMissionState に絞り込まれる
```

さらに踏み込むなら `ClosedMissionState extends MissionState` のように **部分型として表現** すればType Guard自体が不要になることもある。

### 2. SSoT — 定数から型を派生させる

```ts
// ❌ 型と定数の二重管理 → 追加忘れがランタイムエラーに
type DeployEnv = 'STAGING' | 'PRODUCTION'
const VALID_DEPLOY_ENVS = ['STAGING', 'PRODUCTION']

// ✅ 定数を Single Source of Truth に
const VALID_DEPLOY_ENVS = ['STAGING', 'PRODUCTION'] as const
type DeployEnv = (typeof VALID_DEPLOY_ENVS)[number]
```

定数を追加すれば型も連動。テストやフィルタUIのオプションも同じ配列から派生させると、追加忘れによるバグが構造的に消える。

### 3. フォーム型は Zod から導出する

```ts
const formSchema = z.object({
  name: z.string().min(1),
  age: z.coerce.number().int().positive(),
})
type FormValues = z.infer<typeof formSchema>  // ✅ 手書きしない
```

スキーマ変更で型が自動追従する。CLAUDE.md にも明文化されているプロジェクト規約。

### 4. Zodの `optional()` と「条件付き必須」は別概念

```ts
// ❌ _destroy: true 以外のときに token 必須にしたい → これでは表現できない
const schema = z.object({
  token: z.string().transform(v => v || undefined).optional(),
  _destroy: z.boolean().optional(),
})

// ✅ superRefine か discriminatedUnion を使う
const schema = z.object({
  token: z.string().optional(),
  _destroy: z.boolean().optional(),
}).superRefine((data, ctx) => {
  if (!data._destroy && !data.token) {
    ctx.addIssue({ path: ['token'], code: 'custom', message: '必須です' })
  }
})
```

### 5. 型しか参照しないなら `import type`

```ts
// ✅
import type { MediaCampaignTarget } from '../types'
```

TypeScript の elision を確実にし、Next.js の Server/Client 境界での意図しない取り込みを防ぐ。循環参照やバンドル膨張のリスクも軽減。

---

## III. React / Hooks

### 1. useEffect を乱用しない — あれは「避難ハッチ」

`useEffect` は React 内で完結しない処理（外部システムとの同期）を扱うための避難ハッチ。React 内で完結する処理に使うと、再レンダリングが増え、処理の流れが追えなくなる。

**ケースA: props を state にコピーする**

```tsx
// ❌ レンダー後に state を上書き → 1フレーム古い値が表示される瞬間が出る
const [localValue, setLocalValue] = useState(propValue)
useEffect(() => { setLocalValue(propValue) }, [propValue])

// ✅ 案1: 状態を親に持たせ、コールバックで通知
// ✅ 案2: key で位置をリセット（Reactの「同じ位置でのstateリセット」）
<EditPanel key={recordId} initialValue={value} />
```

**ケースB: useEffect が数珠繋ぎになる（カスケード更新）**

```tsx
// ❌ setState → 再レンダー → 別のuseEffectが発火 → … の連鎖
function ShoppingCart({ price, quantity }) {
  const [subtotal, setSubtotal] = useState(0)
  const [tax, setTax] = useState(0)
  const [total, setTotal] = useState(0)
  const [isFreeShipping, setIsFreeShipping] = useState(false)

  useEffect(() => { setSubtotal(price * quantity) }, [price, quantity])
  useEffect(() => { setTax(subtotal * 0.1) }, [subtotal])
  useEffect(() => { setTotal(subtotal + tax) }, [subtotal, tax])
  useEffect(() => { setIsFreeShipping(total >= 5000) }, [total])
  // ...
}

// ✅ props/state から計算できる値はレンダー時に直接計算する
function ShoppingCart({ price, quantity }) {
  const subtotal = price * quantity
  const tax = subtotal * 0.1
  const total = subtotal + tax
  const isFreeShipping = total >= 5000
  // ...
}
```

**ケースC: state 変更を検知して命令型APIを叩く**

あるPRでは「クリックしたボタンの種類で `dialogType` state をセット → その変更を `useEffect` が検知して `dialog.showModal()` → dialog 内部で `dialogType` に応じて分岐」という三段構えになっていた。ユーザー操作に対する処理はイベントハンドラー内で完結させる。

**レビュー時の観点**

- **レンダー時に直接計算する**: props や state から計算可能な値は `useEffect` を使わずコンポーネント直下で計算する（重い計算のみ `useMemo` を検討）
- **イベントハンドラーで処理する**: ユーザー操作に対する処理はハンドラー関数内で行う
- **データ取得ライブラリを使う**: API からのデータ取得に `useEffect` を自作しない。TanStack Query / SWR を使う

React公式の "You Might Not Need an Effect" 推奨パターン。

### 2. useState の遅延初期化で初回チラつきを抑える

```tsx
// ❌ 一瞬日本語が出てから英語になる
const [locale, setLocale] = useState('ja')
useEffect(() => setLocale(detect()), [])

// ✅ 初回レンダーから確定
const [messages] = useState(() => getMessages(detectLocale()))
```

`useState(() => ...)` の遅延初期化は SSR時には実行されない（client componentならCSR一回目で確定）。ロケール、メディアクエリ、localStorageなどブラウザ依存の初期値はこれで決める。

### 3. useCallback されていない関数を子の useEffect deps に渡すと無限ループ

```tsx
// ❌ 毎レンダー新しい参照 → 子の useEffect が暴発 (Maximum update depth exceeded)
const handlePatternChange = (v: string) => onChecked(v)
<RegexCheckList onPatternChange={handlePatternChange} />

// ✅ 既にメモ化された関数を直接渡す（中間ラップしない）
<RegexCheckList onPatternChange={onChecked} />
```

「親側でメモ化されているなら中間でラップし直さない」が原則。逆に親側がメモ化していない場合は、自分のコンポーネントで `useCallback` で受け止めるべきか、根本的に依存を切るべきかを設計判断する。

### 4. `<dialog>` の Escape経路で React state を同期する

```tsx
// ❌ Esc で閉じても setIsOpen(false) されない → 再オープン時に no-op となりサブツリーが再マウントされない
<dialog ref={dialogRef}>
  <button onClick={() => setIsOpen(false)}>×</button>
</dialog>

// ✅ onClose で state を同期
<dialog ref={dialogRef} onClose={() => setIsOpen(false)}>
  <button onClick={() => dialogRef.current?.close()}>×</button>
</dialog>
```

ネイティブ要素の **隠れた状態遷移経路（Esc、フォーム送信、ブラウザ戻る等）** を網羅する。命令型APIとReact stateは `onClose` のようなブリッジで同期する。

### 5. `useId()` でフォーム要素のidを生成

```tsx
// ❌ 同一ページに 2 つ置いた瞬間 id 重複
<input id="search" />

// ✅
function SearchBox() {
  const id = useId()
  return <input id={id} />
}
```

コンポーネントの再利用性を担保するため、id は必ず `useId()` か props 受け取り。

### 6. controlled / uncontrolled 両対応の定石

```tsx
function CheckBox({ checked: checkedProp, defaultChecked, onChange }) {
  const isControlled = checkedProp !== undefined
  const [internal, setInternal] = useState(defaultChecked ?? false)
  const checked = isControlled ? checkedProp : internal

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!isControlled) setInternal(e.target.checked)
    onChange?.(e)
  }
  return <input type="checkbox" checked={checked} onChange={handleChange} />
}
```

React で頻出するパターン。`checkedProp === undefined` で controlled/uncontrolled を判定する。

### 7. props の柔軟性は意図的に制限する（「柔軟性≠正義」）

```tsx
// ❌ デザインばらつきの温床
size?: string

// ✅ 列挙して制約。将来の追加リスクは正直に開示
size?: 'S' | 'M' | 'L'
```

### 8. 分岐をどこに置くかは「将来の拡張可能性」で判断する

- 他のstatusでも表示形が変わるなら → **コンポーネント内で分岐**
- ただ表示/非表示だけなら → **親で `{condition && <X />}`**

「責務分離」という抽象を、拡張可能性の予測で具体的な配置に落とす。

---

## IV. Next.js App Router

### 1. async Server Component が Suspense fallback を遅延させる

```tsx
// ❌ await が完了するまでスケルトンが出ない（描画が止まる）
export default async function Page() {
  const session = await getAssertedSession()  // ここで停止
  return (
    <Suspense fallback={<Skeleton />}>
      <DataView session={session} />
    </Suspense>
  )
}

// ✅ Suspense境界の内側で await
export default function Page() {
  return (
    <Suspense fallback={<Skeleton />}>
      <Inner />
    </Suspense>
  )
}

async function Inner() {
  const session = await getAssertedSession()
  return <DataView session={session} />
}
```

Suspense境界は **「`await` の外側」** に置く。Cookie読み取り程度なら無視できるが、ネットワーク呼び出しを上位で待つと体感速度が悪化する。

### 2. `'use client'` を「葉」に追い込む

```tsx
// ❌ Header をクライアント化 → 下流すべてが client、env取得が遠回り
'use client'
function Layout({ children }) {
  return <><Header /><main>{children}</main></>
}

// ✅ page.tsx から header を slot として渡し、Header は Server Component のまま
function Page() {
  return (
    <Layout header={<Header />}>
      <ClientThing />
    </Layout>
  )
}
```

**Client Component の中に Server Component を子要素として渡せる**（slot パターン）。`'use client'` 境界は最小化する。

### 3. Server Component 化で重複fetchを削減

```tsx
// ❌ クライアントから 2 回呼ばれる
'use client'
function Header() {
  const { data: user } = useSWR('/api/user', fetcher)
  return <span>{user?.name}</span>
}

// ✅ Server Component 側で 1 回取得して ReactNode で渡す
async function Page() {
  const user = await getUser()
  return <Layout header={<Header user={user} />}>{...}</Layout>
}
```

### 4. `'server only'` 文字列リテラル ≠ `import 'server-only'`

```ts
'server only'              // ❌ ただの式、何もしない
import 'server-only'       // ✅ クライアント取り込み禁止
```

server-only / client-only は **副作用 import** として読み込む必要がある。タイポはセキュリティ事故に直結。

### 5. middleware は「許可リスト」設計で fail-safe に

```ts
// ❌ 保護リスト方式 → 新ルート追加時に保護漏れ
export function middleware(req: NextRequest) {
  if (!claims && pathname.startsWith('/missions')) {
    return redirect('/auth/signin')
  }
}

// ✅ デフォルト deny + 公開パスのみ許可
const PUBLIC_PATHS = ['/auth/', '/api/auth/', '/api/e2e/']
export function middleware(req: NextRequest) {
  const isPublic = PUBLIC_PATHS.some(p => pathname.startsWith(p))
  if (!claims && !isPublic) return redirect('/auth/signin')
}
```

認可ロジックは「明示的に開ける」設計にして fail-safe にする。

### 6. クライアント主導フォームを Server Action に寄せる

```tsx
// ❌ useState + handleSubmit + router.refresh()
'use client'
function Form({ data }) {
  const [state, setState] = useState<BusinessMetadata>(data)
  const router = useRouter()
  // ...
}

// ✅ input に name 属性、Server Action で revalidate
function Form({ data }) {
  return (
    <form action={updateMetadata}>
      <input name="businessName" defaultValue={data.businessName} />
    </form>
  )
}
```

`useState` も `useRouter` も `'use client'` も不要になる。

### 7. `'use client'` を増やすコストを意識する

```tsx
// ❌ window.open を使うために 'use client' を追加
'use client'
<button onClick={() => window.open(url, '_blank')}>開く</button>

// ✅ <a> タグでサーバコンポーネントのまま
<a href={url} target="_blank" rel="noopener noreferrer">開く</a>
```

クライアントコンポーネント化は **バンドルサイズ・hydration コスト** が増える。HTML標準で達成できるならそちらを選ぶ。

### 8. 環境変数のフォールバック `?? ''` で fail-silent を避ける

```ts
// ❌ 空文字で署名や JWE 生成が成立してしまう → 原因不明のランタイムエラー
const url = process.env.NEXT_PUBLIC_SUPABASE_URL ?? ''

// ✅ 起動時に必須チェック
const url = process.env.NEXT_PUBLIC_SUPABASE_URL
if (!url) throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL')
```

env は `NEXT_PUBLIC_*` も含めて fail-loud にする。

---

## V. フォーム実装

### 1. フォーム外部データへの追従は `values` オプションを使う

```tsx
// ❌ useEffect で reset → タイミング問題、id=null 状態で確定するバグの温床
useEffect(() => { reset(serverData) }, [serverData])

// ✅ react-hook-form の values オプション
useForm({ values: serverData })
```

新規/既存レコードの判別は **フォーム値の `id === null`** で行う。外部データは非同期更新で一時的に不一致が生じうるため。

### 2. `setValue` には `{ shouldValidate: true }` を渡す

```ts
// ❌ 値を変えてもエラー表示は次の submit まで更新されない
setValue('campaignTargets', next)

// ✅ 操作直後のフィードバック
setValue('campaignTargets', next, { shouldValidate: true })
// または
trigger('campaignTargets')
```

### 3. `watch()` の二重呼び出しは購読を増やす

```tsx
// ❌ map 内で再度 watch → subscription が二重、不要な再レンダー
const watchedTargets = watch('campaignTargets')
{watchedTargets.map(t => (
  <input checked={watch('campaignTargets').includes(t)} />  // ⚠ 再購読
))}

// ✅ 上位変数を使い回す
{watchedTargets.map(t => (
  <input checked={watchedTargets.includes(t)} />
))}
```

### 4. 空文字とnullを意識的に区別する

```ts
// ❌ datetime-local を空にすると '' が来る
// → formatFutureDate('') が '' を返し、Rails API に deactivated_at: '' を送信
function formatFutureDate(v: string) {
  if (!v) return ''  // ⚠
  // ...
}

// ✅ 空 → null をスキーマ層で確定
const schema = z.object({
  deactivatedAt: z.string().trim().nullish().transform(v => v || null),
})
```

CLAUDE.md にもある「Rails で `allow_blank` がついていればなおさら `nil` で送る」原則。

### 5. 数値フィールドは `z.coerce.number()` を使う

```ts
// ❌ FormData は文字列で来る → z.number() ではバリデーション失敗
z.object({ count: z.number().int().positive() })

// ✅ 文字列→数値変換を内包
z.object({ count: z.coerce.number().int().positive() })
```

ただし `z.coerce.number('')` が `0` になる挙動には注意。空値を許容したいなら `nullish()` を組み合わせる。

---

## VI. データフェッチ / API設計

### 1. BFF は一段ルール

```
❌ Client → /api/foo-proxy → /api/vendor/v1 → 外部API   （3ホップ）
✅ Client → /api/vendor/v1 → 外部API                     （2ホップ）
```

トークン隠蔽が目的なら一段で達成可能。多段化は **レイテンシ・複雑度・障害ポイント** を増やすだけ。

### 2. 「フロントPRでもバックエンドAPIの形を提案していい」

フロントから複数回叩いている関連APIがあれば、**Rails側のレスポンスに含めてもらう** ことで往復削減＋障害連鎖の遮断を一気に達成できる。レイヤを跨ぐ視点を持つ。

### 3. ドメイン上のエッジケースを先回りで指摘し、解決策を2段階で提示する

「同一グループ内の子ミッション間でメディアが異なるケース」のような **起こりうるが見落としやすいケース** を、「今やる解決策」と「将来スケールしたら考える解決策」に分けて提示する。

---

## VII. URL / ルーティング状態管理

### 1. nuqs の `parseAsStringLiteral` でクエリパラメータを型レベルで絞る

```ts
// ❌ 不正値が素通り → サイレントに空配列を返す
useQueryState('status', parseAsString.withDefault('all'))

// ✅ リテラルユニオンに絞る
const MISSION_STATUSES = ['all', 'active', 'inactive'] as const
useQueryState('status', parseAsStringLiteral(MISSION_STATUSES).withDefault('all'))
```

URLパラメータも **SSoTの `as const`** から派生させ、フィルタUIのオプション・比較ロジックと一元化する。

### 2. `useQueryStates` を `shallow: false` + `throttleMs` で RSC と連動

```ts
const [filters, setFilters] = useQueryStates(filterSchema, {
  shallow: false,    // RSCを再リクエスト
  throttleMs: 300,   // 連打を抑制
})
```

URLで状態を保持しつつサーバ側の再フェッチに繋ぐ。App Router時代の検索パラメータ管理の定石。

---

## VIII. アクセシビリティ

### 1. `<div onClick>` は `<button type="button">` に置き換える

```tsx
// ❌ キーボード操作・SR で活性化できない、E2E で getByRole('button') で拾えない
<div onClick={handleClick}>クリック</div>

// ✅
<button type="button" onClick={handleClick}>クリック</button>
```

a11y のためだけでなく、**E2Eテストのセレクタ安定化** にも button要素化は効く。

### 2. `role="button" tabIndex={0}` を付けるなら `onKeyDown` も必須

```tsx
// ❌ フォーカスは当たるがキーボードで活性化できない不完全な状態
<div role="button" tabIndex={0} onClick={close} />

// ✅ 案1: フル実装
<div role="button" tabIndex={0} onClick={close}
     onKeyDown={(e) => (e.key === 'Enter' || e.key === ' ') && close()} />

// ✅ 案2: 触れない要素なら presentation で明示
<div role="presentation" onClick={close} />
```

ARIAは中途半端に付けると逆効果。

### 3. ドロップダウンには対状態を表現する

```tsx
<button aria-expanded={isOpen} aria-haspopup="menu" onClick={toggle}>
  メニュー
</button>
<ul role="menu" hidden={!isOpen}>...</ul>
```

「動くUI」には **対応する状態属性** をセットで付ける。a11yは対状態の表現が要。

### 4. ラジオは `getByRole('radio') + .check()` で操作する

```ts
// ❌ テキスト要素を押しているだけ、セマンティクスが消える
await page.getByText('男性').click()

// ✅ ロールベース、sr-only でも動く
await page.getByRole('radio', { name: '男性' }).check()
```

ロールベースのセレクタは **「アクセシビリティと等価性をテストで検証している」** ことを意味する。

### 5. ダイアログには `role="dialog"` を付けてテストもスコープ

```ts
// ❌ Header と Dialog 両方に「閉じる」があると衝突
await page.getByRole('button', { name: '閉じる' }).click()

// ✅ ダイアログ内に絞る
const dialog = page.getByRole('dialog')
await dialog.getByRole('button', { name: '閉じる' }).click()
```

a11y属性付与は **「a11y改善」と「テスト安定化」を同時に達成** する。

---

## IX. セキュリティ

### 1. サニタイズは「攻撃コードで挙動を確認」する

ライブラリを入れて満足せず、`<script>alert("x")</script>` のような実ペイロードで before/after を比較してレビューコメントに残す。**動くことの確認** まで踏み込む。

### 2. iframe は `sandbox` 属性を必ず制限する

```ts
rehypeSanitize({
  ...defaultSchema,
  required: {
    iframe: { sandbox: 'allow-scripts' },  // ✅
  },
})
```

sandbox属性なしの iframe は同一オリジン扱いで `parent.window` にアクセスできる。XSS対策の **「次の層」** の脆弱性。

### 3. `navigator.clipboard.writeText` は必ず try/catch

```ts
// ❌ 権限拒否・非セキュアコンテキスト・未フォーカスで reject → unhandled rejection
await navigator.clipboard.writeText(text)

// ✅
try {
  await navigator.clipboard.writeText(text)
} catch (e) {
  console.error('clipboard failed', e)
  // ユーザーに通知 or フォールバック
}
```

Web API はブラウザ環境/権限で reject するものが多い。「成功する前提」のコードを書かない。

---

## X. スタイリング

### 1. 長いIDに `truncate` は禁物、`break-all` にする

```tsx
// ❌ ユーザーIDが ... で切れてコピー用途が壊れる
<span className="truncate">{userId}</span>

// ✅
<span className="break-all">{userId}</span>
```

Tailwindユーティリティは **「内容の性質」（コピー対象か、見栄え重視か）** で選ぶ。

### 2. `next/image` 一辺倒にしない

写真には `next/image` の最適化が効くが、SVGアイコンには使う必然性が薄い。matcherで `public/images/` を除外する手間も増える。**用途で使い分ける** 判断を持つ。

---

## XI. テスト / E2E

### 1. `data-testid` を増やす前に semantic role を試す

```tsx
// ❌ testid を細かく振る
<div data-testid="release-date">{releaseDate}</div>

// ✅ 親に testid、子は role/tag で絞る
<div data-testid="release-info">
  <time dateTime={d}>{formatted}</time>
</div>
// page.getByTestId('release-info').locator('time')
```

### 2. アサーションには「どこに」を必ず含める

```ts
// ❌ ページのどこかにあれば通る（意味の薄いテスト）
await expect(page.getByLabel('男性')).toBeVisible()

// ✅ スコープを限定
await expect(
  page.getByTestId('onboarding').getByLabel('男性')
).toBeVisible()
```

### 3. 共通モックは `describe` + `beforeEach` で構造化

```ts
test.describe('Activities Page', () => {
  test.describe('when activities exist', () => {
    test.beforeEach(({ page }) => mockActivitiesAPI(page, sampleData))
    test('shows list', async ({ page }) => { ... })
    test('opens detail', async ({ page }) => { ... })
  })

  test.describe('when empty', () => {
    test.beforeEach(({ page }) => mockActivitiesAPI(page, []))
    test('shows empty state', async ({ page }) => { ... })
  })
})
```

コピペテストの蔓延を防ぐ構造論。

### 4. Vitest projects で拡張子別に分離

`.test.ts` (Node) / `.test.tsx` (Browser/Chromium) を `projects` で振り分け。ロジックとコンポーネントでモック範囲を最小化する。

### 5. `next/headers` の stub は「呼ばれたら throw」

```ts
// ❌ nop stub → モック忘れが silent に通過
vi.mock('next/headers', () => ({ cookies: () => ({}) }))

// ✅ 呼ばれたら検知できるように
vi.mock('next/headers', () => ({
  cookies: () => { throw new Error('next/headers must be mocked in tests') },
}))
```

stubは **「呼ばれて困るものは throw にする」** 防御的設計。

### 6. ネットワーク待機とユーザー操作はPromise.allで競合回避

```ts
await Promise.all([
  page.waitForResponse(url => url.includes('/api/missions')),
  page.getByRole('button', { name: '保存' }).click(),
])
```

CLAUDE.md記載のE2Eパターン。タイミング競合を避ける。

---

## XII. エラーハンドリング / 障害対応

### 1. CI の落ち方を「上流コミット」まで遡って残す

axios 1.7.4 のURL構築変更でE2Eが落ちた事例では、**上流PRリンク・差分・どのspecだけが落ちたか・STAGING/PROD差分の意味** までコメントに残されていた。次の同種事故での検索性が桁違いに上がる。

### 2. 踏んだエラー文言は原文のままコメントに残す

`Error: No recipients defined` のような **実エラー文をコメントに含める** と、再発時に grep 一発で経緯が辿れる。コメントは将来の検索対象になることを意識する。

### 3. fail-silentを排除する

- env: `?? ''` でフォールバックしない、起動時に throw
- middleware: 保護リストでなく許可リスト
- フォーマッタ: 空文字を返さない、明示的に null か throw
- stub: nopにしない、呼ばれたら throw

「silent failを許さない」設計が一貫してチームの文化になっている。

---

## XIII. 命名 / 可読性

### 1. 否定形の連結より filter チェーン

```ts
// ❌ 否定形のAND（読みづらい）
items.filter(x =>
  x.status !== 'CLOSED' && x.type !== 'DRAFT' && x.owner !== null
)

// ✅ filter を意味単位で分解、'all' は早期return
items
  .filter(x => filterStatus === 'all' || x.status === filterStatus)
  .filter(x => filterType === 'all' || x.type === filterType)
  .filter(x => x.owner !== null)
```

宣言的で意図が伝わる。

### 2. 変数名の進行形を疑う

```ts
// ❌ 他動詞の進行形 → 英語として不自然
const editingConfig = ...

// ✅
const configToEdit = ...
// または、修飾自体が不要なら
const config = ...
```

「そもそも修飾が必要か」を問い直す。

### 3. アンダースコア接頭辞は「未使用」のサイン

```ts
// ❌ _ が付いてるのに .json() を呼んでいる → 矛盾
const _bannersResponse = await fetch(...)
await _bannersResponse.json()

// ✅ 使うなら接頭辞を外す
const bannersResponse = await fetch(...)

// ✅ そもそも値が不要なら fetch自体やめる
const banners: Banner[] = []
```

命名規約の意味と、それを満たすためのコード簡略化を一体で考える。

### 4. コメントは「なぜ」だけ書く

CLAUDE.md記載のプロジェクト方針:
- **何をしているか** は良い識別子で表現する（コメントで書かない）
- **なぜそうしているか** が非自明なときだけコメントを書く
  - 隠れた制約、過去のバグ対応、surprising な挙動
- 現在のタスクや「used by X」のような変動する情報は書かない（PR説明欄に書く）

### 5. TypeScript らしく書く

```ts
// ❌ 手続き的。ミュータブルな配列とループ変数が外に漏れる
const activeNames = []
for (let i = 0; i < users.length; i++) {
  if (users[i].isActive) activeNames.push(users[i].name)
}

// ✅ immutable、スコープが狭い
const activeNames = users.filter(u => u.isActive).map(u => u.name)
```

`for` 文自体が悪いわけではない（早期break、巨大配列、複雑な添字操作では妥当）。ただ「Ruby で `for` 文を使うか？」と同じ問いで、**その言語らしい書き方があるならそちらを選ぶ**。関数型的な観点では **immutable であること・変数のスコープが狭いこと** が美しさの基準になる。

※これは好みの領域を含む指摘。レビューでは「必須」ではなく「好みです」の温度感で伝える（I-2「強制力を明示する語彙を共通化する」）。

---

## 全体傾向 / チーム文化の特徴

このレビュー集を貫いている共通の価値観:

1. **「コード片を添えて代替案を示す」文化** — 動くコード例を伴うレビューが圧倒的多数。実際に手元で試した形跡が頻繁にある。
2. **トレードオフの開示と心理的安全** — `好みです` / `※FYI` 等で温度感を共通化、推し進めない選択肢にも触れる誠実さ。
3. **プラットフォームへの回帰** — useEffect回避／`'use client'`増やさない／HTML標準・semantic role への回帰。フレームワーク固有の作法に依存しない実装。
4. **ドメイン横断の越境レビュー** — フロントPRでもRailsコントローラに踏み込む、上流ライブラリのコード差分まで追う、レイヤを跨ぐ視野。
5. **fail-silent への徹底的な警戒** — env、middleware、setValue、stub のthrow化など、「silent fail を許さない」設計提案の一貫性。
6. **a11y とテスト安定化の同時最適化** — `role` / `aria-*` の指摘が、a11y単独でなく「セレクタ安定化」も同時に達成する文脈で語られる。
7. **CLAUDE.md規約との一致** — ドキュメントが「実際に守られる規約」として機能している様子が、実レビューに反映されている。

---

*このドキュメントは継続的に更新されます。新しい知見があれば追記してください。*
