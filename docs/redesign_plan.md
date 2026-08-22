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
- [ ] 楽天/Yahoo API横断検索の実装（並列リクエスト、フォールバック）
- [ ] デザインテーマ（mode/botanical/nuance）に応じた画面デザインの作り直し

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
