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

## 未着手（次にやること）

### データ設計の整理
- [ ] `gift_lists`の`is_public`(boolean)と`status`(enum: draft/shared/selected/completed)が
      同じ「公開状態」を別々に表しており、今後食い違って矛盾したデータになるリスクがある。
      `status`に一本化し、`is_public`は廃止する方向で整理する

### 認証まわり
- [ ] Google Cloud Console / LINE Developers Console でクライアントID・シークレットを発行（ユーザー側作業）
- [ ] `.env`への設定と実際のログイン動作確認

### 公開ページ本体の実装
- [ ] `/c/:token` レスポンスから`price`カラムを完全除外（サーバーサイドで担保）
- [ ] URL入力→OGP取得のSSRF対策（`ssrf_filter`導入、プライベートIP/メタデータIPガード、redirect先チェック、タイムアウト2秒/1MB制限）
- [ ] 楽天/Yahoo API横断検索の実装（並列リクエスト、フォールバック）
- [ ] デザインテーマ（mode/botanical/nuance）に応じた画面デザインの作り直し

### 画像アップロード
- [ ] CarrierWaveからActiveStorage(S3)への移行

### 運用・法務
- [ ] アフィリエイトリンクの表示義務対応（「広告を含みます」等の明示）
- [ ] 簡易プライバシーポリシーページの設置
- [ ] 楽天/Yahoo APIのキャッシュ・レート制限（コスト対策）
- [ ] S3画像の削除忘れ対策（`purge_later`をきちんと呼ぶ）
