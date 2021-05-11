## 概要

これはネイティブAdjust™iOS SDKガイドです。Adjust™については[adjust.com]をご覧ください。

Web viewを使用するアプリで、JavaScriptコードから計測する場合は、[iOS Web view SDKガイド][ios-web-views-guide]をご覧ください。

Read this in other languages: [English][en-readme], [中文][zh-readme], [日本語][ja-readme], [한국어][ko-readme].

## 目次

* [サンプルアプリ](#example-apps)
* [基本的な導入方法](#basic-integration)
   * [プロジェクトにSDKを追加](#sdk-add)
   * [iOS frameworksを追加](#sdk-frameworks)
   * [アプリにSDKを実装](＃sdk-integrate)
   * [基本設定](#basic-setup)
      * [iMessage固有の設定](#basic-setup-imessage)
   * [Adjustログ](#adjust-logging)
   * [アプリのビルド](#build-the-app)
* [追加機能](#additional-feature)
   * [AppTrackingTransparency framework](#att-framework)
      * [アプリトラッキング承認ラッパー](#ata-wrapper)
      * [現在の承認ステータスを取得](#ata-getter)
   * [SKAdNetwork frameworks](#skadn-framework)
      * [SKAdNetworkのconversion valueを更新](#skadn-update-conversion-value)
   * [イベントトラッキング](#event-tracking)
      * [収益のトラッキング](#revenue-tracking)
      * [収益の重複排除](#revenue-deduplication)
      * [アプリ内課金の検証](#iap-verification)
      * [コールバックパラメーター](#callback-parameters)
      * [パートナーパラメーター](#partner-parameters)
      * [コールバックID](#callback-id)
   * [セッションパラメーター](#session-parameters)
      * [セッションコールバックパラメーター](＃session-callback-parameters)
      * [セッションパートナーパラメーター](#session-partner-parameters)
      * [ディレイスタート](#delay-start)
   * [アトリビューションコールバック](#attribution-callback)
   * [広告収益のトラッキング](#ad-revenue)
   * [サブスクリプショントラッキング](#subscriptions)
   * [イベントとセッションのコールバック](#event-session-callbacks)
   * [トラッキングの無効化](#disable-tracking)
   * [オフラインモード](#offline-mode)
   * [イベントバッファリング](#event-buffering)
   * [GDPRの忘れられる権利](#gdpr-forget-me)
   * [サードパーティーとの共有](#third-party-sharing)
      * [サードパーティーとの共有を無効にする](#disable-third-party-sharing)
      * [サードパーティーとの共有を有効にする](#enable-third-party-sharing)
   * [ユーザー同意による計測](#measurement-consent)
   * [SDKシグネチャー](#sdk-signature)
   * [バックグラウンドでのトラッキング](#background-tracking)
   * [デバイスID](#device-ids)
      * [iOS広告ID](#di-idfa)
      * [AdjustデバイスID](#di-adid)
   * [ユーザーアトリビューション](#user-attribution)
   * [Pushトークン](#push-token)
   * [プリインストールトラッカー](#pre-installed-trackers)
   * [ディープリンク](#deeplinking)
      * [スタンダードディープリンク](#deeplinking-standard)
      * [iOS 8以前でのディープリンク](#deeplinking-setup-old)
      * [iOS 9およびそれ以降のバージョンでのディープリンク](#deeplinking-setup-old)
      * [ディファードディープリンク](#deeplinking-deferred)
      * [ディープリンクを介したリアトリビューション](#deeplinking-reattribution)
* [トラブルシューティング](#troubleshooting)
   * [SDK初期化時の問題](#ts-delayed-init)
   * ["Adjust requires ARC"というエラーが表示される](#ts-arc)
   * ["\[UIDevice adjTrackingEnabled\]: unrecognized selector sent to instance”というエラーが表示される](#ts-categories)
   * ["Session failed (Ignoring too frequent session.)"というエラーが表示される](#ts-session-failed)
   * [ログに"Install tracked"が表示されない](#ts-install-tracked)
   * ["Unattributable SDK click ignored"というメッセージが表示される](#ts-iad-sdk-click)
   * [Adjustダッシュボード上に表示される収益データが間違っている](#ts-wrong-revenue-amount)
* [ライセンス](#license)

## <a id="example-apps"></a>サンプルアプリ

[`iOS (Objective-C)`][example-ios-objc]と [`iOS (Swift)`][example-ios-swift]、 [`tvOS`][example-tvos]、 [`iMessage`][example-imessage]、[`Apple Watch`][example-iwatch]のサンプルアプリが[`examples` directory][examples]ディレクトリーにあります。このXcodeプロジェクトを開けば、Adjust SDKの実装方法の実例をご確認いただけます。

## <a id="basic-integration">基本的な導入方法

Adjust SDKをiOSプロジェクトに導入する手順を説明します。Xcodeの使用を想定した説明となります。

### <a id="sdk-add"></a>SDKをプロジェクトに追加

[CocoaPods][cocoapods]を使用している場合は、Podfile`に下記のコードを追加し、[こちらの手順](#sdk-integrate)に進んでください。

```ruby
pod 'Adjust', '~> 4.29.2'
```

または

```ruby
pod 'Adjust', :git => 'https://github.com/adjust/ios_sdk.git', :tag => 'v4.29.2'
```

---

[Carthage][carthage]をご利用の場合は、Cartfile`に下記のコードを追加して[こちらの手順](#sdk-frameworks)に進んでください。

```ruby
github "adjust/ios_sdk"
```

---

Swift Package Managerを使用している場合は、Xcodeで `File > Swift Packages > Add Package Dependency` に移動し、レポジトリアドレスを直接追加できます。その後、[この手順](#sdk-frameworks)から次に進みます。

```
https://github.com/adjust/ios_sdk
```

---

Adjust SDKはフレームワークとしてプロジェクトに追加することもできます。[リリースページ][releases]には、次のアーカイブがあります。

* `AdjustSdkStatic.framework.zip`
* `AdjustSdkDynamic.framework.zip`
* `AdjustSdkTv.framework.zip`
* `AdjustSdkIm.framework.zip`

iOS 8リリース以降、Appleはdynamic frameworks（embedded frameworks）を導入しています。iOS 8以降の端末をターゲットにしている場合は、Adjustの SDK dynamic frameworksを使用することができます。StaticかDynamic frameworksを選択し、プロジェクトに追加してください。

``tvOS` アプリの場合もAdjustSDKの利用が可能です。AdjustSdkTv.framework.zip` アーカイブからAdjustのtvOS frameworkを展開してください。

同様に`iMessage`アプリの場合もAdjustSDKの利用が可能です。`AdjustSdkIm.framework.zip` アーカイブからIM frameworkを展開してください。

### <a id="sdk-frameworks"></a>iOS frameworksを追加

iOS frameworksに対応したAdjust SDKの機能を利用する際は、以下のframeworkをXcodeに追加してください。

- `AdSupport.framework` - SDKがIDFA値および（iOS 14より前の）LAT(Limited Ad Tracking)情報を呼び出します。
- `iAd.framework` - SDKが配信中のASA（Apple Search Ads）キャンペーンのアトリビューションを自動的に処理します。（今後、廃止され`AdServices.framework`に置き換わる予定です）。
- `AdServices.framework`- SDKがASAキャンペーンのアトリビューションを自動的に処理します。
- `CoreTelephony.framework`- SDKが現在のRadio Access Technology（無線アクセス技術）を判別します。
- `StoreKit.framework`- iOS 14またはそれ以降において、このframeworkは` SKAdNetwork` のframeworkにアクセスし、「SKAdNetwork」との通信をAdjust SDKで自動的に処理します。
- `AppTrackingTransparency.framework` -iOS 14またはそれ以降において、このframeworkはSDKがトラッキングに対するユーザー同意を確認するダイアログをラップし、ユーザーの許諾状況を示す値にアクセスします。

### <a id="sdk-integrate"></a>アプリにSDKを実装

PodリポジトリからAdjust SDKを追加した場合は、次のimport statement（インポートステートメント）のいずれかを使用します。

```objc
#import "Adjust.h"
```

または

```objc
#import <Adjust/Adjust.h>
```

---

Adjust SDKを静的/動的フレームワークとして追加した場合、またはCarthageを使う場合は、次のインポートステートメントを使用します：

```objc
#import <AdjustSdk/Adjust.h>
```

---

tvOSアプリケーションでAdjust SDKを使用している場合は、次のインポートステートメントを使用します：

```objc
#import <AdjustSdkTv/Adjust.h>
```

---

iMessageアプリケーションでAdjust SDKを使用している場合は、次のインポートステートメントを使用します：

```objc
#import <AdjustSdkIm/Adjust.h>
```

次に、インストール計測に必要な基本設定を説明します。

### <a id="basic-setup"></a>基本設定

Project Navigator上で、アプリケーションデリゲートのソースファイルを開いてください。ファイルの先頭に`import` の記述を追加し、`didFinishLaunching`か`didFinishLaunchingWithOptions`のメソッド中に下記の`Adjust`コールを追加してください。

```objc
#import "Adjust.h"
// or #import <Adjust/Adjust.h>
// or #import <AdjustSdk/Adjust.h>
// or #import <AdjustSdkTv/Adjust.h>
// or #import <AdjustSdkIm/Adjust.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                            environment:environment];

[Adjust appDidLaunch:adjustConfig];
```

![][delegate]

**注意**：Adjust SDKの初期化は最も重要なプロセスです。問題が発生した際は[トラブルシューティングのセクション](#ts-delayed-init)をご確認ください。

`{YourAppToken}`をアプリトークンに差し替えてください。トークンは[管理画面]で確認できます。

テストと本番に合わせて2種類の`environment`をご利用いただけます：

```objc
NSString *environment = ADJEnvironmentSandbox;
NSString *environment = ADJEnvironmentProduction;
```

**重要:** 開発段階のインストールテストでは`ADJEnvironmentSandbox`をご利用ください。アプリのリリース前に`ADJEnvironmentProduction`に変更してください。

Sandbox環境で計測された数値はSandboxレポートに表示されます。Production環境で計測された数値は本番レポートに表示されます。テスト数値と実際のトラフィックが混ざらないよう、環境設定の記述を切り替えてご利用ください。

### <a id="basic-setup-imessage"></a>iMessage固有の設定

**ソースからSDKを追加する：Adjust SDKをiMessageアプリケーション**にソース**から追加する場合、プリプロセッサマクロ（pre-processor macro）**ADJUST_IM=1**がiMessageプロジェクトで設定されていることを確認してください。

**SDKをフレームワークとして追加する:** iMessageアプリケーションに`AdjustSdkIm.framework`を追加した後、`Build Phases`プロジェクト設定で`New Copy Files Phase`を追加します。AdjustSdkIm.framework`をFrameworks`フォルダにコピーするを選択してください。

**セッショントラッキング：** セッショントラッキングをiMessageアプリで正しく機能させるためには、追加の実装ステップを1回実行します。標準のiOSアプリでは、Adjust SDKはiOSシステム通知に自動的に登録され、アプリがいつ入力されたか、フォアグラウンドになったかを知ることができます。これはiMessageアプリの場合には該当しないため、iMessageアプリビューコントローラの`trackSubsessionStart`メソッドと`trackSubsessionEnd`メソッドへの明示的な呼び出しを追加する必要があります。これにより、アプリがフォアグラウンドあるかどうかをSDKに認識させることができます。

`didBecomeActiveWithConversation`のメソッド中に`trackSubsessionStart`を追加します。

```objc
-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    // Use this method to configure the extension and restore previously stored state.

    [Adjust trackSubsessionStart];
}
```

Add call to `trackSubsessionEnd` inside of `willResignActiveWithConversation:` method:

```objc
-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.

    [Adjust trackSubsessionEnd];
}
```

このセットを使用すると、Adjust SDKはiMessageアプリ内でセッションのトラッキングを正常に行うことができます。

注意：書き込んだiOSアプリとiMessageの拡張機能は、異なるメモリ空間で動作しており、バンドルIDも異なります。２つの場所で同じアプリトークンを使用してAdjust SDKを初期化すると、相互が認識しない2つの独立したインスタンスが生成され、ダッシュボードのデータが混在してしまうことがあります。これを避けるためには、iMessageアプリをAdjust管理画面に新規追加し、登録済みのiOSアプリと異なるアプリトークンを使ってSDKを初期化してください。

### <a id="adjust-logging"></a>Adjustログ

`ADJConfig`インスタンスの`setLogLevel:に設定するパラメーターに合わせてXcodeに表示されるログのボリュームが変わります。

```objc
[adjustConfig setLogLevel:ADJLogLevelVerbose];  // enable all logging
[adjustConfig setLogLevel:ADJLogLevelDebug];    // enable more logging
[adjustConfig setLogLevel:ADJLogLevelInfo];     // the default
[adjustConfig setLogLevel:ADJLogLevelWarn];     // disable info logging
[adjustConfig setLogLevel:ADJLogLevelError];    // disable warnings as well
[adjustConfig setLogLevel:ADJLogLevelAssert];   // disable errors as well
[adjustConfig setLogLevel:ADJLogLevelSuppress]; // disable all logging
```

本番用アプリにAdjust SDKのログを表示しない場合は、ログレベルを`ADJLogLevelSuppress` に設定してください。加えて、suppress log level modeが有効化する別のコンストラクタでADJConfig`オブジェクトを下記のように初期化してください。

```objc
#import "Adjust.h"
// or #import <Adjust/Adjust.h>
// or #import <AdjustSdk/Adjust.h>
// or #import <AdjustSdkTv/Adjust.h>
// or #import <AdjustSdkIm/Adjust.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                            environment:environment
                                   allowSuppressLogLevel:YES];

[Adjust appDidLaunch:adjustConfig];
```

### <a id="build-the-app"></a>アプリのビルド

アプリをビルドして起動してください。初回起動後、コンソールのSDKログに、`Install tracked`が表示されます。

![][run]

## <a id="additional-feature">追加機能

プロジェクトにAdjust SDKを実装すると、以下の機能をご利用できるようになります。

### <a id="att-framework"></a>AppTrackingTransparency framework

各パッケージが送信されるたびに、Adjustのバックエンドは、ユーザーの許諾状況を表す4つの値のいずれかを受信します。

- Authorized（承認）
- Denied（拒否）
- Not Determined（未決定）
- Restricted（制限あり）

デバイスがアプリ関連データへのアクセスに対するユーザーの許諾状況の承認リクエスト（ユーザーのデバイストラッキングに使用）を受信した後は、返されるステータスはAuthorizedあるいはDeniedになります。

デバイスがアプリ関連データへのアクセスの承認リクエスト（ユーザーあるいはデバイスのトラッキングに使用）を受信する前は、返されるステータスはNot Determinedになります。

アプリのトラッキングデータの使用が制限されている場合は、返されるステータスはRestrictedになります。

表示されるポップアップダイアログのカスタマイズを希望しない場合のために、Adjust SDKには、ユーザーがポップアップダイアログに応答した後に、更新ステータスを受信するメカニズムが組み込まれています。新しい許諾ステータスをバックエンドに簡単かつ効率的に伝達するために、Adjust SDKはアプリのトラッキング承認メソッドのラッパー(App-tracking authorisation wrapper)を提供しています。次の項目の説明をご覧ください。

### <a id="ata-wrapper"></a>アプリトラッキング承認ラッパー(App-tracking authorisation wrapper)

Adjust SDKは、アプリトラッキング承認ラッパーを使用して、アプリ関連データへのアクセスに対するユーザーの許諾状況をリクエストすることができます。Adjust SDKには、[requestTrackingAuthorizationWithCompletionHandler:](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorizationwith?language=objc)メソッドに基づいて構築されたラッパーが用意されており、ユーザーの許諾情報を取得するコールバックメソッドを定義することもできます。また、このラッパーを使用することで、ユーザーがポップアップダイアログに応答すると、その内容がコールバックメソッドで直ちに伝達されます。SDKは、ユーザーの選択をバックエンドにも通知します。「NSUInteger」の値はコールバックメソッドによって伝達されます。値の意味は次のとおりです。

- 0: `ATTrackingManagerAuthorizationStatusNotDetermined`（承認ステータスは「未決定」）
- 1: `ATTrackingManagerAuthorizationStatusRestricted`（承認ステータスは「制限あり」）
- 2: `ATTrackingManagerAuthorizationStatusDenied`（承認ステータスは「拒否」）
- 3: `ATTrackingManagerAuthorizationStatusAuthorized`（承認ステータスは「承認」）

このラッパーを使用するためには、次のように呼び出してください。

```objc
[Adjust requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
    switch (status) {
        case 0:
            // ATTrackingManagerAuthorizationStatusNotDetermined case
            break;
        case 1:
            // ATTrackingManagerAuthorizationStatusRestricted case
            break;
        case 2:
            // ATTrackingManagerAuthorizationStatusDenied case
            break;
        case 3:
            // ATTrackingManagerAuthorizationStatusAuthorized case
            break;
    }
}];
```

### <a id="ata-getter"></a>現在の承認ステータスを取得

現在のアプリトラッキング承認ステータスを取得するには、`[Adjust appTrackingAuthorizationStatus]` を呼び出します。これは以下のいずれかを返します。

* `0`: ユーザーにまだリクエストをしていない場合
* `1`: ユーザーのデバイスが制限されている場合
* `2`: ユーザーがIDFAへのアクセスを拒否した場合
* `3`: ユーザーがIDFAへのアクセスを承認した場合
* `-1`: ステータスが不明な場合


### <a id="skadn-framework"></a>SKAdNetwork frameworks

Adjust iOS SDK v4.23.0以上を実装済みであり、アプリがiOS14で実行されている場合、SKAdNetworkとの通信はデフォルトでONに設定されますが、OFFに切り替えることもできます。ONに設定すると、SDKの初期化時にSKAdNetworkのアトリビューションがAdjustによって自動的に登録されます。conversion value（コンバージョン値）を受信するためにAdjust管理画面でイベントを設定する場合、conversaion valueのデータはAdjustバックエンドからSDKに送信されます。その後、SDKによってconversion valueが設定されます。SKAdNetworkコールバックデータをAdjustで受信した後、このデータが管理画面に表示されます。

Adjust SDKがSKAdNetworkと自動的に通信しないようOFFに切り替える場合は、configurationオブジェクトで次のメソッドを呼び出すことによって通信を無効化できます。

```objc
[adjustConfig deactivateSKAdNetworkHandling];
```

### <a id="skadn-update-conversion-value"></a>SKAdNetworkのconversion valueを更新

iOS SDK v4.26.0では、Adjust SDKラッパーメソッド`updateConversionValue:`を使ってSKAdNetworkのconversion valueを更新できます。

```objc
[Adjust updateConversionValue:6];
```

### <a id="event-tracking"></a>イベントトラッキング

Adjustではアプリ内イベントの計測も可能です。ここでは、特定のボタンに対するすべてのタップを計測する場合について説明します。[管理画面]で新しいイベントトークンを作成し、`abc123`というイベントトークンが発行されたとします。次に、ボタンの`buttonDown`メソッドで以下のコードを追加してタップを計測します。

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[Adjust trackEvent:event];
```

ユーザーがボタンをタップすると、ログに`Event tracked`が表示されます。

イベントインスタンスは、計測前にイベントをさらに設定するのに使用できます。

### <a id="revenue-tracking"></a>収益（アプリ内課金）のトラッキング

ユーザーによって発生したアプリ内課金の計測も可能です。例えば、1回のタップで1ユーロセントの課金が発生する場合、収益イベントを以下のように実装してください。

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event setRevenue:0.01currency:@"EUR"];

[Adjust trackEvent:event];
```

もちろん、これはコールバックパラメーターと紐付けることができます。

通貨コードを設定すると、Adjustは計測された課金金額を設定されたレポート通貨に自動換算します。[通貨換算についての詳細はこちら][currency-conversion]をご覧ください。

収益とイベントトラッキングの詳細については、[イベントトラッキングガイド][tracking-purchases-and-revenues] をご覧ください。

### <a id="revenue-deduplication"></a>収益の重複排除

収益の重複計測を防ぐため、オプションとしてトランザクションIDをでパスすることもできます。最新の10のトランザクションIDが記憶され、収益イベントに紐づけられたトランザクションIDが重複している場合、そのイベントを排除します。これは、アプリ内購入のトラッキングに特に有効です。以下の例をご参照ください。

アプリ内購入をトラッキングする際は、状態が`SKPaymentTransactionStatePurchased`に変わった場合にのみ`paymentQueue:updatedTransactions`で`finishTransaction`の後に`trackEvent`をコールするようにしてください。これにより、実際に発生しなかった収益イベントがトラッキングされるのを防ぐことができます。

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased:
                [self finishTransaction:transaction];

                ADJEvent *event = [ADJEvent eventWithEventToken:...];
                [event setRevenue:... currency:...];
                [event setTransactionId:transaction.transactionIdentifier];// avoid duplicates
                [Adjust trackEvent:event];

                break;
            // more cases
        }
    }
}
```

### <a id="iap-verification"></a>アプリ内購入認証

Adjustのサーバーサイドのレシート認証ツールである購入認証を使ってアプリ内で行われたアプリ内収益の有効性を調べる際は、iOS purchase SDKをご利用ください。詳細は[こちら][ios-purchase-verification] をご覧ください。

### <a id="callback-parameters"></a>コールバックパラメーター

[管理画面]でイベントのコールバックURLを登録することができます。イベントが計測されると、設定したコールバックURLにGETリクエストを送信します。商品IDなど、お客様独自のカスタムID（コールバックパラメーター）を送信することが可能です。イベント計測前に`addCallbackParameter`をコールするよう実装してください。AdjustはコールバックパラメーターをコールバックURLに追加して送信します。

例えば、コールバックURL `https://www.mydomain.com/callback`に対して、カスタムID（Keyとfooの値）を送信する場合の実装方法は下記の通りです。

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event addCallbackParameter:@"key" value:@"value"];
[event addCallbackParameter:@"foo" value:@"bar"];

[Adjust trackEvent:event];
```

この場合、Adjustはkeyとfooの値を追加してGETリクエストを送信します。

    https://www.mydomain.com/callback?key=value&foo=bar

Adjustはさまざまなプレースホルダー（ローデータ送信）をサポートしています。例えば`{idfa}`はパラメーター値として利用できます。コールバック内で、プレースホルダー{idfa}は該当デバイスのIDFAに置き換えられます。またAdjustは、お客様独自のカスタムパラメーターを保存することはなく、コールバックのみに唯一利用します。イベント発生時にコールバックURLを設定していない場合、カスタムパラメーターが送信もされないことに注意してください。

使用可能なプレースホルダー（パラメーター）の一覧やコールバックの詳細は、[コールバックガイド][callbacks-guide]を参照してください。

### <a id="partner-parameters"></a>パートナーパラメーター

Adjustでは、管理画面でパラメーターを追加して、連携を有効化したネットワークパートナー対してもカスタムパラメーター（お客様の独自IDなど）を送信可能です。

これは上記のコールバックパラメーターと同様に機能しますが、`ADJEvent`イベントインスタンスの`addPartnerParameter`メソッドをコールすることにより追加されます。

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event addPartnerParameter:@"key" value:@"value"];
[event addPartnerParameter:@"foo" value:@"bar"];

[Adjust trackEvent:event];
```

スペシャルパートナーとの連携方法の詳細については、[スペシャルパートナーガイド] [スペシャルパートナー]をご覧ください。

### <a id="callback-id"></a>コールバックID

計測イベントにカスタムIDを追加できます。このIDはイベント計測成功（または計測失敗）後に通知され、どのイベントが正しく計測されたか知ることが可能です。`ADJEvent`インスタンスに`setCallbackId`メソッドをコールしてこのIDを設定してください：


```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event setCallbackId:@"Your-Custom-Id"];

[Adjust trackEvent:event];
```

### <a id="session-parameters"></a>セッションパラメーター

セッションパラメーターは、Adjust SDKが計測したすべてのイベントやセッション発生時に送信されます。セッションパラメーターはローカルに保存されるため、毎回追加する必要はありません。同じパラメーターを2回追加しても何も起こりません。

初回インストール発生時にセッションパラメーターを送信する場合は、Adjust SDKが`[Adjust appDidLaunch:]`で初期化される前にパラメーターをコールする必要があります。インストール時にパラメーターを送信したいものの、必要な値がアプリ起動後にしか取得できない場合は、Adjust SDKの初期化を[遅らせる](#delay-start)ことができます。

### <a id="session-callback-parameters"></a>セッションコールバックパラメーター

[イベント](#callback-parameters)で設定された同じコールバックパラメーター（お客様のカスタムID）を、イベントまたはセッション発生時にに送信することもできます。

セッションコールバックパラメーターとイベントコールバックパラメーターの仕様は似ています。イベントにkeyとvalueを追加する代わりに、`Adjust`の`addSessionCallbackParameter:value:`をコールする際にパラメーターを追加してください。

```objc
[Adjust addSessionCallbackParameter:@"foo" value:@"bar"];
```

セッションコールバックパラメーターは、イベント計測用のコールバックパラメーターとマージされます。イベントに追加されたコールバックパラメーターは、セッションコールバックパラメーターより優先されます。イベント用のコールバックパラメーターがセッション用のパラメーターと同じkeyを持っている場合、イベント用のコールバックパラメーターのvalueが優先されます。

`removeSessionCallbackParameter`メソッドに指定のkeyを渡すことで、特定のセッションパートナーパラメーターを削除することができます。

```objc
[Adjust removeSessionCallbackParameter:@"foo"];
```

セッションコールバックパラメーターからすべてのキーと値を削除したい場合は、`resetSessionCallbackParameters`メソッドを使ってリセットすることができます。

```objc
[Adjust resetSessionCallbackParameters];
```

### <a id="session-partner-parameters"></a>セッションパートナーパラメーター

イベントやセッション発生時に送信される[セッションコールバックパラメーター](#session-callback-parameters)と同じように、セッションパートナーパラメーターも用意されています。

セッションパートナーパラメーターはAdjustのネットワークパートナーに送信され、Adjust[管理画面]のパートナー設定で有効化された連携に利用されます。

セッションパートナーパラメーターとイベントパートナーパラメーターの仕様は似ています。イベントにkeyとvalueを追加する代わりに、`Adjust`メソッドの`addSessionPartnerParameter:value:`のコール時に追加してください。

```objc
[Adjust addSessionPartnerParameter:@"foo" value:@"bar"];
```

セッションパートナーパラメーターは、イベント計測用のパートナーパラメーターとマージされます。イベントに追加されたパートナーパラメーターは、セッションパートナーパラメーターより優先されます。イベントに追加されたパートナーパラメーターがセッションから追加されたパラメーターと同じkeyを持っている場合、イベントに追加されたパートナーパラメーターのvalueが優先されます。

`removeSessionPartnerParameter`メソッドに指定のkeyを渡すことで、特定のセッションパートナーパラメーターを削除することができます。

```objc
[Adjust removeSessionPartnerParameter:@"foo"];
```

セッションパートナーパラメーターからすべてのkeyとvalueを削除したい場合は、`resetSessionPartnerParameters`メソッドを使ってリセットすることができます。

```objc
[Adjust resetSessionPartnerParameters];
```

### <a id="delay-start"></a>ディレイスタート

Adjust SDKのインストール計測を遅らせると、ユニークID（お客様の会員ID等）をセッションパラメーターとして取得して、インストール計測時に送信できるようになります。

`ADJConfig`インスタンスの`setDelayStart`メソッドで、遅らせる時間を秒単位で設定してください。

```objc
[adjustConfig setDelayStart:5.5];
```

この場合、Adjust SDKは最初のインストールセッションやイベントを5.5秒間は送信しません。設定された時間が過ぎるまで、もしくは`[Adjust sendFirstPackages]`がコールされると、セッションパラメーターはディレイインストールセッションやイベントに追加され、Adjust SDKは通常通り計測を再開します。

**Adjust SDKのディレイスタートが指定できる時間は最大10秒です**。

### <a id="attribution-callback"></a>アトリビューションコールバック

流入元のアトリビューションの更新通知をアプリが受けるために、デリゲートコールバックを登録することができます。アトリビューションには複数の流入元が紐づく可能性があるため、この情報は同時に送ることができません。App Delegateでオプションのデリゲートプロトコルを実装するには、以下の手順に従ってください。

Adjustの[該当するアトリビューションデータポリシー][attribution-data]を考慮するようにしてください。

1. `AppDelegate.h`を開き、importと`AdjustDelegate`宣言を追加します。

    ```objc
    @interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>
    ```

2. `AppDelegate.m`を開き、次のデリゲートコールバック関数をApp Delegateに追加します。

    ```objc
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    }
    ```

3. `ADJConfig`インスタンスでデリゲートを設定します。

    ```objc
    [adjustConfig setDelegate:self];
    ```

デリゲートコールバックは`ADJConfig`インスタンスを使用して設定されるため、`[Adjust appDidLaunch:adjustConfig]`をコールする前に`setDelegate`をコールする必要があります。

このデリゲート関数は、SDKが最後のアトリビューションデータを取得した後に作動します。デリゲート関数内で`attribution`パラメーターを確認することができます。プロパティの概要は次のとおりです。

- `NSString trackerToken` 最新アトリビューションのトラッカートークン
- `NSString trackerName` 最新アトリビューションのトラッカー名
- `NSString network` 最新アトリビューションのネットワークのグループ階層
- `NSString campaign` 最新アトリビューションのキャンペーンのグループ階層
- `NSString adgroup` 最新アトリビューションのアドグループのグループ階層
- `NSString creative` 最新アトリビューションのクリエイティブのグループ階層
- `NSString clickLabel` 最新アトリビューションのクリックラベル
- `NSString adid` Adjustが提供するユニークデバイスID(adid)
- `NSString costType` コストタイプの文字列
- `NSNumber costAmount` コストの金額
- `NSString costCurrency` コスト通貨の文字列

値がない場合は、デフォルトで`nil`になります。

注：コストデータ - `costType`、`costAmount`および`costCurrency`は、`setNeedsCost:`メソッドを呼び出して`ADJConfig`で設定された場合にのみ利用可能です。設定されていない場合、あるいは設定されていてもアトリビューションの一部でない場合は、これらのフィールドは`nil`の値を持ちます。この機能はSDK v4.24.0以降のみ利用可能です。

### <a id="ad-revenue"></a>広告収益のトラッキング

Adjust SDKを利用して、以下のメソッドを呼び出し広告収益情報をトラッキングできます。

```objc
[Adjust trackAdRevenue:source payload:payload];
```

Adjust SDKにパスするメソッドの引数は以下の通りです。

- `source` - 広告収益情報のソースを指定する`NSString`オブジェクト
- `payload` - 広告収益のJSONを格納する`NSData`オブジェクト

現在、Adjustは以下の`source`パラメーターの値のみ対応しています。

- `ADJAdRevenueSourceMopub` - メディエーションプラットフォームのMoPubを示します（詳細は、[統合ガイド][sdk2sdk-mopub]を参照ください）。

### <a id="subscriptions"></a>サブスクリプショントラッキング

**注**：この機能はネイティブのSDK v4.22.0以降のみ利用可能です。最低でもバージョン4.22.1を使用することを推奨します。 

**重要**：以下の手順は、SDK内でサブスクリプション計測を行う場合に設定してください。設定を完了するには下記アプリ内へのコード実装の他、Adjustの内部システムにアプリ固有の情報を別途追加する必要があります。追加作業はAdjustの担当者によって行われるため、support@adjust.comまたは担当のアカウントマネージャーまでお問い合わせください。 

App Storeのサブスクリプションを計測し、それぞれの有効性をAdjust SDKで確認できます。サブスクリプションの購入が完了したら、次のようにAdjust SDKを呼び出します。

```objc
ADJSubscription *subscription = [[ADJSubscription alloc] initWithPrice:price
                                                              currency:currency
                                                         transactionId:transactionId
                                                            andReceipt:receipt];
[subscription setTransactionDate:transactionDate];
[subscription setSalesRegion:salesRegion];

[Adjust trackSubscription:subscription];
```

状態が`SKPaymentTransactionStatePurchased`または`SKPaymentTransactionStateRestored`に変わった時にのみこれを行ってください。次に、`paymentQueue:updatedTransactions`で`finishTransaction`をコールしてください。

Subscription tracking parameters:

- [price](https://developer.apple.com/documentation/storekit/skproduct/1506094-price?language=objc)
- currency（[priceLocale](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc)オブジェクトの[currencyCode](https://developer.apple.com/documentation/foundation/nslocale/1642836-currencycode?language=objc)を渡す必要がある）
- [transactionId](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc)
- [receipt](https://developer.apple.com/documentation/foundation/nsbundle/1407276-appstorereceipturl)
- [transactionDate](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411273-transactiondate?language=objc)
- salesRegion（[priceLocale](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc)オブジェクトの[countryCode](https://developer.apple.com/documentation/foundation/nslocale/1643060-countrycode?language=objc)を渡す必要がある）

イベント計測と同様に、コールバックパラメーターやパートナーパラメーターをサブスクリプションオブジェクトに付与できます。

```objc
ADJSubscription *subscription = [[ADJSubscription alloc] initWithPrice:price
                                                              currency:currency
                                                         transactionId:transactionId
                                                            andReceipt:receipt];
[subscription setTransactionDate:transactionDate];
[subscription setSalesRegion:salesRegion];

// add callback parameters
[subscription addCallbackParameter:@"key" value:@"value"];
[subscription addCallbackParameter:@"foo" value:@"bar"];

// add partner parameters
[subscription addPartnerParameter:@"key" value:@"value"];
[subscription addPartnerParameter:@"foo" value:@"bar"];

[Adjust trackSubscription:subscription];
```

### <a id="event-session-callbacks"></a>イベントとセッションのコールバック

イベントとセッションの双方もしくはどちらかをトラッキングし、成功か失敗かの通知を受け取れるようデリゲートコールバックを登録できます。ここでも[アトリビューションコールバック](#attribution-callback)に使用されている`AdjustDelegate`プロトコルを任意で使うことができます。

同じ手順に従って、成功したイベントへのデリゲートコールバック関数を以下のように実装します。

```objc
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
}
```

失敗したイベントへのデリゲートコールバック関数

```objc
- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
}
```

同様に、成功したセッション

```objc
- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
}
```

失敗したセッション

```objc
- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
}
```

デリゲート関数は、SDKがサーバーにパッケージ送信を試みた後でコールされます。デリゲートコールバック内でデリゲートコールバック用のレスポンスデータオブジェクトを確認することができます。レスポンスデータのプロパティの概要は以下のとおりです。

- `NSString message` サーバーからのメッセージまたはSDKのエラーログ
- `NSString timeStamp` サーバーからのタイムスタンプ
- `NSString adid` Adjustから提供するユニークデバイスID（adid）
- `NSDictionary jsonResponse` サーバーからのレスポンスのJSONオブジェクト

どちらのイベントレスポンスデータオブジェクトも以下を含みます。

- `NSString eventToken` トラッキングしたパッケージがイベントだった場合、そのイベントトークン
- `NSString callbackId` イベントオブジェクトにカスタム設定されたコールバックID

値がない場合は、デフォルトで`nil`になります。

失敗したイベントとセッションは以下を含みます。

- `BOOL willRetry` しばらく後に再送を試みる予定であるかどうかを示します。

### <a id="disable-tracking"></a>トラッキングの無効化

`setEnabled`にパラメーター`NO`を渡すことで、AdjustSDKが行うデバイスのアクティビティのトラッキングをすべて無効にすることができます。**この設定はセッション間で記憶されます**。

```objc
[Adjust setEnabled:NO];
```

<a id="is-enabled">Adjust SDKが現在有効化されているかどうかは、`isEnabled`関数を呼び出すことで確認できます。また、`setEnabled`関数に`YES`を渡せば、Adjust SDKを有効化することができます。

### <a id="offline-mode"></a>オフラインモード

Adjustのサーバーへの送信を一時停止し、保持されているトラッキングデータを後から送信するためにAdjust SDKをオフラインモードにすることができます。オフラインモード中はすべての情報がファイルに保存されるため、イベントを多く発生させすぎないようにご注意ください。

`YES`パラメーターで`setOfflineMode` を呼び出すと、オフラインモードを有効にできます。

```objc
[Adjust setOfflineMode:YES];
```

反対に、`NO`パラメーターで`setOfflineMode`を呼び出すと、オフラインモードを解除できます。Adjust SDKがオンラインモードに戻った時、保存されていた情報は計測時の正しいタイムスタンプでAdjustのサーバーに送られます。

トラッキングの無効化とは異なり、この設定はセッション間で**記憶されません**。オフラインモード時にアプリを終了しても、次に起動した時にはオンラインモードとしてアプリが起動します。

### <a id="event-buffering">イベントバッファリング</a>

イベントトラッキングを酷使している場合、HTTPリクエストを遅延させて1分ごとにまとめて送信したほうが良い場合があります。その場合は`ADJConfig`インスタンスでイベントバッファリングを有効にしてください。

```objc
[adjustConfig setEventBufferingEnabled:YES];
```

何も設定されていない場合、イベントバッファリングは**デフォルトで無効になっています**。

### <a id="gdpr-forget-me"></a>GDPRの忘れられる権利

EUの一般データ保護規制(GDPR)第17条に基づいて、ユーザーが「忘れられる権利（right to be forgotten）」を行使した場合は、Adjustに通知することができます。次のメソッドを呼び出して、ユーザーの申請をAdjustバックエンドに伝えるようAdjust SDKに指示してください。

```objc
[Adjust gdprForgetMe];
```

この情報を受け取ると、Adjustは該当ユーザーのデータを消去し、Adjust SDKはユーザーのトラッキングを停止します。以降、そのデバイスからのリクエストはAdjustに送信されません。

## <a id="third-party-sharing"></a>特定のユーザーの計測データをサードパーティーとの共有

ユーザーがサードパーティーとのデータ共有を無効化、有効化、あるいは再有効化する情報をAdjustに送信することができます。

### <a id="disable-third-party-sharing"></a>特定のユーザーについてのサードパーティーとの共有を無効にする

次のメソッドを呼び出して、ユーザーの選択（データ共有を無効にする）をAdjustバックエンドに伝えるようAdjust SDKに指示してください。

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:@NO];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

この情報を受け取ると、Adjustは特定のユーザーに関してパートナーとのデータ共有をブロックします。Adjust SDKは通常通り機能します。

### <a id="enable-third-party-sharing">特定のユーザーについてのサードパーティーとの共有を無効にする</a>

次のメソッドを呼び出して、データ共有あるいはデータ共有の変更に関するユーザーの選択をAdjustバックエンドに伝えるようAdjust SDKに指示してください。

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:@YES];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

この情報を受け取ると、Adjustは特定のユーザーに関してパートナーとのデータ共有設定を変更します。Adjust SDKは通常通り機能します。

次のメソッドを呼び出して、詳細なオプションをAdjustバックエンドに送信するようAdjust SDKに指示してください。

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:nil];
[adjustThirdPartySharing addGranularOption:@"PartnerA" key:@"foo" value:@"bar"];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

### <a id="measurement-consent"></a>特定のユーザーについての同意の計測

Adjust管理画面で同意有効期間とユーザーデータ保持期間を含むデータプライバシー設定を有効化あるいは無効化するには、以下のメソッドを実装してください。

次のメソッドを呼び出して、データプライバシー設定をAdjustバックエンドに伝えるようAdjust SDKに指示してください。

```objc
[Adjust trackMeasurementConsent:YES];
```

この情報を受け取ると、Adjustは特定のユーザーに関してパートナーとのデータ共有設定を変更します。Adjust SDKは通常通り機能します。

### <a id="sdk-signature"></a>SDKシグネチャー

Adjust SDKシグネチャーはアプリごとに有効化できます。この機能の利用をご希望の場合は、担当のテクニカルアカウントマネージャーまでお問い合わせください。

すでにアカウントでSDKシグネチャーが有効になっており、Adjust管理画面のアプリシークレット（App Secret）にアクセスできる場合は、以下の方法を使用してアプリにSDKシグネチャーを実装してください。

App Secretは、`AdjustConfig`インスタンスで`setAppSecret`をコールすることで設定されます。

```objc
[adjustConfig setAppSecret:secretId info1:info1 info2:info2 info3:info3 info4:info4];
```

### <a id="background-tracking"></a>バックグラウンドでのトラッキング

Adjust SDKはデフォルトではアプリがバックグラウンドにある時はHTTPリクエストを停止します。この設定は`AdjustConfig`インスタンスで変更できます。

```objc
[adjustConfig setSendInBackground:YES];
```

設定されていない場合、バックグラウンドでの送信は**デフォルトで無効になっています**。

### <a id="device-ids"></a>デバイスID

Adjust SDKを使って、一部のデバイスIDを取得することができます。

### <a id="di-idfa"></a>iOS広告ID

Google Analyticsなどの一部のサービスでは、レポートの重複を防ぐためにデバイスIDとクライアントIDを連携させることが求められます。

デバイスID（IDFA）を取得するには、`idfa`関数をコールします。

```objc
NSString *idfa = [Adjust idfa];
```

### <a id="di-adid"></a>AdjustデバイスID (adid)

アプリがインストールされている各デバイスに対して、Adjust は、バックエンドでユニークな**Adujust デバイスID (**adid**)**を生成します。このIDを取得するためには、`Adjust`インスタンスで以下のメソッドをコールします。

```objc
NSString *adid = [Adjust adid];
```

**注意**：**adid**は、Adjust SDKによるインストール計測が完了した後に初めて利用可能となります。その時点よりAdjust SDKはデバイスの**adid**に関する情報を保有するようになり、このメソッドを使ってその情報にアクセスできます。よって、SDKが初期化されインストール計測が完了しないと、**adid**にアクセスすることは**できません**。

### <a id="user-attribution"></a>ユーザーアトリビューション

[アトリビューションコールバック](#attribution-callback)で説明したとおり、アトリビューション情報に変更がある度に、このコールバックが起動されます。`Adjust`インスタンスの以下のメソッドをコールすることで、必要な時にいつでもユーザーのアトリビューション情報にアクセスすることができます。

```objc
ADJAttribution *attribution = [Adjust attribution];
```

**注意**：最新のアトリビューション情報は、Adjustバックエンドによるインストール計測が完了し、アトリビューションコールバックがトリガーされた後にのみ利用が可能となります。その時点よりAdjust SDKはユーザーのアトリビューション情報を保有するようになり、このメソッドを使ってアクセス可能になります。SDKが初期化されアトリビューションコールバックが最初に起動されるまでは、ユーザーのアトリビューション値にアクセスできません。

### <a id="push-token"></a>Pushトークン

Pushトークン（device token）は、オーディエンスビルダーやコールバックに使用されます。また、アンインストールや再インストールのトラッキングにも必要です。

Push通知トークンをAdjustに送信するには、App Delegateの`didRegisterForRemoteNotificationsWithDeviceToken`で以下のコールを`Adjust`に追加してください。

```objc
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Adjust setDeviceToken:deviceToken];
}
```

### <a id="pre-installed-trackers"></a>プリインストールトラッカー

Adjust SDKを使用して、出荷直後のスマートフォンにプリインストールされたアプリの初回起動を計測する場合は、以下の手順に従ってください。

1. [管理画面]で新しいトラッカーを作成してください。
2. App Delegateを開き、`ADJConfig`のデフォルトトラッカーを追加します。

  ```objc
  ADJConfig*adjustConfig = [ADJConfig configWithAppToken:yourAppToken environment:environment];
  [adjustConfig setDefaultTracker:@"{TrackerToken}"];
  [Adjust appDidLaunch:adjustConfig];
  ```

  `{TrackerToken}`にステップ2で作成したトラッカートークンを入れます。管理画面にはトラッカー
  URL（`http://app.adjust.com/`など）が表示されます。ソースコード内には、このURL全体ではなく、6文字のトークンのみを
  入力してください。

3. アプリをビルドして実行します。XCodeに下記のような行が表示されるはずです。

    ```
    Default tracker: 'abc123'
    ```

### <a id="deeplinking"></a>ディープリンク

URLからアプリへのディープリンクオプションを使ったAdjustトラッカーURLをご利用の場合、ディープリンクURLとその内容の情報を得ることが可能です。アプリをすでにインストールしている状態でそのURLを訪れる（スタンダードディープリンク）ユーザーもいれば、またインストールしていないユーザーが開く（ディファードディープリンク）場合もあります。Adjust SDKはこれらを両方サポートしており、いずれの場合でも、トラッカーURLがクリックされアプリが起動された後にディープリンクURLが提供されます。アプリでこの機能を使用するには、適切な設定を行う必要があります。

### <a id="deeplinking-standard"></a>スタンダードディープリンク

ユーザーがすでにアプリをインストールしているユーザーがディープリンク情報が付与されたトラッカーURLを開いた場合、アプリが起動されディープリンクの情報がアプリに送信されます。これを解析し、次に何をするかを決めることができます。iOS 9以降より、Apple社はディープリンクの扱い方を変更しています。どんな状況においてアプリにディープリンクを使用したいかによって（または多様なデバイスをサポートするために両方を使用したい場合）、以下のシナリオのいずれか、または両方に対応できるようにアプリを設定する必要があります。

### <a id="deeplinking-setup-old"></a>iOS 8以前でのディープリンク

iOS 8以前のバージョンにおけるディープリンクは、カスタムURLスキーム設定によって行われます。アプリが開かれるためのカスタムURLスキーム名を付ける必要があります。このスキーム名は、`deep_link`パラメーターの一部としてAdjustトラッカーURLにも使用されます。これを設定するには、`Info.plist`ファイルを開き、新しい`URL types`を追加します。そこで、アプリのバンドルIDを`URL identifier`とし、`URL schemes`でアプリで使用したいスキーム名を追加します。以下に、`adjustExample`というスキーム名を使用したアプリの例を示します。

![][custom-url-scheme]

この設定が完了した後、`deep_link`パラメーターを持つ、選択したスキーム名を含むAdjustトラッカーURLをクリックするとアプリが起動されます。アプリが起動されると、`AppDelegate`クラスの`openURL`メソッドがトリガーされ、トラッカーURLの`deep_link`パラメーターの内容の場所が提供されます。ディープリンクの内容にアクセスしたい場合は、このメソッドを上書きしてください。

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    // url object contains your deep link content

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}
```

iOS 8以前のバージョンのiOSデバイス向けのディープリンクの設定が完了しました。

### <a id="deeplinking-setup-new"></a>iOS 9以降のバージョンでのディープリンク

iOS 9以降のデバイスにおけるディープリンクのサポートを設定するには、アプリでAppleのユニバーサルリンク機能を有効化する必要があります。ユニバーサルリンクの詳細と設定方法については、[こちら][universal-links]をご覧ください。

Adjustは、ユニバーサルリンクをサポートするために様々な対応をしています。Adjustでユニバーサルリンクを使うには、Adjust管理画面でユニバーサルリンクのための設定を行ってください。設定方法の詳細については、Adjustの公式[資料][universal-links-guide]をご覧ください。

管理画面にてユニバーサルリンク機能を有効化したら、以下の作業を行ってください。

Apple Developerポータルでアプリの`Associated Domains`を有効化し、アプリのXcodeプロジェクトでもこれを行います。`Assciated Domains`を有効化したら、`Domains`セクションで`applinks:`を使ってプレフィックスを指定し、Adjust管理画面で生成されたユニバーサルリンクを追加します。ユニバーサルリンクの`http(s)`の部分を忘れずに削除するようにしてください。

![][associated-domains-applinks]

設定完了後、Adjustトラッカーのユニバーサルリンクをクリックするとアプリが起動します。アプリが起動すると、`AppDelegate`クラスの`continueUserActivity`メソッドがトリガーし、ユニバーサルリンクURLの内容の場所が提供されます。ディープリンクの内容にアクセスしたい場合は、このメソッドを上書きしてください。

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = [userActivity webpageURL];

        // url object contains your universal link content
    }

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}
```

これで、iOS 9以降のバージョンのiOSデバイス向けのディープリンク設定が完了しました。

Adjustは、ユニバーサルリンクを従来のディープリンクURLに変換するヘルパー機能を提供しています。これは、コード内に、従来のカスタムURLスキームフォーマットにするためにディープリンクの情報を常に必要とするカスタムロジックがある場合にご利用いただけます。ユニバーサルリンクとディープリンクのプレフィックスに使用したいカスタムURLスキーム名と共に、このメソッドをコールすることができます。そうすると、AdjustはカスタムURLスキームディープリンクを生成します。

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = [userActivity webpageURL];

        NSURL *oldStyleDeeplink = [Adjust convertUniversalLink:url scheme:@"adjustExample"];
    }

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}
```

### <a id="deeplinking-deferred"></a>ディファードディープリンク

ディファードディープリンクが開かれる前に通知を受け取るデリゲートコールバックを登録し、Adjust SDKがそれを開くかどうかを決定することができます。また、[アトリビューションコールバック](#attribution-callback)や[イベントとセッションのコールバック](#event-session-callbacks)に使われる`AdjustDelegate`プロトコルをここでも使用できます。

同じ手順に従って、ディファードディープリンクの以下のデリゲートコールバック関数を実装します。

```objc
- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    // deeplink object contains information about deferred deep link content

    // Apply your logic to determine whether the Adjust SDK should try to open the deep link
    return YES;
    // or
    // return NO;
}
```

SDKがAdjustのサーバーからディファードディープリンクを受信した後、ディープリンクを開く前にコールバック関数がコールされます。コールバック関数内で、ディープリンクにアクセスできます。返されるブーリアン値は、SDKがディープリンクを起動するかどうかを決定します。例えば、ディープリンクをすぐには開かないようにした場合、それを保存し後から任意のタイミングで開くように設定できます。

このコールバックが実装されていない場合は、**Adjust SDKはデフォルトで常にディープリンクを開きます**。

### <a id="deeplinking-reattribution"></a>ディープリンクを介したリアトリビューション

Adjustはディープリンクを使ったリエンゲージメントキャンペーンをサポートしています。詳しくは[公式資料][reattribution-with-deeplinks]をご覧ください。

ディープリンクを使用する場合、ユーザーのリアトリビューションを正確に計測するためには、下記のコードを追加してください。

アプリでディープリンクの内容データを受信したら、`appWillOpenUrl`メソッドへのコールを追加してください。このコールによって、Adjust SDKはディープリンクの中に新たなアトリビューション情報が存在するかを調べ、アトリビューションが見つかった場合はAdjustバックエンドに送信します。ディープリンクのついたAdjustトラッカーURLのクリックによってユーザーがリアトリビュートされる場合、アプリで[アトリビューションコールバック](#attribution-callback)がこのユーザーの新しいアトリビューションデータでトリガーされます。

すべてのiOSバージョンでディープリンクリアトリビューションをサポートするための`appWillOpenUrl`へのコールは、以下のようになります。

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    // url object contains your deep link content
    
    [Adjust appWillOpenUrl:url];

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}
```

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL url = [userActivity webpageURL];

        [Adjust appWillOpenUrl:url];
    }

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}
```

## <a id="troubleshooting"></a>よくある質問

### <a id="ts-delayed-init"></a>SDK初期化時の問題

[基本設定手順](#basic-setup)に記載の通り、Appデリゲートの`didFinishLaunching`または`didFinishLaunchingWithOptions`内でAdjust SDKを初期化することを強くおすすめします。Adjust SDKの全機能を使用するには、SDKをできる限り早く初期化することが重要です。

Adjust SDKを初期化しないと、アプリでのトラッキングにあらゆる影響が及ぼされます。**トラッキングを正しく行うために、Adjust　SDKは*必ず*初期化してください。**

`SDKの初期化前では以下の機能は実行されません`。

* [イベントトラッキング](#event-tracking)
* [ディープリンクを介したリアトリビューション](#deeplinking-reattribution)
* [トラッキングの無効化](#disable-tracking)
* [オフラインモード](#offline-mode)

　

SDKを初期化する前にこれらのアクションを計測するためには、アプリ内で`custom actions queueing mechanism`を構築する必要があります。つまり、SDKで利用したいすべてのアクションをキューイングメカニズムに入れ、SDKの初期化が完了したら動作するようにしてください。

オフラインモードの状態とトラッキングの有効/無効状態は変わらず、ディープリンクリアトリビューションは発生しません。また、計測されたあらゆるイベントは`失われます`。

その他にSDKの初期化の影響を受ける可能性があるのは、セッション計測です。Adjust SDKは、初期化が完了するまでアプリ滞在時間に関する情報の収集を開始できません。これが管理画面のDAUデータに影響を与え、正しく計測が行われない可能性があります。

例として、次のシナリオを考えてみましょう。スプラッシュ画面や最初に表示される画面ではない、別の特定のビューまたはビューコントローラーが読み込まれた時にAdjust SDKが初期化されるように実装した場合、実際にユーザーがアプリをインストールして初回起動しても、ホーム画面でSDKが初期化されないためインストールを計測できません。さらに、ユーザーがアプリを気に入らず、ホーム画面が表示された直後にアンインストールした場合も、SDKが初期化されていないため、すべての情報はAdjust SDKに計測されることはなく、レポート画面にも表示されません。

#### イベントトラッキング

計測対象のイベントに関しては、SDKの初期化完了後に内部的なキューイングメカニズムを使ってこれらを待機させて計測します。SDKの初期化前にイベントを計測すると、イベントが`除外されたり` 、`恒久的に失われる`ため、SDKの[`初期化が完了`]し、トラッキングが[`有効化された`](#is-enabled)後にイベントを計測するように実装してください。

#### オフラインモードとトラッキングの有効化/無効化

オフラインモードは、SDKの初期化の間で維持される機能ではないため、デフォルトで`false`に設定されています。SDKの初期化前にオフラインモードを有効化しようとする場合、SDKを初期化する際も`false`のままになります。

トラッキングの有効化/無効化は、SDKの初期化を行う中で維持される機能です。SDKの初期化前にこの値をトグルし設定を変更ようとする場合、それは無視されます。初期化が完了すると、SDKは設定変更前と同じ状態（有効または無効）になります。

#### ディープリンクを介したリアトリビューション

[上記](#deeplinking-reattribution)の通りディープリンクリアトリビューションを使用する場合、使用しているディープリンクメカニズム（従来のディープリンクまたはユニバーサルリンク）によりますが、以下のコールをした後に`NSURL`オブジェクトが得られます。

```objc
[Adjust appWillOpenUrl:url]
```

SDKの初期化前にこのコールを行う場合、ディープリンクURLからのアトリビューション情報は恒久的に失われます。Adjust SDKで正しくリアトリビュートするには、SDKの初期化が完了したらこの`NSURL`オブジェクトのデータをキューし、`appWillOpenUrl`メソッドが呼ばれるようにしてください。

#### セッショントラッキング

セッショントラッキングはAdjust SDKが自動で行うものであり、アプリ開発者はこれをコントロールできません。適切にセッショントラッキングを行うには、このREADMEで推奨されている通りAdjust SDKを初期化することが不可欠です。初期化を行わないと、セッショントラッキングや管理画面に表示されるDAUの数値に予測不能な影響が出る可能性があります。

例：
* ユーザーがアプリを起動したもののSDKが初期化される前にアプリを削除した場合、インストールとセッションは計測されず、レポート画面にも表示されません。
* ユーザーがアプリをダウンロードして午前0時前に初回起動し、Adjust SDKが午前0時を過ぎた後に初期化された場合、初期化されるまで待機していたすべてのインストールとセッションのデータは間違った日付（午前0時過ぎ）でレポートされます。
* ユーザーがアプリを数日利用せず、午前0時前にアプリを起動し、SDKが午前0時過ぎに初期化された場合、DAUはアプリの起動日の翌日付でレポートされます。

これらの現象を避けるため、アプリデリゲートの`didFinishLaunching`または`didFinishLaunchingWithOptions`でAdjust SDKを初期化してください。

### <a id="ts-arc"></a>"Adjust requires ARC"というエラーが表示される

`Adjust requires ARC`というエラーが表示され、ビルドに失敗した場合、プロジェクトが[ARC][arc]を使用していない可能性があります。その場合、Adjustは[プロジェクトを移行][transition]してARCを使用することを推奨します。ARCを使用しない場合は、ターゲットのBuild Phaseにて、Adjustのすべてのソースファイルに対してARCを有効化する必要があります。

`Compile Sources`グループを表示し、すべてのAdjustファイルを選択し`Compiler Flags`を`-fobjc-arc`に変更します（一括で変更するには、すべて選択し`Return`キーを押します）。

### <a id="ts-categories"></a>"[UIDevice adjTrackingEnabled]: unrecognized selector sent to instance"というエラーが表示される

このエラーは、Adjust SDKフレームワークをアプリに追加する際に発生する可能性があります。Adjust SDKはソースファイル内の`カテゴリー`を含んでおり、そのため、このSDK実装アプローチを選んだ場合、Xcodeのプロジェクト設定で`-ObjC`フラグを`Other Linker Flags`に追加する必要があります。このフラグを追加することでこのエラーを解決できます。

### <a id="ts-session-failed"></a>"Session failed (Ignoring too frequent session.)"というエラーが表示される

このエラーはインストールのテストの際に起こりえます。アンインストール後に再インストールするだけでは新規インストールが発生しません。SDKがローカルで統計したセッションデータを失ったとサーバーは判断してエラーメッセージを無視し、その端末に関する有効なデータのみが与えられます。

この仕様はテスト中には厄介かもしれませんが、サンドボックスと本番（Production）の挙動をできる限り近づけるために必要です。

デバイスのセッションデータはAdjustのサーバーでリセットできます。ログのエラーメッセージを確認してください。

```
Session failed (Ignoring too frequent session.Last session: YYYY-MM-DDTHH:mm:ss, this session: YYYY-MM-DDTHH:mm:ss, interval: XXs, min interval: 20m) (app_token: {yourAppToken}, adid: {adidValue})
```

<a id="forget-device">`{yourAppToken}`と以下の`{adidValue}`または`{idfaValue}`値を使用して、以下のリンクのいずれかを開きます。

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&adid={adidValue}
```

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&idfa={idfaValue}
```

デバイスに関する記録が消去されると、リンクは`Forgot device`のみを返します。もしそのデバイスの記録がすでに消去されていたり、値が不正だった場合は、そのリンクは`Device not found`と返します。

### <a id="ts-install-tracked"></a>ログに"Install tracked"が表示されない

テスト用デバイスでインストールをシミュレーションする場合は、Xcodeからアプリのビルドを再実行するだけでは十分ではありません。Xcodeからアプリを再実行するだけではSDKが計測したアプリデータは消去されず、アプリ内に内部データが保存されたままです。AdjustのSDKはそれらのファイルを確認し、アプリはインスール済み（SDK初期化済み）と認識します。初回起動ではなく再び起動されたものだと判断します。

アプリのインストールをシミュレーションするには、以下を行う必要があります。

* デバイスからアプリをアンインストールする（完全に消去する）
* [上記](#forget-device)で説明している通りに、Adjustバックエンドから計測済みのデバイスIDを消去する
* テスト用デバイスでXcodeからアプリを実行し、"Install tracked"というメッセージログを確認する。

### <a id="ts-iad-sdk-click"></a>"Unattributable SDK click ignored"というメッセージが表示される

`サンドボックス`環境でアプリをテストする際にこのメッセージが表示される可能性があります。これは、Appleが`iAd.framework`バージョン3で導入した変更点に関連しています。この変更により、ユーザーがiAdバナーをクリックするとアプリに移動するようになり、その結果Adjust SDKは、クリックされたURLの内容に関するデータとともに`sdk_click`パッケージをAdjustのバックエンドに送信します。いくつかの理由により、Apple社は、iAdバナーをクリックせずにアプリが起動された場合、ランダムな値を使ってiAdバナーURLのクリックを人工的に生成することに決定しました。AdjustのSDKは、iAdバナーのクリックが本物か人工的に生成されたものかを識別できず、どちらの場合でも`sdk_click`パッケージをAdjustバックエンドに送信します。ログレベルが`verbose`に設定されている場合、この`sdk_click`パッケージは以下のようになります。

```
[Adjust]d: Added package 1 (click)
[Adjust]v: Path:      /sdk_click
[Adjust]v: ClientSdk: ios4.10.1
[Adjust]v: Parameters:
[Adjust]v:      app_token              {YourAppToken}
[Adjust]v:      created_at             2016-04-15T14:25:51.676Z+0200
[Adjust]v:      details                {"Version3.1":{"iad-lineitem-id":"1234567890","iad-org-name":"OrgName","iad-creative-name":"CreativeName","iad-click-date":"2016-04-15T12:25:51Z","iad-campaign-id":"1234567890","iad-attribution":"true","iad-lineitem-name":"LineName","iad-creative-id":"1234567890","iad-campaign-name":"CampaignName","iad-conversion-date":"2016-04-15T12:25:51Z"}}
[Adjust]v:      environment            sandbox
[Adjust]v:      idfa                   XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
[Adjust]v:      idfv                   YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY
[Adjust]v:      needs_response_details 1
[Adjust]v:      source                 iad3
```

もし何らかの理由で`sdk_click`が受理された場合、他のキャンペーンURLをクリックすることでアプリを起動、あるいはオーガニックユーザーとしてアプリを起動したユーザーは、この存在しないiAdソースにアトリビュートされることになります。このため、Adjustサーバーはこれを無視し、以下のメッセージを表示します。

```
[Adjust]v: Response: {"message":"Unattributable SDK click ignored."}
[Adjust]i: Unattributable SDK click ignored.
```

このメッセージはSDK実装に関する問題を示すものではなく、ユーザーが間違ってアトリビューション/リアトリビューションされる可能性のある、この人工的に生成された`sdk_click`をAdjustが無視したことを通知するためのものです。

### <a id="ts-wrong-revenue-amount"></a>Adjust管理画面に表示される収益データが間違っている

Adjust SDKは、実装された通りにイベントを計測します。収益イベントを実装した場合、金額として代入された数値がAdjustバックエンドに送信され、レポート画面に表示されます。Adjust SDKとAdjustのバックエンドが金額の値を操作することはありません。よって、計測された金額が間違っているのは、SDKが原因ではありません。

通常、収益イベントを計測するコードの実装事例は以下の通りです。

```objc
// ...

- (double)someLogicForGettingRevenueAmount {
    // This method somehow handles how user determines
    // what's the revenue value which should be tracked.

    // It is maybe making some calculations to determine it.

    // Or maybe extracting the info from In-App purchase which
    // was successfully finished.

    // Or maybe returns some predefined double value.

    double amount; // double amount = some double value

    return amount;
}

// ...

- (void)someRandomMethodInTheApp {
    double amount = [self someLogicForGettingRevenueAmount];

    ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
    [event setRevenue:amount currency:@"EUR"];
    [Adjust trackEvent:event];
}

```

計測されるべきでない値がレポート画面に表示されている場合は、**金額の値を決定するロジックを確認してください**。


[dashboard]:   http://adjust.com
[adjust.com]:  http://adjust.com

[en-readme]:    ../../README.md
[zh-readme]:    ../chinese/README.md
[ja-readme]:    ../japanese/README.md
[ko-readme]:    ../korean/README.md

[sdk2sdk-mopub]:  ../japanese/sdk-to-sdk/mopub.md

[arc]:         http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[examples]:    http://github.com/adjust/ios_sdk/tree/master/examples
[carthage]:    https://github.com/Carthage/Carthage
[releases]:    https://github.com/adjust/ios_sdk/releases
[cocoapods]:   http://cocoapods.org
[transition]:  http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html

[example-tvos]:       ../../examples/AdjustExample-tvOS
[example-iwatch]:     ../../examples/AdjustExample-iWatch
[example-imessage]:   ../../examples/AdjustExample-iMessage
[example-ios-objc]:   ../../examples/AdjustExample-ObjC
[example-ios-swift]:  ../../examples/AdjustExample-Swift

[AEPriceMatrix]:     https://github.com/adjust/AEPriceMatrix
[event-tracking]:    https://docs.adjust.com/en/event-tracking
[callbacks-guide]:   https://docs.adjust.com/ja/callbacks
[universal-links]:   https://developer.apple.com/library/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html

[special-partners]:     https://docs.adjust.com/en/special-partners
[attribution-data]:     https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[ios-web-views-guide]:  https://github.com/adjust/ios_sdk/blob/master/doc/japanese/web_views.md
[currency-conversion]:  https://docs.adjust.com/ja/event-tracking/#tracking-purchases-in-different-currencies

[universal-links-guide]:      https://docs.adjust.com/ja/universal-links/
[adjust-universal-links]:     https://docs.adjust.com/en/universal-links/#redirecting-to-universal-links-directly
[universal-links-testing]:    https://docs.adjust.com/en/universal-links/#testing-universal-link-implementations
[reattribution-deeplinks]:    https://docs.adjust.com/en/deeplinking/#manually-appending-attribution-data-to-a-deep-link
[ios-purchase-verification]:  https://github.com/adjust/ios_purchase_sdk

[reattribution-with-deeplinks]:   https://docs.adjust.com/en/deeplinking/#manually-appending-attribution-data-to-a-deep-link

[run]:         https://raw.github.com/adjust/sdks/master/Resources/ios/run5.png
[add]:         https://raw.github.com/adjust/sdks/master/Resources/ios/add5.png
[drag]:        https://raw.github.com/adjust/sdks/master/Resources/ios/drag5.png
[delegate]:    https://raw.github.com/adjust/sdks/master/Resources/ios/delegate5.png
[framework]:   https://raw.github.com/adjust/sdks/master/Resources/ios/framework5.png

[adc-ios-team-id]:            https://raw.github.com/adjust/sdks/master/Resources/ios/adc-ios-team-id5.png
[custom-url-scheme]:          https://raw.github.com/adjust/sdks/master/Resources/ios/custom-url-scheme.png
[adc-associated-domains]:     https://raw.github.com/adjust/sdks/master/Resources/ios/adc-associated-domains5.png
[xcode-associated-domains]:   https://raw.github.com/adjust/sdks/master/Resources/ios/xcode-associated-domains5.png
[universal-links-dashboard]:  https://raw.github.com/adjust/sdks/master/Resources/ios/universal-links-dashboard5.png

[associated-domains-applinks]:      https://raw.github.com/adjust/sdks/master/Resources/ios/associated-domains-applinks.png
[universal-links-dashboard-values]: https://raw.github.com/adjust/sdks/master/Resources/ios/universal-links-dashboard-values5.png
[tracking-purchases-and-revenues]: https://help.adjust.com/ja/article/app-events#tracking-purchases-and-revenues

## <a id="license"></a>ライセンス

adjust SDKはMITライセンスを適用しています。

Copyright (c) 2012-2019 Adjust GmbH, http://www.adjust.com

以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル（以下「ソフトウェア」）の複製を取得するすべての人に対し、
ソフトウェアを無制限に扱うことを無償で許可します。これには、ソフトウェアの複製を使用、複写、変更、結合、掲載、頒布、サブライセンス、
および/または販売する権利、およびソフトウェアを提供する相手に同じことを許可する権利も無制限に含まれます。

上記の著作権表示および本許諾表示を、ソフトウェアのすべての複製または重要な部分に記載するものとします。

ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証もなく提供されます。
ここでいう保証とは、商品性、特定の目的への適合性、および権利非侵害についての保証も含みますが、それに限定されるものではありません。 
作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、ソフトウェアに起因または関連し、
あるいはソフトウェアの使用またはその他の扱いによって生じる一切の請求、損害、その他の義務について何らの責任も負わないものとします。
