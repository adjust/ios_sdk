## 요약

Adjust™의 iOS SDK에 관한 문서입니다. [adjust.com]에서 Adjust™에 대한 정보를 더 자세히 알아보세요.

앱이 Web view 를 사용하며, 자바스크립트 코드를 통해 Adjust 추적을 사용하려는 경우, [iOS 웹 보기 SDK 가이드][ios-web-views-guide]를 참조하세요.

다른 언어로 읽기: [English][en-readme], [中文][zh-readme], [日本語][ja-readme], [한국어][ko-readme].

## 목차

* [앱 예시](#example-apps)
* [기본 연동](#basic-integration)
   * [프로젝트에 SDK 추가](#sdk-add)
   * [iOS 프레임워크 추가](#sdk-frameworks)
   * [앱에 SDK 연동](#sdk-integrate)
   * [기본 설정](#basic-setup)
      * [iMessage용 설정](#basic-setup-imessage)
   * [Adjust 로](#adjust-logging)
   * [앱 빌드하기](#build-the-app)
* [부가 기능](#additional-feature)
   * [AppTrackingTransparency framework](#att-framework)
      * [App-tracking authorisation wrapper](#ata-wrapper)
      * [현재 승인 상태 확인](#ata-getter)
   * [SKAdNetwork framework](#skadn-framework)
      * [SKAdNetwork 전환값 업데이트](#skadn-update-conversion-value)
      * [전환값 업데이트 콜백](#skadn-cv-updated-callback)
   * [이벤트 추적](#event-tracking)
      * [매출 추적](#revenue-tracking)
      * [매출 중복 제거](#revenue-deduplication)
      * [인앱 결제 검증](#iap-verification)
      * [콜백 파라미터](#callback-parameters)
      * [파트너 파라미터](#partner-parameters)
      * [콜백 ID](#callback-id)
   * [세션 파라미터](#session-parameters)
      * [세션 콜백 파라미터](#session-callback-parameters)
      * [세션 파트너 파라미터](#session-partner-parameters)
      * [지연 시작](#delay-start)
   * [어트리뷰션 콜백](#attribution-callback)
   * [광고 매출 트래킹](#ad-revenue)
   * [구독 트래킹](#subscriptions)
   * [이벤트 및 세션 콜백](#event-session-callbacks)
   * [추적 비활성화](#disable-tracking)
   * [오프라인 모드](#offline-mode)
   * [이벤트 버퍼링](#event-buffering)
   * [GDPR 잊혀질 권리(Right to be Forgotten)](#gdpr-forget-me)
   * [서드파티 공유](#third-party-sharing)
      * [타사 공유 비활성화](#disable-third-party-sharing)
      * [서드 파티 공유 활성화](#enable-third-party-sharing)
   * [동의 측정](#measurement-consent)
   * [SDK 서명](#sdk-signature)
   * [백그라운드 추적](#background-tracking)
   * [기기 ID](#device-ids)
      * [iOS 광고 식별자](#di-idfa)
      * [Adjust 기기 식별자](#af-adid)
   * [사용자 어트리뷰션](#user-attribution)
   * [푸시 토큰](#push-token)
   * [사전 설치 트래커](#pre-installed-trackers)
   * [딥링크](#deeplinking)
      * [표준 딥링크 시나리오](#deeplinking-standard)
      * [iOS 8 이전 버전에서의 딥링크](#deeplinking-setup-old)
      * [iOS 9 이후 버전에서의 딥링크](#deeplinking-setup-new)
      * [지연 딥링크(deferred deeplink) 시나리오](#deeplinking-deferred)
      * [딥링크를 통한 리어트리뷰션( reattribution)](#deeplinking-reattribution)
   * [베타 Data residency](#data-residency)
* [문제 해결](#troubleshooting)
   * [지연 SDK 초기화 관련 문제](#ts-delayed-init)
   * ["Adjust의 ARC 요구" 오류가 발생한 경우](#ts-arc)
   * ["\[UIDevice adjTrackingEnabled\]: 인스턴스에 미식별 선택자 전송" 오류가 발생한 경우](#ts-categories)
   * ["세션 실패(너무 빈번한 세션 거부 )" 오류가 발생한 경우](#ts-session-failed)
   * [로그에 "설치 추적"이 기록되지 않은 경우](#ts-install-tracked)
   * ["부정확한 출처의 SDK 클릭 무시" 메시지가 나타난 경우](#ts-iad-sdk-click)
   * [Adjust 대시보드에서 부정확한 매출 데이터를 발견한 경우](#ts-wrong-revenue-amount)
* [라이선스](#license)

## <a id="example-apps"></a>예시 앱

[`iOS(Objective-C)`][example-ios-objc], [`iOS(Swift)`][example-ios-swift], [`tvOS`][example-tvos], [`iMessage`][example-imessage] 및 [`Apple Watch`][example-iwatch]에 대한 [`예시` 디렉토리][examples]에서 앱 예시를 확인할 수 있습니다. Xcode 프로젝트를 실행하여 Adjust SDK의 연동 과정에 대한 사례를 살펴보세요.

## <a id="basic-integration">기본 연동

iOS 개발용 Xcode를 사용한다는 가정하에 iOS 프로젝트에 Adjust SDK를 연동하는 방법을 설명합니다.

### <a id="sdk-add"></a>프로젝트에 SDK 추가

[CocoaPods][cocoapods]를 사용하는 경우, 다음 내용을 `Podfile`에 추가한 후 [해당 단계](#sdk-integrate)를 완료하세요.

ruby
pod `Adjust`, `~> 4.29.1`
```

또는:

ruby
pod 'Adjust', :git => 'https://github.com/adjust/ios_sdk.git', :tag => 'v4.29.1'
```

---

[Carthage][carthage]를 사용하는 경우, 다음 내용을 `Cartfile`에 추가한 후 [해당 단계](#sdk-frameworks)를 완료하세요.

ruby
github "adjust/ios_sdk"
```

---

Swift Package Manager를 사용한다면 리포지토리 주소를 직접 Xcode에 추가(File > Swift Packages > Add Package Dependency)하고 [이 단계](#sdk-frameworks)로 넘어갈 수 있습니다:

```
https://github.com/adjust/ios_sdk
```

---

프로젝트에 Adjust SDK를 프레임워크로 추가하여 연동할 수도 있습니다. [릴리스 페이지][releases]에서 다음 항목을 확인해 보세요.

* `AdjustSdkStatic.framework.zip`
* `AdjustSdkDynamic.framework.zip`
* `AdjustSdkTv.framework.zip`
* `AdjustSdkIm.framework.zip`

Apple은 iOS 8을 출시한 후, 임베디드 프레임워크로도 잘 알려진 동적 프레임워크(dynamic frameworks)를 도입했습니다. 앱이 iOS 8 이상 버전을 타겟팅하는 경우에는 Adjust SDK 동적 프레임워크를 사용할 수 있습니다. 필요에 따라 정적(static) 또는 동적(dynamic) 프레임워크를 선택하여 프로젝트에 추가하세요.

`tvOS`앱의 경우, `AdjustSdkTv.framework.zip` 자료에서 추출 가능한 tvOS 프레임워크와 함께 Adjust SDK를 활용할 수 있습니다.

`iMessage`앱의 경우, `AdjustSdkIm.framework.zip` 아카이브에서 추출 가능한 IM 프레임워크와 함께 Adjust SDK를 활용할 수 있습니다.

### <a id="sdk-frameworks"></a>iOS 프레임워크 추가

추가 iOS 프레임워크를 앱에 연결할 경우 애드저스트 SDK가 추가 정보를 얻을 수 있습니다. 애드저스트 SDK 기능을 활성화하려는 경우 앱의 SDK 기능 유무에 따라 다음의 프레임워크를 추가하고 이를 선택으로 설정하시기 바랍니다.

- `AdSupport.framework` - SDK가 IDFA 값 및 (iOS 14 이전 버전) LAT 정보에 액세스하려면 이 프레임워크가 필요합니다.
- `iAd.framework` - SDK가 실행 중인 ASA 캠페인에 대한 속성을 자동으로 처리하려면 이 프레임워크가 필요합니다.
- `AdServices.framework` - iOS 14.3 및 이상을 사용하는 기기에서 이 프레임워크는 SDK가 자동으로 ASA 캠페인에 대한 어트리뷰션을 처리하도록 허용합니다. Apple Ads Attribution API를 사용하는 경우 필요합니다.
- `CoreTelephony.framework` - SDK가 현재의 무선 액세스 기술을 결정하려면 이 프레임워크가 필요합니다.
- `StoreKit.framework` - `SKAdNetwork` 프레임워크에 액세스하고 Adjust SDK가 iOS 14 및 이후 버전에서 통신을 자동으로 처리하려면 이 프레임워크가 필요합니다.
- `AppTrackingTranspaintency.framework` - iOS 14 및 이후 버전에서 SDK가 사용자의 추적 동의 다이얼로그를 래핑하고, 추적 여부에 대한 사용자의 동의 값에 대한 액세스를 위해 이 프레임워크가 필요합니다.

### <a id="sdk-integrate"></a>앱에 SDK 연동하기

Pod 리포지토리를 통해 Adjust SDK를 추가했다면, 다음 import 명령어 중 하나를 실행해야 합니다.

```objc
#"Adjust.h"가져오기
```

또는

```objc
#import <Adjust/Adjust.h>
```

---

Adjust SDK를 static/dynamic 프레임워크로 추가했거나 Carthage를 통해 등록했다면, 다음 import 명령어 중 하나를 실행해야 합니다.

```objc
#import <AdjustSdk/Adjust.h>
```

---

tvOS 앱에서 Adjust SDK를 사용하는 경우, 다음 import 명령어 중 하나를 실행해야 합니다.

```objc
#import <AdjustSdkTv/Adjust.h>
```

---

iMessage 앱에서 Adjust SDK를 사용하는 경우, 다음 가져오기 명령어 중 하나를 실행해야 합니다.

```objc
#import <AdjustSdkIm/Adjust.h>
```

다음으로는 기본 세션 추적을 설정하겠습니다.

### <a id="basic-setup"></a>기본 설정

Project Navigator에서 애플리케이션 delegate 의 소스 파일을 실행합니다. `import` 명령어를 파일 상단에 추가한 후, 다음 콜을 앱 delegate 의 `didFinishLaunching` 또는 `didFinishLaunchingWithOptions` 메서드 내 `Adjust`에 추가합니다.

```objc
#"Adjust.h"가져오기
// 또는 #import <Adjust/Adjust.h>
// 또는 #import <AdjustSdk/Adjust.h>
// 또는 #import <AdjustSdkTv/Adjust.h>
// 또는 #import <AdjustSdkIm/Adjust.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                            environment:environment];

[Adjust appDidLaunch:adjustConfig];
```

![][delegate]

**참고**: Adjust SDK 초기화는 `아주 중요한` 단계입니다. 제대로 완료하지 않으면 [문제 해결 섹션](#ts-delayed-init)에서 설명하는 다양한 문제가 발생할 수 있습니다.

`{YourAppToken}`을 사용 중인 앱 토큰으로 교체한 다음, [Dashboard]에서 결과를 확인해 보세요.

테스트 또는 배포 등 어떤 목적으로 앱을 빌드하는에 따라 다음 두 값 중 하나의 `Environment(환경)`으로 설정해야 합니다.

```objc
NSString *environment = ADJEnvironmentSandbox;
NSString *environment = ADJEnvironmentProduction;
```

**중요:** 앱을 테스트해야 하는 경우, 해당 값을 `ADJEnvironmentSandbox`로 설정해야 합니다. 앱을 퍼블리시할 준비가 완료되면 환경 설정을 `ADJEnvironmentProduction`으로 변경하고, 앱 개발 및 테스트를 새로 시작한다면 `ADJEnvironmentSandbox`로 다시 설정하세요.

테스트 기기로 인해 발생하는 테스트 트래픽과 실제 트래픽을 구분하기 위해 다른 환경을 사용하고 있으니, 상황에 알맞은 설정을 적용하시기 바랍니다. 이는 매출을 추적하는 경우에 특히 중요합니다.

### <a id="basic-setup-imessage"></a>iMessage 전용 설정

**소스에서 SDK 추가:** **소스에서** Adjust SDK를 iMessage 앱에 추가하기로 선택한 경우, iMessage 프로젝트 설정에 프리 프로세서 매크로 **ADJUST_IM=1**이 설정되어 있는지 확인하세요.

**Framework(프레임워크)로 SDK 추가:** iMessage 앱에 `AdjustSdkIm.framework`를 추가했다면, `Build Phases` 프로젝트 설정에 `New Copy Files Phase`를 추가하고 `AdjustSdkIm.framework`가 `Frameworks` 폴더로 복사되도록 선택했는지 확인하세요.

**세션 추적:** iMessage 에서 세션 추적을 원활하게 실행하고 싶다면, 추가적인 연동 과정을 거쳐야 합니다. 표준 iOS 앱의 경우 Adjust SDK에서 iOS 시스템 알림을 자동으로 수신하기 때문에 Adjust가 앱의 세션 정보를 파악할 수 있으나, iMessage 앱의 경우에는 그렇지 않습니다. 따라서 explicit call(명시적인 콜)을 iMessage 앱 뷰 컨트롤러 내부의 `trackSubsessionStart`와 `trackSubsessionEnd` method(매서드)에 추가해야 Adjust SDK에서 앱이foreground에 있는지 여부를 추적할 수 있습니다.

`didBecomeActiveWithConversation:` 메서드 내부의 `trackSubsessionStart`에 콜을 추가합니다.

```objc
-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // 확장이 비활성에서 활성 상태로 이동하면 호출됨.
    // 확장이 UI를 표시하려고 할 때 발생함.
    // 확장을 구성하고 이전에 저장된 상태를 복구하려면 이 메서드를 사용하시기 바랍니다.

    [Adjust trackSubsessionStart];
}
```

`willResignActiveWithConversation:` 메서드 내부의 `trackSubsessionEnd`에 콜을 추가합니다.

```objc
-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // 확장판이 활성에서 비활성 상태로 이동하면 호출됨.
    // 유저가 확장을 거부 또는 다른 대화로 변경하거나,
    // 메시지를 종료할 때 발생함.
    
    // 공유된 리소스를 내보내고, 유저 데이터를 저장하고, 타이머를 무효화하고,
    // 확장이 이후 종료된 경우 현재 상태로 복구하기 위해 충분한 상태 정보를 저장하기 위해
    // 이 메서드를 사용하시기 바랍니다.

    [Adjust trackSubsessionEnd];
}
```

이렇게 설정을 완료하면, Adjust SDK를 통해 iMessage 앱 내부에서 세션을 추적할 수 있습니다.

**참고:** 빌드한 iOS 앱 및 iMessage 확장자가 서로 다른 메모리 공간에서 운영되며, 상이한 번들 식별자를 사용하고 있는지 확인해야 합니다. 두 공간에서 같은 앱 토큰으로 Adjust SDK를 초기화하면 두 개의 독립 인스턴스가 생성되며, 두 인스턴스가 각자 서로의 존재를 모르는 채로 추적하여 대시보드 데이터에서 적합하지 않은 데이터 혼합이 발생할 수 있습니다. 따라서 iMessage 앱용 Adjust 대시보드에서 별도의 앱을 생하여 다른 앱 토큰으로 SDK를 초기화하는 것이 좋습니다.

### <a id="adjust-logging"></a>Adjust 로그

다음 파라미터 중 하나를 통해 `ADJConfig` 인스턴스에서 `setLogLevel:`을 호출하여 테스트하는 동안 조회할 로그의 양을 늘리거나 줄일 수 있습니다.

```objc
[adjustConfig setLogLevel:ADJLogLevelVerbose];  // 모든 로그 활성화
[adjustConfig setLogLevel:ADJLogLevelDebug];    // 추가 로그 활성화
[adjustConfig setLogLevel:ADJLogLevelInfo];     // 기본값
[adjustConfig setLogLevel:ADJLogLevelWarn];     / /정보 로그 비활성화
[adjustConfig setLogLevel:ADJLogLevelError];    // 경고도 비활성화
[adjustConfig setLogLevel:ADJLogLevelAssert];   // 에러도 비활성화
[adjustConfig setLogLevel:ADJLogLevelSuppress]; // 모든 로그 비활성화
```

개발 중인 앱에 Adjust SDK가 기록하는 로그를 표시하지 않으려면, `ADJLogLevelSuppress`를 선택한 후 로그 수준 모드를 조절할 수 있는 생성자에서 `ADJConfig` 객체를 초기화해야 합니다.

```objc
#"Adjust.h"가져오기
// 또는 #import <Adjust/Adjust.h>
// 또는 #import <AdjustSdk/Adjust.h>
// 또는 #import <AdjustSdkTv/Adjust.h>
// 또는 #import <AdjustSdkIm/Adjust.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                            environment:environment
                                   allowSuppressLogLevel:YES];

[Adjust appDidLaunch:adjustConfig];
```

### <a id="build-the-app"></a>앱 빌드하기

앱을 빌드하고 실행합니다. 빌드를 성공적으로 완료했다면, 콘솔에서 SDK 로그를 꼼꼼하게 살펴보시기 바랍니다. 앱을 처음으로 출시한 경우, `설치 추적` 로그 정보를 반드시 확인하세요.

![][run]

## <a id="additional-feature">추가 기능

Adjust SDK를 프로젝트에 연동하면 다음 기능을 활용할 수 있습니다.

### <a id="att-framework"></a>AppTrackingTransparency 프레임워크

전송된 각 패키지에 대해 Adjust 백엔드는 사용자 또는 기기를 추적하는 데 사용할 수 있는 앱 관련 데이터에 대한 액세스 동의를 다음 네 가지 상태 중 하나로 수신합니다.

- Authorized
- Denied
- Not Determined
- Restricted

기기가 사용자 기기 추적에 사용되는 앱 관련 데이터에 대한 액세스를 승인하는 인증 요청을 수신한 후에는 Authorized 또는 Denied 상태가 반환됩니다.

기기가 사용자 또는 기기를 추적하는 데 사용되는 앱 관련 데이터에 대한 액세스 인증 요청을 수신하기 전에는 Not Determined 상태가 반환됩니다.

앱 추적 데이터 인증 권한이 제한되면 Restricted 상태가 반환됩니다.

사용자에게 표시되는 대화 상자 팝업을 맞춤 설정하지 않으려는 경우, SDK에는 사용자가 대화 상자 팝업에 응답하면 업데이트된 상태를 수신하는 자체 메커니즘이 있습니다. 새로운 동의 상태를 백엔드에 편리하고 효율적으로 전달하기 위해 Adjust SDK는 다음 챕터 `앱 트래킹 인증 래퍼`에 설명된 앱 트래킹 인 메서드와 관련한 래퍼를 제공합니다.

### <a id="ata-wrapper"></a>App-tracking 인증 래퍼(wrapper)

Adjust SDK를 사용하면 앱 관련 데이터에 액세스하는 데 대한 사용자 인증을 요청할 수 있습니다. Adjust SDK에는 [requestTrackingAuthorizationWithCompletionHandler:](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorizationwith?language=objc) 상에 빌드된 래퍼가 있습니다. 여기서 콜백 메서드를 정의하여 사용자의 선택에 대한 정보를 얻을 수도 있습니다. 또한 이 래퍼를 사용하면 사용자가 팝업 대화 상자에 응답하는 즉시 콜백 메서드를 사용하여 다시 전달됩니다. 또한 SDK는 사용자의 선택 정보를 백엔드에 알립니다. `NSUInteger` 값은 다음과 같은 의미로 콜백 메서드를 통해 전달됩니다.

- 0: `ATTrackingManagerAuthorizationStatusNotDetermined`
- 1: `ATTrackingManagerAuthorizationStatusRestricted`
- 2: `ATTrackingManagerAuthorizationStatusDenied`
- 3: `ATTrackingManagerAuthorizationStatusAuthorized`

이 래퍼를 사용하려면 다음과 같이 호출하면 됩니다:

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

### <a id="ata-getter"></a>현재 승인 상태 확인

현재 앱의 트래킹 승인 상태를 확인하려면 `[Adjust appTrackingAuthorizationStatus]`를 호출할 수 있으며, 이때 다음의 값이 반환될 수 있습니다.

* `0`: 유저가 아직 승인 요청을 받지 않음
* `1`: 유저 기기가 제한됨
* `2`: 유저가 IDFA 액세스를 거부함
* `3`: 유저가 IDFA 액세스를 승인함
* `-1`: 상태 확인이 불가함


### <a id="skadn-framework"></a>SKAdNetwork 프레임워크

Adjust iOS SDK v4.23.0 이상을 설치했으며 iOS 14에서 앱을 실행하는 경우, SKAdNetwork와의 통신이 기본적으로 활성화되며 비활성화하도록 설정할 수 있습니다. 활성화하면 SDK가 실행될때 SKAdNetwork 어트리뷰션에 대해 Adjust가 자동으로 등록합니다. 이벤트가 Adjust 대시보드에서 전환 값을 수신하도록 설정된 경우, Adjust 백엔드가 전환 값 데이터를 SDK로 전송합니다. 그런 다음 SDK가 전환 값을 설정합니다. Adjust가 SKAdNetwork 콜백 데이터를 수신한 후에는 해당 정보가 대시보드에 표시됩니다.

Adjust SDK가 SKAdNetwork와 자동으로 통신하지 않도록 하려면 구성 객체에 대해 다음 메서드를 호출하여 해당 메서드를 사용하지 않도록 설정할 수 있습니다:

```objc
[adjustConfig deactivateSKAdNetworkHandling];
```

### <a id="skadn-update-conversion-value"></a>SKAdNetwork 전환값 업데이트

iOS SDK v4.26.0의 경우 Adjust 래퍼(wrapper) 메서드인 `updateConversionValue:`를 사용하여 유저에 대한 SkAdNetwork 전환값을 업데이트할 수 있습니다.

```objc
[Adjust updateConversionValue:6];
```

### <a id="skadn-cv-updated-callback"></a>전환값 업데이트 콜백

콜백을 등록하여 Adjust SDK가 유저의 전환값을 업데이트할 때마다 알림을 받을 수 있습니다. `AdjustDelegate` 프로토콜을 실행해야 하며, 추가로 `adjustConversionValueUpdated:` 메서드를 실행할 수 있습니다.

```objc
- (void)adjustConversionValueUpdated:(NSNumber *)conversionValue {
    NSLog(@"Conversion value updated callback called!");
    NSLog(@"Conversion value: %@", conversionValue);
}
```

### <a id="event-tracking"></a>이벤트 트래킹

Adjust를 사용하여 이벤트를 트래킹할 수 있습니다. 특정 버튼에 대한 모든 탭을 트래킹하려는 경우를 가정해 보겠습니다. Adjust [대시보드]에서 이벤트 토큰을 생성합니다. 이는 `abc123`와 같은 형태입니다. 버튼의 `buttonDown`메서드에서 탭을 트래킹하기 위해 다음을 추가합니다:

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[Adjust trackEvent:event];
```

버튼을 탭하면 이제 로그에 `Event tracked`가 표시됩니다.

이벤트 인스턴스를 사용하여 이벤트를 트래킹하기 전에 해당 이벤트를 구성할 수 있습니다.

### <a id="revenue-tracking"></a>매출 트래킹

사용자가 광고를 탭하거나 인앱 구매를 통해 매출을 창출 할 수있는 경우 이벤트를 통해 해당 매출을 트래킹할 수 있습니다. 광고를 한번 누르는 행위에 €0.01의 매출 금액이 발생한다고 가정해 보겠습니다. 그 경우 매출 이벤트를 다음과 같이 트래킹할 수 있습니다.:

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event setRevenue:0.01 currency:@"EUR"];

[Adjust trackEvent:event];
```

이것은 물론 콜백 파라미터와 함께 쓸 수 있습니다.

사용자가 통화 토큰을 설정하면 Adjust는 사용자가 대시보드에 설정한 통화 세팅에 따라 전송되는 매출을 reporting 매출로 자동 전환합니다. 지원하는 통화 리스트는 여기에서 확인하세요. [currency conversion here.][currency-conversion]

[이벤트 트래킹 가이드](https://help.adjust.com/ko/article/app-events#tracking-purchases-and-revenues)에서 매출과 이벤트 트래킹에 대한 자세한 내용을 확인하실 수 있습니다.

### <a id="revenue-deduplication"></a>매출 중복 제거

중복되는 매출을 트래킹하는 것을 방지하기 위해 전환 ID를 선택적으로 추가할 수 있습니다. 마지막 10개의 트랜잭션 ID가 보관되며, 중복되는 전환 ID가 있는 매출 이벤트는 건너뛰게 됩니다. 이러한 방식은 인앱 결제 트래킹에 활용할 수 있습니다. 예시는 다음과 같습니다.

인앱 구매를 트래킹하려면, 상태가 `SKPaymentTransactionStatePurchased`로 변경된 이후에만 `paymentQueue:updatedTransactions`에서 `finishTransaction` 다음에 `trackEvent`를 호출합니다. 이렇게 하면 실제로 발생하지 않은 매출을 추적하는 것을 방지할 수 있습니다.

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self finishTransaction:transaction];

                ADJEvent *event = [ADJEvent eventWithEventToken:...];
                [event setRevenue:... currency:...];
                [event setTransactionId:transaction.transactionIdentifier]; // avoid duplicates
                [Adjust trackEvent:event];

                break;
            // more cases
        }
    }
}
```

### <a id="iap-verification"></a>인앱 구매 검증

Adjust의 서버 측 결제 수신 정보 검증 툴인 Purchase Verification 제품을 사용하여 인앱 결제를 검증하고 싶다면, Adjust의 iOS 구매 SDK를 확인하고 [여기][ios-purchase-verification]에서 자세한 내용을 확인하시기 바랍니다.

### <a id="callback-parameters"></a>콜백 파라미터

[대시보드]에서 이벤트를 위한 콜백 URL을 등록할 수 있습니다. Adjust는 이벤트가 트래킹 될 때마다 해당 URL에 GET 요청을 보냅니다. 이벤트를 트래킹하기 전에 이벤트에 `addCallbackParameter`를 호출하여 해당 이벤트에 콜백 파라미터를 추가 할 수 있습니다. 이후 Adjust는 해당 파라미터를 사용자의 콜백 URL에 추가합니다.

예를 들어, 사용자가 http://www.mydomain.com/callback URL을 등록했으며 다음과 같은 이벤트를 트래킹한다고 가정해 보겠습니다.

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event addCallbackParameter:@"key" value:@"value"];
[event addCallbackParameter:@"foo" value:@"bar"];

[Adjust trackEvent:event];
```

이 경우, Adjust가 이벤트를 추적하여 다음으로 요청을 전송합니다.

    http://www.mydomain.com/callback?key=value&foo=bar

Adjust는 {idfa} 등 파라미터 값으로 사용될 수 있는 다양한 placeholder를 지원합니다. 콜백을 통해 이 placeholder는 현재 기기의 특정 ID로 대체될 수 있습니다. Adjust는 커스텀 파라미터를 보관하지 않으며 콜백에 추가하기만 하기 때문에 콜백 없이는 커스텀 파라미터가 저장되거나 사용자에게 전송되지 않습니다.

Adjust [callbacks guide][callbacks-guide]에서 사용 가능한 값의 전체 리스트를 비롯하여 URL 콜백을 사용하는 방법을 자세히 알아보실 수 있습니다.

### <a id="partner-parameters"></a>파트너 파라미터

Adjust 대시보드에서 활성화된 네트워크 파트너로 전송될 파라미터를 추가할 수도 있습니다.

이는 상기 콜백 파라미터와 유사한 방식으로 이루어지지만, `ADJEvent` 인스턴스에 `addPartnerParameter` 메서드를 호출하여 추가할 수 있습니다.

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event addPartnerParameter:@"key" value:@"value"];
[event addPartnerParameter:@"foo" value:@"bar"];

[Adjust trackEvent:event];
```

[특별 파트너 가이드][special-partners]에서 특별 파트너와 연동 방법에 대한 자세한 내용을 알아보실 수 있습니다.

### <a id="callback-id"></a>콜백 ID

트래킹하고자 하는 개별 이벤트에 맞춤 문자열 ID를 추가할 수도 있습니다. 이 ID는 이후에 이벤트 성공 및/또는 이벤트 실패 콜백에서 보고되며, 이를 통해 성공적으로 트래킹 된 이벤트와 그렇지 않은 이벤트를 확인할 수 있습니다. `ADJEvent` 인스턴스에 `setCallbackId` 메서드를 호출하여 이 ID를 설정할 수 있습니다.


```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event setCallbackId:@"Your-Custom-Id"];

[Adjust trackEvent:event];
```

### <a id="session-parameters"></a>세션 파라미터

일부 파라미터는 저장되어 Adjust SDK의 모든 이벤트 및 세션에 전송됩니다. 이러한 파라미터를 한 번 추가하면 로컬로 저장되기 때문에 매번 추가할 필요가 없습니다. 동일한 파라미터를 다시 추가해도 아무 일도 일어나지 않습니다.

초기 설치 이벤트와 함께 세션 파라미터를 보내려면 `[Adjust appDidLaunch:]`를 통해 Adjust SDK를 시작하기 전에 반드시 호출해야 합니다. 설치 시에 파라미터를 전송해야 하지만 필요한 값을 실행 이후에만 확보할 수 있는 경우, 이러한 동작이 가능하게 하려면 Adjust SDK의 첫 실행을 지연시키면 됩니다.

### <a id="session-callback-parameters"></a>세션 콜백 파라미터

Adjust SDK의 모든 이벤트 또는 세션에서 전송될 [events](#callback-parameters)를 위해 등록된 동일한 콜백 파라미터를 저장할 수 있습니다.

세션 콜백 파라미터는 이벤트 콜백 파라미터와 유사한 인터페이스를 가집니다. 이벤트에 키와 값을 추가하는 대신에, `Adjust`에 `addSessionCallbackParameter:value:` 메서드 호출을 통해 추가됩니다.

```objc
[Adjust addSessionCallbackParameter:@"foo" value:@"bar"];
```

세션 콜백 파라미터는 콜백 파라미터와 병합되며 이벤트에 추가됩니다. 이벤트에 추가된 콜백 파라미터는 세션 콜백 파라미터보다 높은 우선순위를 가집니다. 세션에서 추가된 것과 동일한 키로 콜백 파라미터를 이벤트에 추가하면 이벤트에 추가된 콜백 파라미터의 값이 우선시됩니다.

원하는 키를`removeSessionCallbackParameter` 메소드에 전달하여 특정 세션 콜백 파라미터를 제거 할 수 있습니다.

```objc
[Adjust removeSessionCallbackParameter:@"foo"];
```

세션 콜백 파라미터에서 모든 키와 값을 삭제하려면 `resetSessionCallbackParameters` 메서드를 사용하여 재설정 할 수 있습니다.

```objc
[Adjust resetSessionCallbackParameters];
```

### <a id="session-partner-parameters"></a>세션 파트너 파라미터

Adjust SDK의 이벤트 또는 세션에 [session callback parameters](#session-callback-parameters)가 전송되는 것처럼 세션 파트너 파라미터도 있습니다.

이러한 파라미터는 사용자의 Adjust 대시보드에서 활성화된 네트워크 파트너 연동에 전송됩니다.

세션 파트너 파라미터는 이벤트 파트너 파라미터와 유사한 인터페이스를 가집니다. 키와 값을 이벤트에 추가하는 대신, Adjust 메서드의 `addSessionPartnerParameter:value:`: 로의 호출을 통해 추가합니다.

```objc
[Adjust addSessionPartnerParameter:@"foo" value:@"bar"];
```

세션 파트너 파라미터는 이벤트에 추가된 파트너 파라미터와 병합됩니다. 이벤트에 추가된 파트너 파라미터는 세션 파트너 파라미터보다 높은 우선순위를 가집니다. 세션에서 추가된 것과 동일한 키로 파트너 파라미터를 이벤트에 추가하면 이벤트에 추가된 파트너 파라미터의 값이 우선시됩니다.

원하는 키를`removeSessionPartnerParameter` 메서드에 전달하여 특정 세션 파트너 파라미터를 삭제할 수 있습니다.

```objc
[Adjust removeSessionPartnerParameter:@"foo"];
```

세션 파트너 파라미터에서 모든 키와 값을 제거하려면`resetSessionPartnerParameters` 메소드를 사용하여 재설정할 수 있습니다.

```objc
[Adjust resetSessionPartnerParameters];
```

### <a id="delay-start"></a>시작 지연

Adjust SDK의 시작을 지연시키면 앱이 내부 유저 ID와 같은 세션 파라미터를 획득할 시간이 확보되므로, 세션 파라미터를 설치 시에 전송할 수 있게 됩니다.

`ADJConfig` 인스턴스에서 `setDelayStart` 메서드로 초기 지연 시간을 초 단위로 설정하시기 바랍니다.

```objc
[adjustConfig setDelayStart:5.5];
```

이렇게 설정하면 Adjust SDK가 초기 설치 세션과 5.5초 이내로 생성된 이벤트를 전송하지 않습니다. 이 시간이 만료되거나 그동안 `[Adjust sendFirstPackages]`를 호출하는 경우, 모든 세션 파라미터가 지연된 설치 세션 및 이벤트에 추가되며 Adjust SDK가 평소대로 재개됩니다.

**Adjust SDK의 최대 시작 지연 시간은 10초입니다.**

### <a id="attribution-callback"></a>어트리뷰션 콜백

델리게이트 콜백을 등록하여 트래커 어트리뷰션의 변경 사항에 대한 알림을 받을 수 있습니다. 어트리뷰션에는 다양한 소스가 관련되어 있기 때문에 이 정보는 동기적으로 제공될 수 없습니다. 아래의 단계를 수행하여 앱 델리게이트에서 추가적인 델리게이트 프로토콜을 실행합니다.

Adjust의 [관련 어트리뷰션 데이터 정책][attribution-data]을 반드시 고려하시기 바랍니다.

1. `AppDelegate.h`를 열고 임포트와 `AdjustDelegate` 선언을 추가합니다.

    ```objc
    @interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>
    ```

2. `AppDelegate.m`을 열고 다음의 델리게이트 콜백 기능을 앱 델리게이트 실행에 추가합니다.

    ```objc
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    }
    ```

3. `ADJConfig` 인스턴스와 델리게이트를 설정합니다.

    ```objc
    [adjustConfig setDelegate:self];
    ```

델리게이트 콜백이 `ADJConfig` 인스턴스를 사용하여 구성되므로, `[Adjust appDidLaunch:adjustConfig]`를 호출하기 전에 `setDelegate`를 호출해야 합니다.

델리게이트 기능은 SDK가 최종 어트리뷰션 데이터를 수신한 이후에 호출됩니다. 델리게이트 함수 내에서 `attribution` 파라미터에 액세스할 수 있습니다. 그 속성에 대한 요약 정보는 다음과 같습니다.

- `NSString trackerToken` 현재 어트리뷰션의 트래커 토큰.
- `NSString trackerName` 현재 어트리뷰션의 트래커 이름.
- `NSString network` 현재 어트리뷰션의 네트워크 그룹화 수준.
- `NSString campaign`현재 어트리뷰션의 캠페인 그룹화 수준.
- `NSString adgroup`현재 어트리뷰션의 광고 그룹 그룹화 수준.
- `NSString creative` 현재 어트리뷰션의 크리에이티브 그룹화 수준.
- `NSString clickLabel` 현재 어트리뷰션의 클릭 레이블.
- `NSString adid` 어트리뷰션이 제공한 고유 기기 식별자.
- `NSString costType` 비용 유형 문자열.
- `NSNumber costAmount` 비용 금액.
- `NSString costCurrency` 비용 통화 문자열.

값을 사용할 수 없는 경우, 기본값인 `nil`이 나타납니다.

참고: 비용 데이터인 `costType`과 `costAmount`, `costCurrency`는 `setNeedsCost:` 메서드를 호출하여 `ADJConfig`에서 설정된 경우에만 이용 가능합니다. 설정이 되지 않았거나, 또는 설정이 되었으나 어트리뷰션의 일부가 아닌 경우에는 필드의 값이 `nil`로 나타납니다. 본 기능은 SDK v4.24.0 이상 버전에서만 이용 가능합니다.

### <a id="ad-revenue"></a>광고 매출 트래킹

**참고**: 이 광고 매출 트래킹 API는 네이티브 SDK v4.29.0 이상에서만 이용가능합니다.

다음 메서드를 호출하여 Adjust SDK로 광고 매출 정보를 트래킹할 수 있습니다.

```objc
// 적절한 광고 매출 소스와 함께 ADJAdRevenue 인스턴스 초기화
ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:source];
// 매출과 통화값 전송
[adRevenue setRevenue:1.6 currency:@"USD"];
// 선택 파라미터 전송
[adRevenue setAdImpressionsCount:adImpressionsCount];
[adRevenue setAdRevenueUnit:adRevenueUnit];
[adRevenue setAdRevenuePlacement:adRevenuePlacement];
[adRevenue setAdRevenueNetwork:adRevenueNetwork];
// 필요한 경우 콜백 및/또는 파트너 파라미터 추가
[adRevenue addCallbackParameter:key value:value];
[adRevenue addPartnerParameter:key value:value];

// track ad revenue
[Adjust trackAdRevenue:source payload:payload];
```

애드저스트는 현재 다음의 `source` 파라미터 값을 지원합니다.

- `ADJAdRevenueSourceAppLovinMAX` - AppLovin MAX 플랫폼.
- `ADJAdRevenueSourceMopub` - MoPub 플랫폼.
- `ADJAdRevenueSourceAdMob` - AdMob 플랫폼.
- `ADJAdRevenueSourceIronSource` - IronSource 플랫폼.

**참고**: 지원되는 소스와의 연동에 대한 자세한 내용을 설명하는 추가 문서는 이 README 외에 별도로 제공됩니다. 또한, 이 기능을 사용하기 위해서는 Adjust 대시보드에서 앱에 대한 추가적인 설정이 필요합니다. 따라서, 이 기능을 사용하기 전에 모든 설정이 올바르게 이루어지도록 하기 위해 Adjust 지원팀에 먼저 연락하시기 바랍니다.

### <a id="subscriptions"></a>구독 트래킹

**참고**: 이 기능은 SDK 4.22.0 버전 이상에서만 사용할 수 있습니다. Adjust는 최소 4.22.1 버전을 사용하기를 권고합니다. 

**중요**: 다음의 단계는 SDK 내에서의 구독 트래킹만 설정합니다. 설정을 완료하려면 특정 앱 정보가 반드시 Adjust의 내부 인터페이스에 추가되어야 합니다. 이는 Adjust의 직원이 수행해야 합니다. support@adjust.com이나 담당 테크니컬 어카운트 매니저에게 연락하시기 바랍니다. 

Adjust SDK에서 App Store 구독을 트래킹하고 유효성을 검증할 수 있습니다. 구독이 성공적으로 구매되면, 다음의 콜을 Adjust SDK에 호출합니다.

```objc
ADJSubscription *subscription = [[ADJSubscription alloc] initWithPrice:price
                                                              currency:currency
                                                         transactionId:transactionId
                                                            andReceipt:receipt];
[subscription setTransactionDate:transactionDate];
[subscription setSalesRegion:salesRegion];

[Adjust trackSubscription:subscription];
```

이는 상태가 `SKPaymentTransactionStatePurchased`나 `SKPaymentTransactionStateRestored`로 변경된 경우에만 사용하시기 바랍니다. 이후 `paymentQueue:updatedTransactions`에서 `finishTransaction`에 호출합니다.

구독 트래킹 파라미터:

- [가격](https://developer.apple.com/documentation/storekit/skproduct/1506094-price?language=objc)
- 통화([현지 가격](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc) 객체의 [통화 코드](https://developer.apple.com/documentation/foundation/nslocale/1642836-currencycode?language=objc)를 전달해야 함)
- [거래 ID](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc)
- [영수증](https://developer.apple.com/documentation/foundation/nsbundle/1407276-appstorereceipturl)
- [거래 일자](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411273-transactiondate?language=objc)
- 판매 지역([현지 가격](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc) 객체의 [국가 코드](https://developer.apple.com/documentation/foundation/nslocale/1643060-countrycode?language=objc)를 전달해야 함)

이벤트 추적과 마찬가지로 콜백 및 파트너 파라미터를 구독 객체에 연결할 수 있습니다.

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

### <a id="event-session-callbacks"></a>이벤트와 세션 콜백

델리게이트 콜백을 등록하여 트래킹이 성공 또는 실패한 이벤트 및/또는 세션에 대한 알림을 받을 수 있습니다. [어트리뷰션 콜백](#attribution-callback)에 사용되는 동일한 선택 프로토콜인 `AdjustDelegate`가 사용됩니다.

동일한 단계를 수행한 뒤 성공적으로 트래킹된 이벤트에 다음의 델리게이트 콜백 함수를 사용하시기 바랍니다.

```objc
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
}
```

트래킹이 실패한 이벤트에는 다음의 델리게이트 콜백 함수를 사용합니다.

```objc
- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
}
```

성공적으로 트래킹된 세션의 경우:

```objc
- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
}
```

추적에 실패한 세션의 경우:

```objc
- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
}
```

SDK가 패키지를 서버로 전송하려고 시도한 후에 델리게이트 콜백 함수가 호출됩니다. 델리게이트 콜백 내에서 델리게이트 콜백에 대한 응답 데이터 객체에 액세스할 수 있습니다. 세션 응답 데이터 속성에 대한 요약 정보는 다음과 같습니다.

- `NSString message` 서버로부터의 메시지 또는 SDK에 의해 로깅된 오류.
- `NSString timeStamp` 서버로부터의 타임스탬프.
-`NSString adid` Adjust에서 제공하는 고유 기기 식별자.
- `NSDictionary jsonResponse` 서버로부터의 응답을 포함하는 JSON 객체.

두 이벤트 응답 데이터 개체는 다음을 포함합니다.

- `NSString eventToken` 트래킹된 패키지가 이벤트인 경우 해당 이벤트 토큰.
- `NSString callbackId` 이벤트 객체에 설정된 맞춤 정의 콜백 ID

값을 사용할 수 없는 경우, 기본값인 `nil`이 나타납니다.

두 이벤트 및 세션 실패 개체는 다음을 포함합니다.

- `BOOL willRetry`는 이후 패키지 재전송 시도가 있음을 알립니다.

### <a id="disable-tracking"></a>트래킹 비활성화

`NO` 파라미터와 함께 `setEnabled`를 호출하여, Adjust SDK가 현재 기기의 모든 활동을 트래킹하는 것을 비활성화 할 수 있습니다. **이 설정은 세션 간에 유지됩니다**.

```objc
[Adjust setEnabled:NO];
```

<a id="is-enabled"> `isEnabled` 함수를 호출하여 Adjust SDK가 현재 활성화 상태인지 확인할 수 있습니다. 활성화된 파라미터를 `YES`로 설정하여 `setEnabled` 를 호출하고, 언제든지 Adjust SDK를 활성화할 수 있습니다.

### <a id="offline-mode"></a>오프라인 모드

Adjust 서버에 대한 전송을 연기하고 트래킹된 데이터가 이후에 전송되도록 유지함으로써 Adjust SDK를 오프라인 모드로 설정할 수 있습니다. 오프라인 모드에서는 모든 정보가 파일에 저장되기 때문에 너무 많은 이벤트를 발생시키지 않도록 주의해야 합니다.

오프라인 모드를 활성화하려면 `setOfflineMode`를 호출하고 파라미터를 `YES`로 설정합니다.

```objc
[Adjust setOfflineMode:YES];
```

반대로 `setOfflineMode`를 `NO`와 호출하여 오프라인 모드를 취소할 수 있습니다. Adjust SDK가 다시 온라인 모드가 되면 저장된 모든 정보가 정확한 시간 정보와 함께 Adjust 서버로 전송됩니다.

트래킹 비활성화와는 다르게, 이 설정은 **세션 간에 유지되지 않습니다.** 즉, 앱이 오프라인 모드에서 종료되었더라도 Adjust SDK는 항상 온라인 모드로 시작됩니다.

### <a id="event-buffering"></a>이벤트 버퍼링

앱이 이벤트 트래킹을 많이 사용하는 경우, 일부 HTTP 요청을 연기하여 HTTP 요청을 1분에 한 번씩 일괄로 보내고자 할 수 있습니다. `ADJConfig` 인스턴스를 통해 이벤트 버퍼링을 활성화할 수 있습니다.

```objc
[adjustConfig setEventBufferingEnabled:YES];
```

아무것도 설정되지 않은 경우 이벤트 버퍼링의 **기본값은 비활성화**입니다.

### <a id="gdpr-forget-me"></a>GDPR 잊혀질 권리

EU의 개인정보보호법(GDPR) 제 17조에 따라, 사용자는 잊혀질 권리(Right to be Forgotten)를 행사했음을 Adjust에 알릴 수 있습니다. 다음 메서드를 호출하면 Adjust SDK가 잊혀질 권리에 대한 사용자의 선택과 관련된 정보를 Adjust 백엔드에 보냅니다.

```objc
[Adjust gdprForgetMe];
```

이 정보를 수신한 후 Adjust는 해당 사용자의 데이터를 삭제하며 Adjust SDK는 해당 사용자에 대한 추적을 중지합니다. 이 기기로부터의 요청은 향후 Adjust에 전송되지 않습니다.

## <a id="third-party-sharing"></a>특정 유저에 대한 서드파티 공유

유저가 서드파티 파트너와의 데이터 공유를 비활성화, 활성화 및 재활성화할 때 Adjust에 이를 고지할 수 있습니다.

### <a id="disable-third-party-sharing"></a>특정 유저에 대한 서드파티 공유 비활성화

다음 메서드를 호출하여 Adjust SDK가 데이터 공유 비활성화에 대한 사용자의 선택과 관련된 정보를 Adjust 백엔드에 보냅니다:

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:@NO];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

이 정보를 수신하면 Adjust는 특정 사용자의 데이터를 파트너와 공유하는 것을 차단하고 Adjust SDK는 계속 정상적으로 작동합니다.

### <a id="enable-third-party-sharing">특정 유저에 대한 서드파티 공유 활성화 및 비활성화</a>

다음 메서드를 호출하여 Adjust SDK가 데이터 공유에 대한 유저의 선택과 변경 내용을 Adjust 백엔드에 보내도록 하시기 바랍니다.

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:@YES];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

Adjust는 정보 수신 후 해당 유저에 대한 파트너와의 데이터 공유 상태를 변경합니다. Adjust SDK는 계속해서 정상적으로 작동합니다.

Adjust SDK가 Adjust 백엔드로 상세한 옵션을 전송하도록 하려면 다음의 메서드를 호출합니다.

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:nil];
[adjustThirdPartySharing addGranularOption:@"PartnerA" key:@"foo" value:@"bar"];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

### <a id="measurement-consent"></a>특정 유저에 대한 동의 측정

Adjust 대시보드에서 데이터 프라이버시 설정을 활성화 또는 비활성화하려면(동의 만료 기간 및 유저 데이터 보유 기간 포함) 다음의 메서드를 도입해야 합니다.

다음의 메서드를 호출하여 Adjust SDK가 데이터 프라이버시 설정을 Adjust 백엔드로 보내도록 하시기 바랍니다.

```objc
[Adjust trackMeasurementConsent:YES];
```

Adjust는 정보 수신 후 해당 유저에 대한 파트너와의 데이터 공유 상태를 변경합니다. Adjust SDK는 계속해서 정상적으로 작동합니다.

### <a id="sdk-signature"></a> SDK 서명

Adjust SDK 서명은 클라이언트별로 활성화됩니다. 이 기능을 사용하기 위해서는 담당 매니저에게 문의하십시오.

SDK 서명이 이미 계정에서 활성화되어 있으며 Adjust 대시보드의 App Secret에 액세스할 수 있는 경우, 아래 방법을 사용하여 SDK 서명을 앱에 연동하세요.

`AdjustConfig`인스턴스에서`setAppSecret`을 호출하여 앱 시크릿을 설정합니다.

```objc
[adjustConfig setAppSecret:secretId info1:info1 info2:info2 info3:info3 info4:info4];
```

### <a id="background-tracking"></a>백그라운드 트래킹

Adjust SDK는 기본값에 따라 앱이 백그라운드에서 작동하는 동안 HTTP 요청 전송을 일시 중지하도록 설정되어 있습니다. 이 설정은 `AdjustConfig` 인스턴스에서 변경할 수 있습니다.

```objc
[adjustConfig setSendInBackground:YES];
```

아무 것도 설정되지 않으면 백그라운드 전송이 **기본적으로 비활성화됩니다**.

### <a id="device-ids"></a>기기 ID

Adjust SDK를 사용하면 일부 기기 식별자를 얻을 수 있습니다.

### <a id="di-idfa"></a>iOS 광고 ID

특정 서비스(예: Google Analytics)는 중복 보고를 방지하기 위해 기기 및 클라이언트 ID 통합을 요청합니다.

기기 ID IDFA를 얻으려면 `idfa` 함수를 호출합니다.

```objc
NSString *idfa = [Adjust idfa];
```

### <a id="af-adid"></a>Adjust 기기 ID

사용자의 앱이 설치된 각 기기에 대해 Adjust 백앤드는 고유한 **Adjust 기기 식별자**(**adid**)를 생성합니다. 이 식별자를 얻기 위해`Adjust` 인스턴스에서 다음 메서드를 호출 할 수 있습니다.

```objc
NSString *adid = [Adjust adid];
```

**참고** : **adid** 에 대한 정보는 Adjust 백앤드에서 앱 설치를 트래킹한 후에 사용할 수 있습니다. 그 다음부터는 Adjust SDK가 기기 **adid** 정보를 보유하게 되며, 이 메서드를 사용하여 해당 정보에 액세스할 수 있습니다. 따라서 SDK가 초기화되고 앱 설치가 추적되기 전까지는 **adid**에 액세스할 수 **없습니다**.

### <a id="user-attribution"></a>유저 어트리뷰션

어트리뷰션 콜백은 [어트리뷰션 콜백 섹션](#attribution-callback)에 설명된 대로 실행되며, 변경될 때마다 새 어트리뷰션에 대한 정보를 제공합니다. 유저의 현재 어트리뷰션에 대한 정보에 액세스하려면 `Adjust` 인스턴스에서 다음의 메서드를 호출합니다.

```objc
ADJAttribution *attribution = [Adjust attribution];
```

**참고**: 현재 어트리뷰션에 대한 정보는 Adjust 백엔드가 앱의 설치를 추적하고 어트리뷰션 콜백이 처음으로 실행된 다음에만 사용할 수 있습니다. 그 다음부터는 Adjust SDK가 사용자의 어트리뷰션 상태에 대한 정보를 보유하게 되며, 이 메서드를 사용하여 해당 정보에 액세스할 수 있습니다. 따라서 SDK가 초기화되고 어트리뷰션 콜백이 실행되기 전까지는 사용자의 어트리뷰션 값에 액세스할 수 **없습니다**.

### <a id="push-token"></a>푸시 토큰

푸시 토큰은 오디언스 빌더(Audience Builder) 및 클라이언트 콜백에 사용되며 삭제 및 재설치 트래킹 기능에 필요합니다.

Adjust에 푸시 알림 토큰을 전송하려면 앱 델리게이트(app delegate)의 `didRegisterForRemoteNotificationsWithDeviceToken` 에 Adjust으로의 호출을 추가하세요.

```objc
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Adjust setDeviceToken:deviceToken];
}
```

### <a id="pre-installed-trackers"></a>사전 설치 트래커

Adjust SDK를 사용하여 본인의 앱을 발견하고 기기에 사전 설치한 사용자를 식별하려면 다음 단계를 따르세요.

1. [대시보드]에서 새 트래커를 생성합니다.
2. 앱 델리게이트를 열고 `ADJConfig`의 기본값 트래커를 설정합니다.

  ```objc
  ADJConfig*adjustConfig = [ADJConfig configWithAppToken:yourAppToken environment:environment];
  [adjustConfig setDefaultTracker:@"{TrackerToken}"];
  [Adjust appDidLaunch:adjustConfig];
  ```

  `{TrackerToken}`을 2단계에서 만든 트래커 토큰으로 교체합니다. 대시보드에 트래커가 표시됩니다.
  URL (including `http://app.adjust.com/`). 소스 코드에서 전체 URL이 아닌
  6글자의 토큰만 지정해야 합니다.

3. 앱을 빌드하고 실행합니다. XCode에서 다음과 같은 라인이 나타나야 합니다.

    ```
    Default tracker: 'abc123'
    ```

### <a id="deeplinking"></a>딥링크

Adjust 트래커 URL을 사용하며 URL로부터 앱으로 딥링킹하는 옵션을 설정한 경우, 딥링크 및 그 콘텐츠에 대한 정보를 얻을 수 있습니다. 사용자가 앱을 이미 설치한 경우(표준 딥링크 시나리오) 또는 기기에 앲이 없는 경우(지연 딥링크 시나리오)에 URL 조회가 발생할 수 있습니다. 이 두 시나리오는 Adjust SDK에서 지원되며 두 경우 모두 트래커 URL에 도달 한 후 앱이 시작된 후 딥 링크 URL이 제공됩니다. 앱에서이 기능을 사용하려면 올바르게 설정해야합니다.

### <a id="deeplinking-standard"></a>표준 딥링크 시나리오

만일 사용자가 이미 앱을 설치하였고 딥링크 정보가 담긴 트래커 URL에 도달하였다면 애플리케이션이 열리고 딥링크의 내용이 앱으로 전송되어 파싱 및 다음 작업을 결정할 수 있습니다. iOS 9이 나오면서 Apple은 앱에서 딥링크를 처리하는 방식을 변경했습니다. 앱에 사용하려는 시나리오 (또는 다양한 기기를 지원하기 위해 둘 다 사용하려는 경우)에 따라 다음 시나리오 중 하나 또는 둘 다를 처리하도록 앱을 설정해야합니다.

### <a id="deeplinking-setup-old"></a>iOS 8 이하 기기에서의 딥링크

iOS 8 및 이전 기기에서 딥링크는 커스텀 URL 스킴 설정을 사용하여 수행됩니다. 앱을 여는 데 사용할 커스텀 URL 스킴 이름을 선택해야합니다. 이 스킴 이름은`deep_link` 파라미터의 일부로 Adjust 트래커 URL에서도 사용됩니다. 앱에서 이를 설정하려면`Info.plist`를 엽니다. 파일에 새로운 `URL 유형`행을 추가합니다. 거기에 `URL 식별자`로 앱의 번들 ID를 작성하고 `URL 스킴`아래에서 앱이 처리 할 스킴 이름을 추가합니다. 아래 예제에서는 앱이`adjustExample` 스킴 이름을 처리하도록 선택했습니다.

![][custom-url-scheme]

이것이 설정되면 선택한 스킴 이름이 포함된`deep_link` 파라미터로 Adjust 트래커 URL를 클릭하면 앱이 열립니다. 앱이 열리면 `AppDelegate`클래스의`openURL` 메소드가 실행되고 트래커 URL의`deep_link` 파라미터의 내용이 전달됩니다. 딥링크의 컨텐츠에 액세스하려면이 이 매서드를 오버라이드합니다.

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    // url 객체에 딥링크 콘텐츠가 있습니다

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

이 셋업을 사용하여 iOS 8 및 이전 버전의 iOS 기기에 대한 딥링크 처리를 성공적으로 설정했습니다.

### <a id="deeplinking-setup-new"></a>iOS 9 이상 기기에서의 딥링크

iOS 9 이후 기기에 대한 딥링크 지원을 설정하려면 앱이 Apple 유니버셜 링크를 처리할 수 있도록 설정해야 합니다. 유니버셜 링크 및 해당 설정에 대해 자세히 알아 보려면 [here] [universal-links]를 확인하십시오.

Adjust는 개별적으로 유니버셜 링크와 관련하여 많은 것들을 처리하고 있습니다. 그러나 Adjust로 유니버셜 링크를 지원하려면 Adjust 대시 보드에서 유니버셜 링크에 대해 작은 설정을 수행해야합니다. 이에 대한 자세한 내용은 공식 [here] [universal-links-guide]를 참조하십시오.

대시보드에서 유니버셜 링크 기능을 활성화한 후에는 앱에서도 이를 수행해야합니다.

Apple Developer Portal에서 앱에 대해 `Associated Domains`를 활성화한 후에는 앱의 Xcode 프로젝트에서 동일한 작업을 수행해야합니다. `Associated Domains`를 활성화 한 후`Domains` 섹션의 Adjust 대시보드에서`applinks :`를 접두사로 사용하여 생성된 유니버설 링크를 추가하고 유니버설 링크의 `http(s)` 부분을 반드시 삭제하도록 합니다.

![][associated-domains-applinks]

이 설정이 완료되면 Adjust 트래커 유니버셜 링크를 클릭할 시 앱이 열립니다. 앱이 열리면 `AppDelegate`클래스의`continueUserActivity` 메서드가 트리거되고 유니버셜 링크 URL의 컨텐츠가 있는 곳이 전달됩니다. 딥링크의 컨텐츠에 액세스하려면이 이 매서드를 오버라이드합니다.

``` objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = [userActivity webpageURL];

        // url 객체는 사용자의 유니버셜 링크 콘텐츠가 포함되어 있습니다
    }

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

이 셋업을 사용하여 iOS9 및 이후 버전의 iOS 기기에 대한 딥링크 처리를 성공적으로 설정했습니다.

딥링크 정보가 항상 기존 스타일의 커스텀 URL 스킴 형식으로 나올 것으로 예상되는 코드에 커스텀 로직이 있는 경우 유니버셜 링크를 이전 스타일의 딥링크 URL로 변환 할 수있는 도우미 기능을 제공합니다. 사용자는 유니버셜 링크와 딥링크가 접두어로 표시된 사용자 정의 URL 스킴 이름으로 이 메서드를 호출할 수 있으며 Adjust는 사용자 정의 URL 스킴 딥링크를 생성합니다:

``` objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = [userActivity webpageURL];

        NSURL *oldStyleDeeplink = [Adjust convertUniversalLink:url scheme:@"adjustExample"];
    }

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

### <a id="deeplinking-deferred"></a>디퍼드 딥링크 시나리오

디퍼드 딥링크가 열리기 전에 알림을 받을 델리게이트 콜백을 지정하고, Adjust SDK가 이를 열지 결정할 수 있습니다. [어트리뷰션 콜백](#attribution-callback)에 사용되는 동일한 선택 프로토콜인 `AdjustDelegate`가 사용됩니다.

동일한 단계를 수행하고, 디퍼드 딥링크에 대해 다음의 델리게이트 콜백 함수를 사용합니다.

```objc
- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    // 딥링크 객체는 디퍼드 딥링크 콘텐츠에 대한 정보를 포함합니다.

    // Adjust SDK가 딥링크를 열려고 시도해야 하는지 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

콜백 함수는 SDK가 Adjust 서버에서 디퍼드 딥링크를 수신하고 열기 전에 호출됩니다. 콜백 함수 내에서 딥링크에 액세스할 수 있습니다. 반환된 불 논리 값은 SDK가 딥링크를 실행해야 할지 결정합니다. 예를 들어, SDK가 바로 딥링크를 열지 않고 저장 후 나중에 직접 열도록 할 수 있습니다.

이 콜백이 구현되지 않으면 **Adjust SDK는 항상 기본적으로 해당 딥링크를 열려고 시도합니다.**.

### <a id="deeplinking-reattribution"></a>딥링크를 통한 리어트리뷰션

Adjust를 사용하면 립링크를 사용하여 리인게이지먼트(재유입) 캠페인 트래킹을 실행할 수 있습니다. 이를 수행하는 방법에 대한 자세한 정보는 Adjust의 [official docs][reattribution-with-deeplinks]에서 찾아볼 수 있습니다.

이 기능을 사용하는 경우, 사용자에 대한 리어트리뷰션이 적절히 이루어지려면 앱에서 Adjust SDK에 대한 추가적인 호출을 수행해야 합니다.

앱의 딥링크 콘텐츠 정보를 수신했으면 the `appWillOpenUrl` 매서드로 호출을 추가합니다. 이 호출을 수행함으로써 Adjust SDK는 딥링크 내부에서 새 어트리뷰션 정보를 찾으며, 정보가 있는 경우에는 Adjust 백앤드에 전송됩니다. 딥링크 콘텐츠를 포함하는 Adjust 트래커 URL에 대한 클릭으로 인해 사용자에 대한 리어트리뷰션이 이루어져야 하는 경우, 앱에서 해당 사용자에 대한 새 어트리뷰션 정보와 함께 [어트리뷰션 콜백](#attribution-callback)이 실행되는 것을 볼 수 있습니다.

`appWillOpenUrl`에 대한 호출은 모든 iOS 버전에서 딥링크 리어트리뷰션을 지원하기 위해 다음과 같이 수행되어야합니다.

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    // url 객체에 딥링크 콘텐츠가 있습니다
    
    [Adjust appWillOpenUrl:url];

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

``` objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL url = [userActivity webpageURL];

        [Adjust appWillOpenUrl:url];
    }

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

### <a id="data-residency"></a>[베타] 데이터 레지던시

데이터 레지던시 기능을 활성화하려면, 다음의 상수 중 1개와 함께 `ADJConfig` 인스턴스의 `setUrlStrategy:` 메서드를 호출하시기 바랍니다.

```objc
[adjustConfig setUrlStrategy:ADJDataResidencyEU]; // EU 데이터 레지던시 지역
[adjustConfig setUrlStrategy:ADJDataResidencyTR]; // 터키 데이터 레지던시 지역
```

**참고:** 이 기능은 현재 베타 테스트 단계입니다. 이 기능에 액세스하고 싶다면 담당 어카운트 매니저나 support@adjust.com으로 연락주시기 바랍니다. Adjust의 지원팀이 앱에 해당 기능을 활성화한 것이 아니라 자체적으로 해당 기능을 활성화한 경우 SDK 트래픽이 중단되게 됩니다.

## <a id="troubleshooting"></a>문제 해결

### <a id="ts-delayed-init"></a>지연된 SDK 초기화 문제

[기본 연동 단계](#basic-setup)에 명시된 바와 같이, ADjust는 앱 델리게이트의 `didFinishLaunching` 또는 `didFinishLaunchingWithOptions` 메서드 내에서 Adjust SDK를 초기화하는 것을 강력히 권고합니다. Adjust SDK를 최대한 빨리 초기화하여야 SDK의 모든 기능을 사용할 수 있습니다.

Adjust SDK를 즉시 초기화하지 않은 경우 앱 트래킹에 여러 영향을 미칠 수 있습니다. **앱에서 트래킹을 수행하려면 Adjust SDK가 *반드시* 초기화되어야 합니다.**

SDK를 초기화 하기 전에 다음의 활동을 수행하려고 하면,

* [이벤트 추적](#event-tracking)
* [딥링크를 통한 리어트리뷰션( reattribution)](#deeplinking-reattribution)
* [추적 비활성화](#disable-tracking)
* [오프라인 모드](#offline-mode)

`수행되지 않을 것입니다`.

실제 초기화 이전에 Adjust SDK에서 이러한 활동을 트래킹하려고 하면, 앱 안에 `custom actions queueing mechanism`를 빌드해야 합니다. Adjust SDK가 수행하기를 원하는 모든 활동을 대기하고, SDK가 초기화되었을 때 해당 활동을 수행해야 합니다.

오프라인 모드 상태와 트래킹 활성화/비활성화 상태는 변경되지 않을 것이며, 딥링크 리어트리뷰션은 발생하지 않을 것이며, 트래킹된 이벤트는 모두 `포함되지 않을 것입니다`.

지연된 SDK 초기화에 영향을 받는 또 다른 요소는 세션 트래킹입니다. Adjust SDK는 초기화 되기 전에 세션 길이 정보를 수집할 수 없습니다. 이는 대시보드의 DAU 수치에 영향을 주며, 트래킹이 제대로 되지 않을 것입니다.

예시 시나리오: 특정 뷰나 뷰 컨트롤러가 로딩되었을 때 Adjust SDK를 초기화하려는 상황. 해당 시점은 스플래시 화면이나 앱의 첫 화면이 아니므로, 유저가 홈스크린부터 해당 화면에 도달해야 하는 상황입니다. 유저가 앱을 다운로드하고 실행하면 홈스크린이 나타날 것입니다. 유저가 설치를 완료했으므로 트래킹이 되어야 하는 이벤트입니다. 그러나 유저가 Adjust SDK를 초기화하기로 결정한 해당 화면에 도달해야 하기 때문에, Adjust SDK는 이 시점에서는 설치에 대해서 알 수 없습니다. 또한, 유저가 홈스크린을 본 뒤 바로 삭제하게 되면 이 모든 정보는 Adjust SDK에 트래킹되지 않으며, 대시보드에도 나타나지 않게 될 것입니다.

#### 이벤트 트래킹

내부 대기 메커니즘을 통해 트래킹하고자 하는 이벤트를 대기시킨 뒤 SDK가 초기화된 이후 트래킹하시기 바랍니다. SDK 초기화 전에 이벤트를 트래킹하면 이벤트가 `포함되지 않고` `영구적으로 소실`될 수 있습니다. SDK가 `초기화`되고 [`활성화`](#is-enabled)된 이후에 이벤트를 트래킹하시기 바랍니다.

#### 오프라인 모드 및 트래킹 활성화/비활성화

오프라인 모드는 SDK 초기화 간에 유지되는 기능이 아니므로, 기본값 설정은 `false`로 되어 있습니다. SDK 초기화 전 오프라인 모드를 활성화하면, 이후 SDK를 초기화할 때 `false`로 설정될 것입니다.

트래킹의 활성화/비활성화는 SDK 초기화 간에 유지됩니다. SDK 초기화 전 이 값의 토글을 사용하고자 하면 토글 시도가 거부될 것입니다. 초기화가 완료되면 SDK는 토글 시도 전의 상태(활성화 또는 비활성화)일 것입니다.

#### 딥링크를 통한 리어트리뷰션

[위에서](#deeplinking-reattribution) 명시된 바와 같이, 딥링크 리어트리뷰션의 처리 시에는 사용하는 딥링크 메커니즘(이전 방식 또는 유니버설 링크)에 따라, `NSURL` 객체를 얻게 되고 이후 다음을 호출해야 합니다.

```objc
[Adjust appWillOpenUrl:url]
```

SDK 초기화 전에 해당 호출을 하면, 해당 딥링크 URL로부터의 어트리뷰션 정보는 영구적으로 소실됩니다. Adjust SDK가 성공적으로 유저를 리어트리뷰션하길 원하면 `NSURL` 객체 정보를 대기시킨 뒤, SDK가 초기화 된 이후 `appWillOpenUrl` 메서드를 실행합니다.

#### 세션 트래킹

세션 트래킹은 Adjust SDK가 자동으로 수행하는 기능으로, 앱 개발자가 액세스할 수 없습니다. 적절한 세션 트래킹을 위해 Adjust SDK는 이 README에서 설명된 방식으로 초기화되어야 합니다. 초기화가 제대로 되지 않으면 적절한 세션 트래킹과 대시보드의 DAU 수치에 예기치 못한 영향이 발생할 수 있습니다.

그 예는 다음과 같습니다.
* SDK 초기화 전에 유저가 앱을 실행했으나 삭제한 경우, 해당 설치와 세션은 절대 트래킹되지 않으며 대시보드에서도 보고되지 않습니다.
* 유저가 자정 전에 앱을 다운로드하고 실행하고 Adjust SDK가 자정 이후에 초기화된 경우, 대기 중이었던 설치와 세션 데이터의 보고일이 정확하지 않을 것입니다.
* 유저가 특정일에는 앱을 사용하지 않았으나 자정 이후에 앱을 실행하고, SDK가 자정 이후 초기화된 경우에는 DAU가 앱 실행일과는 다른 날에 보고될 것입니다.

이러한 이유로 본 문서에 있는 설명에 따라 앱 델리게이트의 `didFinishLaunching` 또는 `didFinishLaunchingWithOptions` 메서드에서 Adjust SDK를 초기화하시기 바랍니다.

### <a id="ts-arc"></a>"Adjust requires ARC" 오류가 발생한 경우

빌드가 `Adjust requires ARC` 오류로 실패한 경우는 프로젝트가 [ARC][arc]를 사용하지 않기 때문입니다. 이 경우 [프로젝트 트랜지션을 ][전환]하여 ARC를 사용하도록 하시기 바랍니다. ARC를 사용하고 싶지 않다면, 타겟의 빌드 단계에서 Adjust의 모든 소스 파일에 대해 ARC를 활성화해야 합니다.

`Compile Sources` 그룹 확장, Adjust 파을 모두 선택하고 `Compiler Flags`를 `-fobjc-arc`로 변경 (모두 선택 후 `Return` 키를 눌러 일괄 변경 적용).

### <a id="ts-categories"></a> "[UIDevice adjTrackingEnabled]: 인스턴스에 미식별 선택자 전송" 오류가 발생한 경우

해당 에러는 Adjust SDK 프레임워크를 앱에 추가 시 발생합니다. Adjust SDK는 소스 파일 중에 `categories`를 포함하기 때문에, 사용자가 SDK 연동 접근법을 선택한 경우 Xcode 프로젝트 설정에서 `Other Linker Flags`에 `-ObjC` 플래그를 추가해야 합니다. 플래그를 추가하면 오류가 해결될 것입니다.

### <a id="ts-session-failed"></a>"세션 실패(너무 빈번한 세션 거부) 오류가 발생한 경우

본 오류는 일반적으로 설치 테스트 시 발생합니다. 앱의 설치 삭제와 재설치만으로는 새 설치가 트리거되지 않습니다. 서버는 SDK가 로컬에 집계된 세션 데이터를 소실했다고 판단하여, 해당 기기에 대해 서버에서 이용 가능한 정보를 기반으로 오류 메시지를 무시할 것입니다.

이러한 행동은 테스트 시 번거로울 수 있으나, 샌드박스의 행동이 프로덕션 행동과 최대한 일치하도록 하기 위해 반드시 필요합니다.

Adjust의 서버에서 해당 기기의 세션 데이터를 재설정할 수 있습니다. 로그에서 오류 메시지를 확인하시기 바랍니다.

```
세션 실패(너무 빈번한 세션 거부) 최종 세션: YYYY-MM-DDTHH:mm:ss,현재 세션: YYYY-MM-DDTHH:mm:ss, interval: XXs, min interval: 20m) (app_token: {yourAppToken}, adid: {adidValue})
```

<a id="forget-device">With the `{yourAppToken}` and  either `{adidValue}` or `{idfaValue}` values filled in below, open one of the following links:

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&adid={adidValue}
```

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&idfa={idfaValue}
```

기기 정보가 삭제되면 링크는 `Forgot device` 값을 반환합니다. 기기 정보가 이미 삭제되었거나 값이 부정확한 경우, 링크는 `Device not found` 값을 반환합니다.

### <a id="ts-install-tracked"></a> 로그에서 "Install tracked"를 확인할 수 없는 경우

테스트 기기에서 앱의 설치 시나리오를 시뮬레이션하고 싶은 경우, Xcode로부터 테스트 기기에 앱을 다시 실행하는 것만으로는 충분하지 않습니다. Xcode에서 앱을 다시 실행한다고 해서 앱 데이터가 삭제되는 것은 아니며, Adjust SDK가 앱 내부에서 보관하는 모두 내부 파일은 그대로 존재할 것입니다. 따라서, 앱이 재실행되면 Adjust SDK는 해당 파일을 보고 앱이 이미 설치(그리고 SDK가 이미 론칭되었다고 간주)되었으며, 최초 실행이 아니라 다시 실행된 것으로 간주합니다.

앱 설치 시나리오를 확인하려면 다음을 수행해야 합니다.

* 기기에서 앱 삭제(완전한 삭제)
* [위](#forget-device)에서 명시된 바와 같이 Adjust 백엔드에서 테스트 기기를 삭제합니다.
* 테스트 기기에 Xcode로부터 앱을 실행하면, "Install tracked" 로그 메시지를 볼 수 있습니다.

### <a id="ts-iad-sdk-click"></a>"Unattributable SDK click ignored" 메시지가 나타나는 경우

`sandbox` 환경에서 앱을 테스트할 때 나타날 수 있는 메시지입니다. 이는 Apple이 도입한 `iAd.framework` 버전 3 변경과 관련된 이슈입니다. 유저가 iAd 배너를 클릭하여 앱을 실행한 경우 Adjust SDK는 Adjust 백엔드로 `sdk_click` 패키지를 전송하여 클릭된 URL의 내용을 알립니다. 그러나 Apple은 iAD 배너를 클릭하지 않고 앱이 실행된 경우 무작위 값과 함께 iAd 배너 URL 클릭을 인위적으로 생성합니다. Adjust SDK는 iAD 배너 클릭이 실제 클릭인지 인위적으로 생성된 것인지 구분하지 못하기 때문에, 두 경우 모두 Adjust 백엔드로 `sdk_click` 패키지를 전송할 것입니다. 로그 레벨을 `verbose`로 설정한 경우, `sdk_click` 패키지가 다음과 같이 나타날 것입니다.

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

`sdk_click`가 승인되면, 기타 캠페인 URL을 클릭하여 앱을 실행한 유저나 심지어 오가닉 유저조차 실제로 존재하지 않는 iAD 소스에 어트리뷰션 될 것입니다. 이러한 이유에서 Adjust 백엔드는 이를 거부하고, 다음의 메시지로 사용자에게 다음과 같이 알림을 보내는 것입니다.

```
[Adjust]v: Response: {"message":"Unattributable SDK click ignored."}
[Adjust]i: Unattributable SDK click ignored.
```

따라서 이 메시지는 SDK 연동에 문제가 있는 것이 아니라 Adjust 백엔드가 유저가 부정확하게 어트리뷰션/리어트리뷰션되지 않도록 인위적으로 생성된 `sdk_click`을 거부했음을 알리는 것입니다.

### <a id="ts-wrong-revenue-amount"></a>Adjust 대시보드에서 매출 데이터가 부정확한 경우

Adjust SDK는 사용자의 설정에 따라 트래킹합니다. 이벤트에 매출을 추가한 경우, 사용자가 입력한 금액만이 Adjust 백엔드에 전송되고 대시보드에 표시될 것입니다. Adjust SDK와 백엔드는 금액 값을 조정하지 않습니다. 잘못된 금액이 트래킹된다면 Adjust SDK가 해당 금액을 트래킹하도록 설정되었기 때문입니다.

일반적으로 매출 이벤트 트래킹을 위한 사용자 코드는 다음과 같이 나타납니다.

```objc
// ...

- (double)someLogicForGettingRevenueAmount {
    // 이 방식은 어떠한 매출 값이 트래킹 되어야 하는지에 관해
    // 사용자가 결정한 내용을 처리합니다.

    // 이를 결정하기 위해 계산을 할 수도 있습니다.

    // 또는 성공적으로 완료된 인앱 구매에서의
    // 정보를 가져올 수도 있습니다.

    // 또는 사전 정의된 이중 값을 반환할 수도 있습니다.

    double amount; // 이중 금액 = 이중 값

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

대시보드에서 예상한 바와 다른 트래킹 값을 보게 되면 **금액 값을 결정하는 로직을 확인하시기 바랍니다**.

[dashboard]:   http://adjust.com
[adjust.com]:  http://adjust.com

[en-readme]:  ../../README.md
[zh-readme]:  ../chinese/README.md
[ja-readme]:  ../japanese/README.md
[ko-readme]:  ../korean/README.md

[sdk2sdk-mopub]:  ../korean/sdk-to-sdk/mopub.md

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
[event-tracking]:    https://docs.adjust.com/ko/event-tracking
[example-iwatch]:    http://github.com/adjust/ios_sdk/tree/master/examples/AdjustExample-iWatch
[callbacks-guide]:   https://docs.adjust.com/ko/callbacks
[universal-links]:   https://developer.apple.com/library/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html

[special-partners]:     https://docs.adjust.com/ko/special-partners
[attribution-data]:     https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[ios-web-views-guide]:  /web_views.md
[currency-conversion]:  https://docs.adjust.com/ko/event-tracking/#part-7

[universal-links-guide]:      https://docs.adjust.com/ko/universal-links/
[adjust-universal-links]:     https://docs.adjust.com/ko/universal-links/
[universal-links-testing]:    https://docs.adjust.com/ko/universal-links/#part-4
[reattribution-deeplinks]:    https://docs.adjust.com/ko/deeplinking/#part-6-1
[ios-purchase-verification]:  https://github.com/adjust/ios_purchase_sdk/tree/master/doc/korean

[reattribution-with-deeplinks]:   https://docs.adjust.com/ko/deeplinking/#part-6-1

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

[associated-domains-applinks]:          https://raw.github.com/adjust/sdks/master/Resources/ios/associated-domains-applinks.png
[universal-links-dashboard-values]: https://raw.github.com/adjust/sdks/master/Resources/ios/universal-links-dashboard-values5.png

## <a id="license">라이선스

Adjust SDK는 MIT 라이선스에 따라 사용이 허가됩니다.

Copyright (c) 2012-2019 Adjust GmbH, http://www.adjust.com

이로써 본 소프트웨어와 관련 문서 파일(이하 "소프트웨어")의 복사본을 받는 사람에게는 아래 조건에 따라 소프트웨어를 제한 없이 다룰 수 있는 권한이 무료로 부여됩니다. 이 권한에는 소프트웨어를 사용, 복사, 수정, 병합, 출판, 배포 및/또는 판매하거나 2차 사용권을 부여할 권리와 소프트웨어를 제공 받은 사람이 소프트웨어를 사용, 복사, 수정, 병합, 출판, 배포 및/또는 판매하거나 2차 사용권을 부여하는 것을 허가할 수 있는 권리가 제한 없이 포함됩니다.

위 저작권 고지문과 본 권한 고지문은 소프트웨어의 모든 복사본이나 주요 부분에 포함되어야 합니다.

소프트웨어는 상품성, 특정 용도에 대한 적합성 및 비침해에 대한 보증 등을 비롯한 어떤 종류의 명시적이거나 암묵적인 보증 없이 "있는 그대로" 제공됩니다. 어떤 경우에도 저작자나 저작권 보유자는 소프트웨어와 소프트웨어의 사용 또는 기타 취급에서 비롯되거나 그에 기인하거나 그와 관련하여 발생하는 계약 이행 또는 불법 행위 등에 관한 배상 청구, 피해 또는 기타 채무에 대해 책임지지 않습니다.
--END--
