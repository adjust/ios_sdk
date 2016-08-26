## Criteo プラグイン

以下のいずれかの方法でadjustとCriteoの統合が可能です。

### CocoaPods

[CocoaPods](http://cocoapods.org/)をご利用の場合、Podfileに以下の記述を加えることができます。

```ruby
pod 'Adjust/Criteo'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage)をご利用の場合、Cartfileに以下の記述を加えることができます。

```ruby
github "adjust/ios_sdk" "criteo"
```

### ソースファイル

以下の手順でadjustとCriteoを統合することもできます。

1. `plugin/Criteo`フォルダを[releases page](https://github.com/adjust/ios_sdk/releases)からダウンロードアーカイブに置いてください。

2. プロジェクトの`Adjust`フォルダに`ADJCriteo.h`と`ADJCriteo.m`ファイルをドラッグしてください。

3. `Choose options for adding these files`のダイアログが出たら、`Copy items if needed`にチェックを入れ、`Create groups`を選択してください。

### Criteoイベント
下記の例のように、Criteoの各イベントを統合できます。

#### View Listing

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewListingEventToken}"];

NSArray *productIds = @[@"productId1", @"productId2", @"product3"];

[ADJCriteo injectViewListingIntoEvent:event productIds:productIds customerId:@"customerId1"];

[Adjust trackEvent:event];
```

#### View Product

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewProductEventToken}"];

[ADJCriteo injectViewProductIntoEvent:event productId:@"productId1" customerId:@"customerId1"];

[Adjust trackEvent:event];
```

#### カート

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{cartEventToken}"];

ADJCriteoProduct *product1 = [ADJCriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
ADJCriteoProduct *product2 = [ADJCriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
ADJCriteoProduct *product3 = [ADJCriteoProduct productWithId:@"productId3" price:50 quantity:2];
NSArray *products = @[product1, product2, product3];

[ADJCriteo injectCartIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```

#### トランザクションの確認

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{transactionConfirmedEventToken}"];

ADJCriteoProduct *product1 = [ADJCriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
ADJCriteoProduct *product2 = [ADJCriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
ADJCriteoProduct *product3 = [ADJCriteoProduct productWithId:@"productId3" price:50 quantity:2];
NSArray *products = @[product1, product2, product3];

[ADJCriteo injectTransactionConfirmedIntoEvent:event products:products 
  transactionId:@"transactionId1" customerId:@"customerId1"];

[Adjust trackEvent:event];
```

#### ユーザーのレベル

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{userLevelEventToken}"];

[ADJCriteo injectUserLevelIntoEvent:event uiLevel:1 customerId:@"customerId1"];

[Adjust trackEvent:event];
```

#### ユーザーのステータス

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{userStatusEventToken}"];

[ADJCriteo injectUserStatusIntoEvent:event uiStatus:@"uiStatusValue" customerId:@"customerId1"];

[Adjust trackEvent:event];
```

#### Achievement Unlocked

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{achievementUnlockedEventToken}"];

[ADJCriteo injectAchievementUnlockedIntoEvent:event uiAchievement:@"uiAchievementValue" customerId:@"customerId"];

[Adjust trackEvent:event];
```

#### カスタムイベント

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{customEventEventToken}"];

[ADJCriteo injectCustomEventIntoEvent:event uiData:@"uiDataValue" customerId:@"customerId"];

[Adjust trackEvent:event];
```

#### カスタムイベント 2

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{customEvent2EventToken}"];

[ADJCriteo injectCustomEvent2IntoEvent:event uiData2:@"uiDataValue2" uiData3:3 customerId:@"customerId"];

[Adjust trackEvent:event];
```

#### ハッシュEmail

`injectHashedEmailIntoCriteoEvents`メソッドを使って、各Criteoメソッドにハッシュ化されたEmailアドレスを付与することができます。
ハッシュ化されたEmailアドレスはアプリの一ライフサイクル中にCriteoの各メソッドに送信されますので、アプリが再起動された時に再びセットされる必要があります。
`injectHashedEmailIntoCriteoEvents`を`nil`に設定することで、ハッシュEmailを削除することができます。

```objc
#import "ADJCriteo.h"

[ADJCriteo injectHashedEmailIntoCriteoEvents:@"8455938a1db5c475a87d76edacb6284e"];
```

#### 検索日

`injectViewSearchDatesIntoCriteoEvent`メソッドを使って、各Criteoメソッドにチェックインの日付とチェックアウトの日付を付与することができます。これらの日付はアプリの一ライフサイクル中にCriteoの各メソッドに送信されますので、アプリが再起動された時に再びセットされる必要があります。

`injectViewSearchDatesIntoCriteoEvents`を`nil`に設定することで、これらの検索日を削除することができます。

```objc
#import "ADJCriteo.h"

[ADJCriteo injectViewSearchDatesIntoCriteoEvents:@"2015-01-01" checkOutDate:@"2015-01-07"];
```

#### パートナーID

`injectPartnerIdIntoCriteoEvent`を使って、各CriteoメソッドにパートナーIDを付与することができます。このIDはアプリの一ライフサイクル中にCriteoの各メソッドに送信されますので、アプリが再起動された時に再びセットされる必要があります。

`injectPartnerIdIntoCriteoEvent`を`nil`に設定することで、パートナーIDを削除することができます。

```objc
#import "ADJCriteo.h"

[ADJCriteo injectPartnerIdIntoCriteoEvents:@"{criteoPartnerId}"];
```

#### ディープリンクの送信

プロジェクトナビゲータからApplication Delegateのソースファイルを開いてください。openURLメソッドがあればそこに、なければこれを追加して、以下のadjustへのコールを追加してください。

```objc
#import "ADJCriteo.h"

- (BOOL)  application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    ADJEvent *event = [ADJEvent eventWithEventToken:@"{deeplinkEventToken}"];
    
    [ADJCriteo injectDeeplinkIntoEvent:event url:url];
    
    [Adjust trackEvent:event];

    //...
}
```
