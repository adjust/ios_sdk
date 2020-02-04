## Criteo 플러그인

다음 방법 중 하나를 수행하여 Criteo 이벤트와 adjust를 연동하세요.

### CocoaPods

[CocoaPods](http://cocoapods.org/)를 사용하는 경우, Podfile에 다음 줄을 추가 할 수 있습니다 :

```ruby
pod 'Adjust/Criteo'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage)를 사용하는 경우 Cartfile에 다음 줄을 추가 할 수 있습니다.

```ruby
github "adjust/ios_sdk" "criteo"
```

### 소스

다음 방법 중 하나를 수행하여 Criteo 이벤트와 adjust를 통합하세요.

1. 애드저스트의 [releases page](https://github.com/adjust/ios_sdk/releases)에서 다운로드한 아카이브에서`plugin / Criteo` 폴더를 찾으세.

2.`ADJCriteo.h`를 드래그하세요. 그리고`ADJCriteo.m` 파일을 프로젝트 내의`Adjust` 폴더에 넣습니다.

3. '이 파일을 추가하기위한 옵션 선택'대화 상자에서 확인란을 선택하십시오
'필요한 경우 항목 복사'로 이동하고 '그룹 만들기'라디오 버튼을 선택하십시오.

### Criteo 이벤트
이제 다음 예시와 같이 각기 다른 Criteo 이벤트를 연동할 수 있습니다.

#### 리스팅보기

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewListingEventToken}"];

NSArray *productIds = @[@"productId1", @"productId2", @"product3"];

[ADJCriteo injectViewListingIntoEvent:event productIds:productIds];

[Adjust trackEvent:event];
```

#### View Product

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewProductEventToken}"];

[ADJCriteo injectViewProductIntoEvent:event productId:@"productId1"];

[Adjust trackEvent:event];
```

#### Cart

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{cartEventToken}"];

ADJCriteoProduct *product1 = [ADJCriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
ADJCriteoProduct *product2 = [ADJCriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
ADJCriteoProduct *product3 = [ADJCriteoProduct productWithId:@"productId3" price:50 quantity:2];
NSArray *products = @[product1, product2, product3];

[ADJCriteo injectCartIntoEvent:event products:products];

[Adjust trackEvent:event];
```

#### Transaction confirmation

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{transactionConfirmedEventToken}"];

ADJCriteoProduct *product1 = [ADJCriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
ADJCriteoProduct *product2 = [ADJCriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
ADJCriteoProduct *product3 = [ADJCriteoProduct productWithId:@"productId3" price:50 quantity:2];
NSArray *products = @[product1, product2, product3];

[ADJCriteo injectTransactionConfirmedIntoEvent:event products:products 
  transactionId:@"transactionId1" newCustomer:@"newCustomerId"];

[Adjust trackEvent:event];
```

#### User Level

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{userLevelEventToken}"];

[ADJCriteo injectUserLevelIntoEvent:event uiLevel:1];

[Adjust trackEvent:event];
```

#### User Status

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{userStatusEventToken}"];

[ADJCriteo injectUserStatusIntoEvent:event uiStatus:@"uiStatusValue"];

[Adjust trackEvent:event];
```

### Achievement Unlocked

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{achievementUnlockedEventToken}"];

[ADJCriteo injectAchievementUnlockedIntoEvent:event uiAchievement:@"uiAchievementValue"];

[Adjust trackEvent:event];
```

### 커스텀 이벤트

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{customEventEventToken}"];

[ADJCriteo injectCustomEventIntoEvent:event uiData:@"uiDataValue"];

[Adjust trackEvent:event];
```

### 커스텀 이벤트 2

```objc
#import "ADJCriteo.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"{customEvent2EventToken}"];

[ADJCriteo injectCustomEvent2IntoEvent:event uiData2:@"uiDataValue2" uiData3:3];

[Adjust trackEvent:event];
```

#### Hashed Email

`injectHashedEmailIntoCriteoEvents` 메소드를 사용하여 모든 Criteo 이벤트에 해시 된 이메일을 첨부할 수 있습니다.
해시된 이메일은 앱 라이프사이클에서 모든 Criteo 이벤트와 함께 전송되므로 앱을 다시 시작하면 다시 설정해야합니다.
그러므로 앱이 다시 시작될 경우 다시 설정해야합니다.
`injectHashedEmailIntoCriteoEvents` 메소드를 0으로 설정하여 해시 된 이메일을 제거할 수 있습니다.

```objc
#import "ADJCriteo.h"

[ADJCriteo injectHashedEmailIntoCriteoEvents:@"8455938a1db5c475a87d76edacb6284e"];
```

#### Search dates

`injectViewSearchDatesIntoCriteoEvent` 메소드를 사용하여 모든 Criteo 이벤트에 체크인 및 체크 아웃 날짜를 첨부 할 수 있습니다. 앱 라이프사이클에서 모든 Criteo 이벤트와 함께 날짜가 전송되므로 앱을 다시 시작하면 다시 설정해야합니다.

`injectViewSearchDatesIntoCriteoEvents` 날짜를 0으로 설정하여 검색 날짜를 제거할 수 있습니다.

```objc
#import "ADJCriteo.h"

[ADJCriteo injectViewSearchDatesIntoCriteoEvents:@"2015-01-01" checkOutDate:@"2015-01-07"];
```

#### Partner id

`injectPartnerIdIntoCriteoEvent` 메소드를 사용하여 모든 Criteo 이벤트에 파트너 ID를 첨부 할 수 있습니다. 파트너 ID는 앱 라이프사이클에서 모든 Criteo 이벤트와 함께 전송되므로 앱을 다시 시작하면 다시 설정해야합니다.

`injectPartnerIdIntoCriteoEvent` 값을`nil로 설정하여 검색 날짜를 제거 할 수 있습니다.

```objc
#import "ADJCriteo.h"

[ADJCriteo injectPartnerIdIntoCriteoEvents:@"{criteoPartnerId}"];
```

#### Send deeplink

Project Navigator에서 애플리케이션 delegate의 소스 파일을 실행합니다. openURL 메소드를 찾거나 추가하고 다음 호출을 추가하여 조정하십시오.

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

### 고객 ID

`injectCustomerIdIntoCriteoEvents` 메소드를 사용하여 모든 Criteo 이벤트에 고객 ID를 첨부 할 수 있습니다. 고객 ID는 애플리케이션 수명주기 동안 모든 Criteo 이벤트와 함께 전송되므로 앱을 다시 시작할 때 다시 설정해야합니다.

`injectPartnerIdIntoCriteoEvent` 값을 `nil`으로 설정하여 검색 날짜를 제거 할 수 있습니다.

```objc
#import "ADJCriteo.h"

[ADJCriteo injectCustomerIdIntoCriteoEvents:@"{CriteoCustomerId}"];

```

#### User Segment

`injectUserSegmentIntoCriteoEvents` 메소드를 사용하여 모든 Criteo 이벤트에 사용자 분할을 첨부 할 수 있습니다. 고객 ID는 앱 라이프사이클에서 모든 Criteo 이벤트와 함께 전송되므로 앱을 다시 시작할 때 다시 설정해야합니다.

`injectUserSegmentIntoCriteoEvents` 값을 'null'로 설정하여 사용자 분할을 제거 할 수 있습니다.

```objc
#import "ADJCriteo.h"

[ADJCriteo injectUserSegmentIntoCriteoEvents:@"{CriteoUserSegment}"];
```
