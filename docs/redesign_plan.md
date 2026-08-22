# 再設計プロジェクト 実装計画

決定事項の理由は [redesign_decisions.md](redesign_decisions.md) を参照。
ここではやること・やっていないことだけを管理する。

## 完了

- [x] DB設計 ステップ1（theme/status/source_type/price/affiliate_url/provider/uid/ActiveStorageテーブル追加）
- [x] ローカル/ステージングでのマイグレーション動作確認（既存データ無事なことを確認済み）
- [x] `notifications`テーブルの polymorphic不整合バグ修正
- [x] OmniAuth（Google/LINE）実装 フェーズ1（既存パスワード認証と共存）
- [x] 公開リンク(`/shared_gift_lists/:token`)のセキュリティ強化一式
      （Referrer-Policy設定、noindexメタタグ、robots.txt除外、`public_token`分離＋再発行機能、
      `choose`の排他チェック、`cancel`の所有者限定チェック）
- [x] 上記に対するテスト追加（`GiftList`/`GiftItem`/`User`のモデルテスト、
      公開リンクの排他制御・認可チェックの統合テスト）
- [x] 既存コントローラのテスト追加（`GiftListsController`/`GiftItemsController`/
      `SharedGiftItemsController`/`StaticPagesController`）。テストを書く過程で以下の
      未発見だったバグを3件見つけ、その場で修正済み:
      - `GiftListsController`/`GiftItemsController`に`authenticate_user!`が無く、
        未ログインでアクセスすると500エラーになっていた（ビューではログイン導線を
        出していたが、コントローラ自体は無防備だった）
      - `GiftItemsController#create`が`gift_list_uuid`をURLパラメータからそのまま
        信用しており、ログインユーザーが他人のギフトリストにギフトを追加できる
        IDOR（認可不備）があった → `current_user.gift_lists`にスコープするよう修正
      - `SharedGiftItemsController#show`が`gift_item.id`だけで検索しており、連番IDを
        総当たりすれば他人の（共有されていない）ギフトの詳細まで閲覧できてしまう
        情報漏洩があった → ネストされた`public_token`経由でしか辿れないよう修正
- [x] URL入力→OGP取得のSSRF対策（`ssrf_filter`導入、プライベートIP/メタデータIPガード、
      redirect先チェック、タイムアウト2秒/1MB制限）。`app/services/safe_html_fetcher.rb`として実装。
      あわせて、これまでOGP取得失敗時に例外処理が一切なく500エラーになっていたバグも修正
      （失敗時は手動入力画面へのフォールバック文言を表示するよう変更）
- [x] `gift_lists.is_public`を削除し、`status`に一本化。バリデーション以外に
      参照箇所が無かったため、素直に`remove_column`で削除できた

## 未着手（次にやること）

### 認証まわり
- [x] Google Cloud Console / LINE Developers Console でクライアントID・シークレットを発行（ユーザー側作業）
- [x] `.env`への設定、およびサーバーサイドでのリダイレクトURL生成確認
      （`compose.yml`に`env_file: .env`が無く、`.env`の値が一切コンテナに読み込まれていなかった
      バグを発見・修正。修正前は`client_id`が空のままGoogle/LINEに送られていた）
- [x] ログイン画面のGoogle/LINEボタンがTurbo(Hotwire)に横取りされ、外部ドメインへの
      リダイレクトが処理できず「押しても何も起きない」状態になっていたバグを修正。
      `button_to`に`data: { turbo: false }`を追加し、通常のフルページ遷移にした。
      修正後、実際にaccounts.google.comの同意画面まで遷移することを確認済み
- [x] 実際にGoogle/LINEでログインが完了し、アプリ側にユーザーが作成される
      （`from_omniauth`が正しく動く）ところまでユーザー自身のブラウザで確認済み
- [x] メール/パスワードでの新規登録を停止し、Google/LINEログインに一本化
      （フェーズ3。既存パスワードユーザーのログインには影響なし）
- [x] アカウント編集画面(`/users/edit`)で表示名を変更できるようにした。
      OmniAuthユーザーはパスワードを知らないため、`update_without_password`を使い
      現在のパスワード確認なしで名前・メールアドレスを変更できるようにした
      （Deviseの仕様上、この方法だとパスワード自体の変更はできないため、
      パスワード変更フィールドは編集画面から外した）
- [ ] （優先度低・将来対応）パスワード認証を完全廃止し、SNS認証のみにする
      （`database_authenticatable`/`registerable`を外す。理由は
      [redesign_decisions.md](redesign_decisions.md)参照）

### 公開ページ本体の実装
- [x] 楽天/Yahoo API横断検索の実装（並列リクエスト、フォールバック）
      - `RakutenProductSearch`/`YahooProductSearch`/`ProductSearch`（並列実行の窓口）として実装
      - 片方のAPIキー未設定・障害時は空配列を返すのみで、もう片方の結果はそのまま表示される
      - ギフト新規登録画面にキーワード検索欄を追加、Turbo Streamで結果を差し込み表示
      - 検索結果から選んだ場合は`source_type: api_search`として登録。あわせて、これまで
        `source_type`がどの経路でも一度も設定されておらず常にDBのデフォルト値`manual`のままだった
        バグも修正（`url_ogp`/`manual`もそれぞれ正しく設定するようにした）
      - `RAKUTEN_APPLICATION_ID`・`YAHOO_CLIENT_ID`はユーザー側で取得・設定が必要
        （`.env`にプレースホルダーを追加済み、本番はRenderの環境変数への追加も別途必要）
- [x] アプリ内通知（フェーズ1）: 商品が選ばれたら`Notification`レコードは以前から作られていたが、
      画面上に表示する仕組みが無かったため追加。ヘッダーに通知ベル・未読件数バッジを表示し、
      `/notifications`で一覧を見られるようにした（閲覧すると自動で既読になる）
- [ ] 通知フェーズ2: LINE Messaging APIでのプッシュ通知、Google/メール認証ユーザーへのメール通知
      （詳細は[redesign_decisions.md](redesign_decisions.md)参照）
- [ ] デザインテーマ（mode/botanical/nuance）に応じた画面デザインの作り直し
      `tmp/design_preview/ui_gothic.html`をベースに使えることを確認済み。カタログ作成・編集は
      「別ページのまま、見た目だけウィザード風」の方式Aで実装する（詳細は
      [redesign_decisions.md](redesign_decisions.md)参照）。UIデザイン自体は別セッションで
      並行して作成中。
      対象画面は以下の14画面（2026-08-22時点で洗い出し済み）:
      **認証まわり**
      1. ログイン画面 (`/users/sign_in`) — メール/パスワード + Google/LINEログインボタン
      2. アカウント編集画面 (`/users/edit`) — 表示名・メールアドレスの変更、アカウント削除
      3. パスワード再設定画面 (`/users/password/new`, `/edit`) — リンクは非表示だがルートは生きている（優先度低）
      　※新規登録画面(`/users/sign_up`)はGoogle/LINE誘導のみのブロック画面のため対象外
      **贈り主側（ログイン必須）**
      4. ギフトリスト一覧 (`/gift_lists`) — 未ログイン時は誘導表示
      　　15. （追加予定）履歴一覧 — `completed`のギフトリストを絞り込み表示、いつ・誰に・何を贈ったか
      5. ギフトリスト新規作成 (`/gift_lists/new`)
      6. ギフトリスト詳細/管理画面 (`/gift_lists/:uuid`) — 商品一覧、共有URLコピー、リンク再発行、選ばれた商品の確認、「選び直してもらう」ボタン
      7. ギフトリスト編集 (`/gift_lists/:uuid/edit`) — リスト名・メッセージ編集
      8. ギフトアイテム新規登録 (`/gift_lists/:uuid/gift_items/new`) — URL入力 or 手動入力
      9. ギフトアイテム編集 (`/gift_items/:id/edit`)
      10. ギフトアイテム詳細/管理画面側 (`/gift_items/:id`) — あまり使われていないが一覧の遷移先として存在
      **受け取り主側（ログイン不要・公開ページ）**
      11. 公開カタログ画面 (`/shared_gift_lists/:token`) — テーマに応じた見た目、商品一覧、選択ボタン、メッセージ表示、確定後の案内
      12. 公開アイテム詳細 (`/shared_gift_lists/:token/shared_gift_items/:id`) — 商品名・画像・説明の詳細ページ
      **その他**
      13. トップページ (`/`) — サービス紹介、「はじめる」CTA
      14. 共通ヘッダー/フッター（ログイン状態に応じた表示切り替え）

### 新機能（UIは別セッションで並行して検討中）
- [ ] 贈った商品の履歴管理
      - `GiftList#status`に`completed`（プレゼント完了）へ明示的に遷移させる操作が今は無いので追加
      - ギフトリスト一覧に「履歴」タブ/絞り込みを作り、`completed`のものを一覧表示
      - 画面リストにも追加予定（15. 履歴一覧画面）
- [ ] 人気・定番プリセット機能
      - 実店舗の商品を紹介する形になるため、リンク切れ・価格変動のメンテコストが課題
      - 楽天/Yahoo API連携の後に着手する方針（APIのライブデータを使えばリンク切れの心配が減る）
      - 先行して少数を手動キュレーションする案もあるが、優先度はAPI実装より低い
- [ ] 選択時のLINE通知送信（現状は`Notification`レコードがDBに作られるだけで、実際の送信処理は未実装。
      `app/models/gift_item.rb`にも「LINE通知の送信は…後続実装」とコメントあり。旧トップページの
      「選ばれたギフトを通知でお知らせ（未実装）」も同じ注記）。
      トップページのモック（`tmp/design_preview/ui_refined_v15.html`他）の使い方ステップ④
      「贈り主に通知が届く」は、これが実装された前提の将来のビジョンとして描いている
      （2026-08-22、デザイン検討時に確認・合意）

### 画像アップロード
- [ ] CarrierWaveからActiveStorage(S3)への移行

### 運用・法務
- [ ] アフィリエイトリンクの表示義務対応（「広告を含みます」等の明示）
- [ ] 簡易プライバシーポリシーページの設置
- [ ] 楽天/Yahoo APIのキャッシュ・レート制限（コスト対策）
- [ ] S3画像の削除忘れ対策（`purge_later`をきちんと呼ぶ）

## 保留（将来検討、今回のスコープ外）

- `price`カラムの非表示対応・入力フォーム整備 — 「セットで贈る」機能（複数選択・合計金額ベース）
  とセットで検討する可能性が高いため、今回は着手しない。詳細は
  [redesign_decisions.md](redesign_decisions.md)の「将来検討」を参照。
- Ruby 3.2.3 / Rails 7.2.2.1 のアップグレード — Brakemanが「サポート終了(EOL)」を警告している。
  脆弱性ではないが、いずれ計画的にアップグレードする必要がある。今回のPRではCIのBrakeman実行から
  `EOLRuby`/`EOLRails`チェックを除外して切り分けた（`.github/workflows/ci.yml`）。
