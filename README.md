# カタログギフトメーカー

## サービス概要
「カタログギフトメーカー」は、贈り物を選ぶ楽しさを提供するWebアプリです。
一般的なカタログギフトとは異なり、特定のショップに縛られず自分で商品を選び、オリジナルのギフトカタログを作成できます。
受け取った相手はリストの中から欲しいものを選ぶことができるため、ミスマッチを防げます。


## このサービスへの思い・作りたい理由
贈り物に対する自身の失敗や既存サービスへの不満、嬉しかった思い出からこのサービスを開発したいと考えました。

### ▫️ 一般的なカタログギフトの不満を解消
既存のカタログギフトには、自分が贈りたいアイテムが含まれていないことが多いです。
本サービスでは、贈り主自身がセレクトしたアイテムの中から選んでもらえるため、より気持ちを込めたギフトが可能です。

### ▫️ ギフトのミスマッチを防ぎたい
「すでに持っている」「好みに合わなかった」というギフトの問題を解決したい。相手が本当に欲しいものを選べる仕組みにすることで、ギフトの価値を高めます。

### ▫️ 贈られて嬉しかった経験
友人から出産祝いとして自作のギフトリスト（※）を送ってもらったことがあり、自分のために贈り物を考えてリスト作りに時間をかけてくれたことがとても嬉しかったです。
(※商品画像と説明文を画像化し、LINE上で送られたもの。画像編集アプリなどを使用し手間をかけて作られていました)

この嬉しい気持ちを誰もが体験できるように、手軽にオリジナルのカタログギフトを作れるようにしたいと考えています。



## ユーザー層について

- 20〜30代の社会人
  - 結婚・出産・昇進などお祝い事が多いライフステージにある
  - 送別会や歓迎会など、職場での贈り物を用意する機会が増える

- 贈り物にこだわりたい人
  - 大切な人に本当に喜んで貰える贈り物をしたいと考えている人
  - 他とは違う特別な贈り物を探している人



## サービスの利用イメージ

1. **ギフトリストを作成**
   - 商品画像・商品名・説明を登録
   - ショップURLから自動取得 or 手動入力
   - 自由にカスタマイズ可能

2. **ギフトリストURLを相手に共有**
   - メッセンジャーアプリなどでシェアされることを想定
   - シェアしやすいようコピペ用テンプレートも用意

3. **相手が商品を選ぶ**
   - リストから1つ選択
   - 選択済みが見えるUIに

4. **作成者に通知が届く**
   - マイページに通知
   - LINE通知（本リリース後）



## このアプリを使うメリット

- 相手が欲しいものを選べるので、ギフトのミスマッチを防げる
- さまざまなショップを横断して選べるため、自由度が高い
- 手軽に贈りたいものリストが作成できる
- 購入サイトのURLを共有しないので、価格を伏せたまま贈れる
- URLの羅列よりスマートで、特別感のあるギフトリストが作れる
- 自分好みにカスタマイズ可能（画像変更・説明文編集）



## ユーザーの獲得について

- SNSでの情報発信
- 開発ブログでの紹介記事



## サービスの差別化ポイント・推しポイント
同様のサービスは見当たらなかったため、カタログギフトやAmazonほしい物リスト、完全に自作するものと比較しました。

- **一般的なカタログギフトと比べて**
  - **ショップを問わず自由に選べる**
    - 既存のカタログギフトは特定のブランドやECサイトに限定されるが、本サービスではショップを横断して自由に選択可能
  
- **Amazonほしい物リストと比べて**
  - **贈る側の“気持ち”を込められる**
    - ほしい物リストは「受け取り側が主導で作るリスト」であり、本サービスは**贈る側が主導で作るリスト**であることが大きな違い
    - 相手が欲しいものから選ぶことが一番のミスマッチ回避ではありますが、贈る側が相手のことを想いながらセレクトするという工程を残すことで、気持ちのこもったギフト体験を実現
    - 「ほしい物リストを作ってるか聞く」「欲しいものを尋ねる」といったワンクッションを挟まずに贈れるため、スマートさとサプライズ性を両立できる
  
- **自作のカタログギフトと比べて**
  - **手軽にギフトリストを作れる**
    - 商品URLを入力するだけでリストが作れる



## 機能候補

### MVP機能一覧

- ユーザー登録
- ログイン・ログアウト機能
- ギフトリスト作成（商品タイトル、説明、画像）
    - 商品画像・商品名・説明を自動取得（購入サイトの商品ページURLを入力してOGP取得）
    - 商品名・説明の手動入力・編集
    - 画像アップロード機能（自作画像を使いたい人向け）
- ギフトリストの共有
    - 作成したリストのURLを発行し、贈る相手に簡単に共有できる
    - 受け取る側はログインなしで閲覧（ランダムなURLにする）
- ギフトの選択
    - 受け取る側がリストから欲しいものを選択できる
- マイページ機能
    - プロフィールの表示・編集
    - 作成したギフトリスト一覧
- ギフト選択通知
    - マイページ内で通知

### 本リリース時

- LINE通知機能（リスト作成者に「この商品が選ばれました！」と通知）
- ギフトプリセット
    - Amazonギフトカードなどのデジタルギフト券のプリセットを用意しておき、リストに加えられる
- ギフトリスト一覧
    - 他の人が作成したギフトリストを見れる（選択はできない状態）
- パスワードリセット機能
- Googleログイン認証
- リストのデザインカスタマイズ機能（テーマやカラーを選べる）
- 利用規約
- プライバシーポリシー
- Xシェア機能
    作成したギフトリストのシェア
- レスポンシブ対応

### このアプリが行わないこと
このアプリはギフト選びをサポートすることが目的であり、商品購入や発送の手続きはユーザー自身で行なってもらいます


## 機能の実装方針予定

- バックエンド：Ruby on Rails
- CSS：Tailwind CSS
- 画像投稿：ActiveStorage
- LINE通知：LINE Messaging API
- 商品情報の取得：Gem NokogiriでOGPを取得
