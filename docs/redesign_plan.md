# 再設計プロジェクト 実装計画

決定事項の理由は [redesign_decisions.md](redesign_decisions.md) を参照。
ここではやること・やっていないことだけを管理する。

## 完了

- [x] DB設計 ステップ1（theme/status/source_type/price/affiliate_url/provider/uid/ActiveStorageテーブル追加）
- [x] ローカル/ステージングでのマイグレーション動作確認（既存データ無事なことを確認済み）
- [x] `notifications`テーブルの polymorphic不整合バグ修正
- [x] OmniAuth（Google/LINE）実装 フェーズ1（既存パスワード認証と共存）

## 未着手（次にやること）

### 公開リンク(`/c/:token`)のセキュリティ強化
- [ ] `Referrer-Policy: strict-origin-when-cross-origin` の設定
- [ ] `/c/:token` ページへの `noindex, nofollow` メタタグ追加
- [ ] `robots.txt` で `/c/` 配下を除外
- [ ] `gift_lists`に`public_token`カラムを追加し、公開URLを`uuid`(主キー)ではなく`public_token`経由にする
- [ ] マイページから`public_token`を再発行（リンク無効化）できる機能
- [ ] `SharedGiftListsController#choose`に`GiftList#try_mark_selected!`を使った排他チェックを追加
      （現状は`GiftList`の状態を見ずに何度でも選び直せてしまう）
- [ ] `SharedGiftListsController#cancel`（選択解除）に認可チェックを追加
      （現状ログイン不要な公開ルートに置かれており、送り主でなくても`cancel`を呼べてしまう。
      「選び直しは送り主に依頼する」という仕様が実際には強制されていない）

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
