# Android 対応に向けた調査メモ

## 1. Android で問題になりそうな箇所

- **通知権限が未要求**: Android 13 以降で必要な `POST_NOTIFICATIONS` パーミッションがマニフェストに無く、初期化処理でも権限リクエストを行っていないため、通知が表示されない。
- **ローカル通知の初期化が iOS 前提**: `DarwinInitializationSettings` を組み込んでいる一方で、Android では権限確認やチャンネル設定が不足しており、Android 固有の初期設定が行われていない。
- **アプリアイコン生成が iOS のみ**: `flutter_launcher_icons` 設定で `android: false` になっており、Android ではデフォルトアイコンのまま。ビルド自体はできるが、ストア提出やブランド整合性で問題化する可能性。
- **アプリ ID・署名の暫定値**: `applicationId` が `com.example.contact_lens_management` のまま、リリース時に固有 ID と署名設定が必須。
- **In-app Purchase のストア差分**: プロダクト ID が iOS/Android 共通か不明。Google Play 側で同じ ID を用意しなければ購入が失敗する。

## 2. 修正が必要なファイル一覧

- `android/app/src/main/AndroidManifest.xml`: 通知権限(`POST_NOTIFICATIONS`)の追加、必要に応じて `SCHEDULE_EXACT_ALARM` などを検討。
- `lib/main.dart`: `_initializeNotifications` 周りで Android の通知権限要求と初期化処理を追加。`NotificationDetails` に Android 用のサウンド/チャネル設定を明示。
- `pubspec.yaml`: `flutter_launcher_icons` で Android を有効化し、共通アイコンを生成できるようにする。
- `android/app/build.gradle.kts`: 本番用の `applicationId` と署名設定を反映する(リリース準備時)。
- （必要に応じて）`android/app/src/main/res/*`: カスタムアイコン追加時のリソース生成物。

## 3. 具体的な修正案

- **通知権限対応**
  - マニフェストに `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` を追加。
  - `_initializeNotifications` で Android 向け `requestNotificationsPermission` を呼び出し、許可状態に応じてスケジュール処理を実行。
  - 必要なら `AndroidNotificationChannel` を定義し、チャネル名・説明を共通で管理。
- **通知スケジュールの安定化**
  - `zonedSchedule` の Android 側 `NotificationDetails` にアイコン/サウンド設定を入れ、端末依存のデフォルトに左右されないようにする。
  - 正確なスケジュールが必要なら API 31+ で `SCHEDULE_EXACT_ALARM` の宣言と許可ダイアログ遷移を追加検討。
- **アプリアイコン整備**
  - `flutter_launcher_icons` で Android を有効化し、`assets/app_icon_1024.png` を元に各解像度のアイコンを生成。
  - 生成されたアイコンを `@mipmap/ic_launcher` に反映し、`AndroidInitializationSettings` の指定を一致させる。
- **アプリ ID / 署名**
  - `applicationId` を本番のパッケージ名に変更し、`release` ビルドに署名設定を追加(keystore の path/alias/password)。
- **課金アイテム確認**
  - `premium_monthly_300` / `premium_yearly_2500` が Google Play Console でも同一 ID で登録されているかを確認。差分がある場合は Android 用 ID を設定できる拡張ポイントを用意。

上記のうち、機能追加を伴わずに Android で動作保証するための最優先は「通知権限の追加と初期化の Android 対応」です。その他はリリース品質(アイコン・署名・課金設定)として順次対応できます。
