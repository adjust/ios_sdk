## 요약

웹뷰(하이브리드)를 사용하는 iOS 앱 용 Adjust\'99의 iOS SDK 가이드입니다. [adjust.com]에서 Adjust™에 대한 정보를 더 자세히 알아보세요.

[WebViewJavascriptBridge][web_view_js_bridge] 플러그인을 사용하여 Javascript에서 네이티브 Objective-C 호출(또는 그 반대로)로 브릿지를 제공합니다. 이 플러그인은 MIT 라이센스에 따라 사용이 허가되었습니다.

## 목차

* [앱 예시](#example-app)
* [기본 연동](#basic-integration)
   * [웹 브리지가있는 SDK를 프로젝트에 추가](#sdk-add)
   * [iOS 프레임워크 추가](#sdk-frameworks)
   * [앱에 SDK 연동](#sdk-integrate)
   * [AdjustBridge를 앱에 연동](#bridge-integrate-app)
   * [AdjustBridge를 웹뷰에 연동](#bridge-integrate-web)
   * [기본 설정](#basic-setup)
   * [Adjust 로](#adjust-logging)
   * [앱 빌드하기](#build-the-app)
* [부가 기능](#additional-features)
   * [이벤트 추적](#event-tracking)
      * [매출 추적](#revenue-tracking)
      * [매출 중복 제거](#revenue-deduplication)
      * [콜백 파라미터](#callback-parameters)
      * [파트너 파라미터](#partner-parameters)
   * [세션 파라미터](#session-parameters)
      * [세션 콜백 파라미터](#session-callback-parameters)
      * [세션 파트너 파라미터](#session-partner-parameters)
      * [지연 시작](#delay-start)
   * [어트리뷰션 콜백](#attribution-callback)
   * [이벤트 및 세션 콜백](#event-session-callbacks)
   * [추적 비활성화](#disable-tracking)
   * [오프라인 모드](#offline-mode)
   * [이벤트 버퍼링](#event-buffering)
   * [GDPR 잊혀질 권리(Right to be Forgotten)](#gdpr-forget-me)
   * [타사 공유 비활성화](#disable-third-party-sharing)
   * [SDK 서명](#sdk-signature)
   * [백그라운드 추적](#background-tracking)
   * [기기 ID](#device-ids)
      * [iOS 광고 식별자](#di-idfa)
      * [Adjust 기기 식별자](#di-adid)
   * [사용자 어트리뷰션](#user-attribution)
   * [푸시 토큰](#push-token)
   * [사전 설치 트래커](#pre-installed-trackers)
   * [딥링크](#deeplinking)
      * [표준 딥링크 시나리오](#deeplinking-standard)
      * [iOS 8 이전 버전에서의 딥링크](#deeplinking-setup-old)
      * [iOS 9 이후 버전에서의 딥링크](#deeplinking-setup-new)
      * [지연 딥링크(deferred deeplink) 시나리오](#deeplinking-deferred)
      * [딥링크를 통한 리어트리뷰션( reattribution)](#deeplinking-reattribution)
* [라이선스](#license)

## <a id="example-app"></a>앱 예시

repository에서 예시앱[웹 iOS 앱] [example-webview]를 찾을 수 있습니다. 이 프로젝트를 사용하여 Adjust SDK를 연동하는 방법을 확인할 수 있습니다.

## <a id="basic-integration">기본 연동

웹 브리지 SDK v4.9.1 또는 이전 버전에서 마이그레이션하는 경우이 새 버전으로 업데이트 할 때 [this migration guide] (web_view_migration.md)를 따르십시오.

iOS 개발용 Xcode를 사용한다는 가정하에 iOS 프로젝트에 Adjust SDK를 연동하는 방법을 설명합니다.

### <a id="sdk-add"> </a> 웹 브리지가있는 SDK를 프로젝트에 추가

[CocoaPods][cocoapods]를 사용하는 경우, 다음 내용을 'Podfile'에 추가한 후 [해당 단계](#sdk-integrate)를 완료하세요.

```ruby
pod 'Adjust/WebBridge', '~> 4.23.0'
```

---

[Carthage][carthage]를 사용하는 경우, 다음 내용을 'Cartfile'에 추가한 후 [해당 단계](#sdk-frameworks)를 완료하세요.

```ruby
github "adjust/ios_sdk"
```

---

프로젝트에 Adjust SDK를 프레임워크로 추가하여 연동할 수도 있습니다. [releases page][releases]에서`AdjustSdkWebBridge.framework.zip`을 찾을 수 있습니다 여기에는 동적 프레임이 포함되어 있습니다. \

### <a id="sdk-frameworks"></a>iOS 프레임워크 추가

1. Project Navigator에서 프로젝트를 선택합니다.
2. 메인 화면 좌측에서 타겟을 선택합니다.
3. 'Build Phases' 탭에서 'Link Binary with Libraries' 그룹을 확장합니다.
4. 해당 섹션의 하단에서 '+' 버튼을 선택합니다.
5. 'AdSupport.framework'를 선택하고 'Add' 버튼을 클릭합니다. 
6. 동일한 단계를 반복하여 'iAd.framework'를 추가하십시오. `CoreTelephony.framework` and `WebView.framework`
7. 프레임워크의 'Status'를 'Optional'로 변경합니다.

### <a id="sdk-integrate"></a>앱에 SDK 연동

Pod 리포지토리를 통해 Adjust SDK를 추가 한 경우 앱의 소스 파일에 다음 import 문 중 하나를 사용해야합니다.

```objc
#import "AdjustBridge.h"
```

---

Adjust SDK를 정적/동적 프레임 워크 또는 Carthage를 통해 추가 한 경우 앱의 소스 파일에 다음 import 문구를 사용해야합니다.

```objc
#<AdjustSdkWebBridge/AdjustBridge.h>가져오기
```

다음으로는 기본 세션 추적을 설정하겠습니다.

### <a id="bridge-integrate-app"></a>AdjustBridge를 앱에 연동하기

프로젝트 네비게이터에서 소스 파일 View Controller를 엽니 다. 파일 맨 위에`import` 문구를 추가하십시오.  
Web View Delegate의`viewDidLoad` 또는`viewWillAppear` 메소드는`AdjustBridge`에 다음 호출을 추가합니다.

```objc
#import "AdjustBridge.h"
// or #import <AdjustSdkWebBridge/AdjustBridge.h>

- (void)viewWillAppear:(BOOL)animated {
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];

    //@property (nonatomic, strong) AdjustBridge *adjustBridge;를 인터페이스에 추가합니다
    [self.adjustBridge loadWKWebViewBridge:webView];
    // 선택적으로 이벤트를 캡처할 수 있도록 웹뷰 delegate를 추가 할 수 있습니다
    // [self.adjustBridge loadWKWebViewBridge:webView wkWebViewDelegate:(id<WKNavigationDelegate>)self];
}

// ...
```

`AdjustBridge` 인스턴스의`bridgeRegister` 속성을 사용하여 포함 된 WebViewJavascriptBridge 라이브러리를 사용할 수도 있습니다.
레지스터/콜 핸들러 인터페이스는 WebViewJavascriptBridge가 ObjC에 대해 수행하는 것과 유사합니다. 사용 방법은 [the library documentation] (https://github.com/marcuswestin/WebViewJavascriptBridge#usage)를 참조하십시오.

### <a id="bridge-integrate-web"> </a> AdjustBrige를 웹뷰에 연동

웹뷰에서 자바 스크립트 브릿지를 사용하려면 섹션`4`에서`WebViewJavascriptBridge` 플러그인 [README] [wvjsb_readme]에서 설명하는 것처럼 구성해야합니다. 다음 자바스크립트 코드를 포함하여 Adjust iOS 웹브리지를 초기화합니다:

```js
function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        return callback(WebViewJavascriptBridge);
    }

    if (window.WVJBCallbacks) {
        return window.WVJBCallbacks.push(callback);
    }

    window.WVJBCallbacks = [callback];

    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);

    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}
```

`WebViewJavascriptBridge`의 변경으로 인해`WVJBIframe.src = 'https : // __ bridge_loaded__';`행이 버전 4.11.6에서`WVJBIframe.src = 'wvjbscheme : // __ BRIDGE_LOADED__';`에서 변경되었습니다. 플러그인.

### <a id="basic-setup"></a>기본 설정

동일한 HTML 파일에서`setupWebViewJavascriptBridge` 콜백 내에서 Adjust SDK를 초기화하십시오:

```js
setupWebViewJavascriptBridge(function(bridge) {
    // ...

    var yourAppToken = yourAppToken;
    var environment = AdjustConfig.EnvironmentSandbox;
    var adjustConfig = new AdjustConfig(yourAppToken, environment);

    Adjust.appDidLaunch(adjustConfig);

    // ...
});
```

**참고**: Adjust SDK 초기화는 '아주 중요한' 단계입니다. 제대로 완료하지 않으면 [문제 해결 섹션](#ts-delayed-init)에서 설명하는 다양한 문제가 발생할 수 있습니다.

Replace `yourAppToken` with your app token. [Dashboard]에서 결과를 확인해 보세요.

테스트 또는 배포 등 어떤 목적으로 앱을 빌드하는에 따라 다음 두 값 중 하나의 'Environment(환경)'으로 설정해야 합니다.

```js
var environment = AdjustConfig.EnvironmentSandbox;
var environment = AdjustConfig.EnvironmentProduction;
```

** 중요:**이 값은 앱을 테스트하는 상태에서만 'AdjustConfig.EnvironmentSandbox'로 설정해야합니다. 앱을 퍼블리시할 준비가 완료되면 앱스토어에 업데이트 전에 환경 모드를 AdjustConfig.EnvironmentProduction으로 변경하시기 바랍니다. 만약 앱 개발 및 테스트를 새로 시작한다면 AdjustConfig.EnvironmentSandbox로 설정하후 테스트를 진행하시면 대시보드에서 테스트 데이터가 구분됩니다.

테스트 기기로 인해 발생하는 테스트 트래픽과 실제 트래픽을 구분하기 위해 다른 환경을 사용하고 있으니, 상황에 알맞은 설정을 적용하시기 바랍니다. 이는 매출을 추적하는 경우에 특히 중요합니다.

### <a id="adjust-logging"></a>Adjust 로깅(logging)

다음 파라미터 중 하나를 통해 'ADJConfig' 인스턴스에서 'setLogLevel:'을 호출하여 테스트하는 동안 조회할 로그의 양을 늘리거나 줄일 수 있습니다.

```js
adjustConfig.setLogLevel(AdjustConfig.LogLevelVerbose)   // enable all logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelDebug)     // enable more logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelInfo)      // the default
adjustConfig.setLogLevel(AdjustConfig.LogLevelWarn)      // disable info logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelError)     // disable warnings as well
adjustConfig.setLogLevel(AdjustConfig.LogLevelAssert)    // disable errors as well
adjustConfig.setLogLevel(AdjustConfig.LogLevelSuppress)  // disable all logging
```

개발 중인 앱에 Adjust SDK가 기록하는 로그를 표시하지 않으려면, 'AdjustConfig.LogLevelSuppress` '를 선택한 후, 추가적으로 suppress log level 모드를 활성화한 constructor에서 세번째 파라미터의 true와 함께 'AdjustConfig' 객체를 초기화해야 합니다.

```js
setupWebViewJavascriptBridge(function(bridge) {
    // ...

    var yourAppToken = yourAppToken;
    var environment = AdjustConfig.EnvironmentSandbox;
    var adjustConfig = new AdjustConfig(yourAppToken, environment, true);

    Adjust.appDidLaunch(adjustConfig);

    // ...
});
```

### <a id="build-the-app"></a>앱 빌드

앱을 빌드하고 실행합니다. 빌드를 성공적으로 완료했다면, 콘솔에서 SDK 로그를 꼼꼼하게 살펴보시기 바랍니다. 앱이 시작된 후
앱을 처음으로 출시한 경우, 'Install tracked' 로그 정보를 반드시 확인하세요.

## <a id="additional-features"></a>부가 기능

Adjust SDK를 프로젝트에 연동하면 다음 기능을 활용할 수 있습니다.

### <a id="event-tracking"></a>이벤트 추적

Adjust를 사용하여 이벤트를 트래킹할 수 있습니다. 특정 버튼에 대한 모든 탭을 트래킹하려는 경우를 가정해 보겠습니다. adjust 대시보드에서 이벤트 토큰을 생성합니다. 이는 'abc123'와 같은 형태입니다. 버튼의 'onclick' method에서 탭을 트래킹하기 위해 다음 줄을 추가합니다:

```js
var adjustEvent = new AdjustEvent('abc123');
Adjust.trackEvent(adjustEvent);
```

버튼을 탭하면 이제 로그에 'Event tracked'가 표시됩니다.

이벤트 인스턴스를 사용하여 이벤트를 트래킹하기 전에 해당 이벤트를 더 구성할 수 있습니다.

### <a id="revenue-tracking"></a>매출 트래킹

사용자가 광고를 탭하거나 인앱 구매를 통해 매출을 창출 할 수있는 경우 이벤트를 통해 해당 매출을 트래킹할 수 있습니다. 광고를 한번 누르는 행위에 €0.01의 매출 금액이 발생한다고 가정해 보겠습니다. 그 경우 매출 이벤트를 다음과 같이 트래킹할 수 있습니다.:

```js
var adjustEvent = new AdjustEvent(eventToken);
adjustEvent.setRevenue(0.01, 'EUR');
Adjust.trackEvent(adjustEvent);
```

이것은 물론 콜백 파라미터와 함께 쓸 수 있습니다.

사용자가 통화 토큰을 설정하면 Adjust는 사용자가 대시보드에 설정한 통화 세팅에 따라 전송되는 매출을 reporting 매출로 자동 전환합니다. 지원하는 통화 리스트는 여기에서 확인하세요. [currency conversion here.][currency-conversion]

[event tracking guide] [event-tracking-guide]에서 매출 및 이벤트 추적에 대한 자세한 내용을 확인할 수 있습니다.

### <a id="revenue-deduplication"></a>매출 중복 제거

중복되는 매출을 트래킹하는 것을 방지하기 위해 전환 ID를 선택적으로 추가할 수 있습니다. 마지막 열 개의 트랜잭션 ID가 보관되며, 중복되는 전환 ID가 있는 매출 이벤트는 건너뛰게 됩니다. 이러한 방식은 인앱 결제 트래킹에 활용하실 수 있습니다.

웹뷰에서 트랜잭션 식별자에 액세스 할 수있는 경우 Adjust 이벤트 객체의 'setTransactionId' 메소드로 전달할 수 있습니다. 이렇게 하면 실제로 발생하지 않은 매출을 추적하는 것을 방지할 수 있습니다.

```js
var adjustEvent = new AdjustEvent(eventToken);
adjustEvent.setTransactionId(transactionIdentifier);
Adjust.trackEvent(adjustEvent);
```

### <a id="callback-parameters"></a>콜백 파라미터

[dashboard]에서 이벤트를 위한 콜백 URL을 등록할 수 있습니다. 그러면 Adjust는 이벤트가 트래킹될 때마다 해당 URL에 GET 요청을 보냅니다. 이벤트를 트래킹하기 전에 이벤트에서 'addCallbackParameter'를 호출하여 해당 이벤트에 콜백 파라미터를 추가 할 수 있습니다. 그런 다음 Adjust는 이러한 파라미터를 사용자의 콜백 URL에 추가합니다.

예를 들어, 사용자가 이벤트를 위해 http://www.adjust.com/callback URL을 등록했으며 다음과 같은 이벤트를 트래킹한다고 가정해 보겠습니다.

```js
var adjustEvent = new AdjustEvent(eventToken);
adjustEvent.addCallbackParameter('key', 'value');
adjustEvent.addCallbackParameter('foo', 'bar');
Adjust.trackEvent(adjustEvent);
```

이 경우, Adjust가 이벤트를 추적하여 다음으로 요청을 전송합니다.

    http://www.adjust.com/callback?key=value&foo=bar

Adjust는 {idfa} 등 파라미터 값으로 사용될 수 있는 다양한 placeholder를 지원합니다. 콜백을 통해 이 placeholder는 현재 기기의 특정 ID로 대체될 수 있습니다. Adjust는 사용자의 커스텀 파라미터를 저장하지 않으며 콜백에 추가하기만 합니다. 또한 이벤트를 위한 콜백을 등록하지 않은 경우에는 이러한 파라미터를 읽지도 않습니다.

Adjust [callbacks guide][callbacks-guide]에서 사용 가능한 값의 전체 리스트를 비롯하여 URL 콜백을 사용하는 방법을 자세히 알아보실 수 있습니다.

### <a id="partner-parameters"> </a> 파트너 파라미터

Adjust 대시보드에서 활성화된 연동에 대해 네트워크 파트너에게 전송할 파라미터를 추가 할 수도 있습니다.

이는 상기 콜백 파라미터와 유사한 방식으로 이루어지지만, AdjustEvent 인스턴스의 addPartnerParameter 파라미터를 호출하여 추가할 수 있습니다.

```js
var adjustEvent = new AdjustEvent('abc123');
adjustEvent.addPartnerParameter('key', 'value');
adjustEvent.addPartnerParameter('foo', 'bar');
Adjust.trackEvent(adjustEvent);
```

[특별 파트너 가이드][special-partners]에서 특별 파트너와 연동 방법에 대한 자세한 내용을 알아보실 수 있습니다.

### <a id="session-parameters"></a>세션 파라미터

일부 파라미터는 저장되어 Adjust SDK의 모든 이벤트 및 세션에 전송됩니다. 이러한 파라미터를 한 번 추가하면 로컬로 저장되기 때문에 매번 추가할 필요가 없습니다. 동일한 파라미터를 다시 추가해도 아무 일도 일어나지 않습니다.

초기 설치 이벤트와 함께 세션 파라미터를 보내려면 Adjust.appDidLaunch ()를 통해 Adjust SDK를 시작하기 전에 반드시 호출해야합니다. 설치 시에 파라미터를 전송해야 하지만 필요한 값을 실행 이후에만 확보할 수 있는 경우, 이러한 동작이 가능하게 하려면 Adjust SDK의 첫 실행을 지연시키면 됩니다.

### <a id="session-callback-parameters"></a>세션 콜백 파라미터

Adjust SDK의 모든 이벤트 또는 세션에서 전송될 [events](#callback-parameters)를 위해 등록된 동일한 콜백 파라미터를 저장할 수 있습니다.

세션 콜백 파라미터는 이벤트 콜백 파라미터와 유사한 인터페이스를 가집니다. 키와 이벤트에 값을 추가하는 대신 'Adjust' '메서 드'`addSessionCallbackParameter (key, value)`에 대한 호출을 통해 추가됩니다. :

```js
Adjust.addSessionCallbackParameter('foo', 'bar');
```

세션 콜백 파라미터는 콜백 파라미터와 병합되며 이벤트에 추가됩니다. 이벤트에 추가된 콜백 파라미터는 세션 콜백 파라미터보다 높은 우선순위를 가집니다. 세션에서 추가된 것과 동일한 키로 콜백 파라미터를 이벤트에 추가하면 이벤트에 추가된 콜백 파라미터의 값이 우선시됩니다.

원하는 키를`removeSessionCallbackParameter` 메소드에 전달하여 특정 세션 콜백 파라미터를 제거 할 수 있습니다.

```js
Adjust.removeSessionCallbackParameter('foo');
```

세션 콜백 파라미터에서 모든 키와 값을 삭제하려면 `resetSessionCallbackParameters` 메서드를 사용하여 재설정 할 수 있습니다.

```js
Adjust.resetSessionCallbackParameters();
```

### <a id="session-partner-parameters"></a>세션 파트너 파라미터

Adjust SDK의 이벤트 또는 세션에 [session callback parameters] (# session-callback-parameters)가 전송되는 것처럼 세션 파트너 파라미터도 있습니다.

이러한 파라미터는 사용자의 Adjust 대시보드에서 활성화된 네트워크 파트너 연동에 전송됩니다.

세션 파트너 파라미터는 이벤트 파트너 파라미터와 유사한 인터페이스를 가집니다. 키와 값을 이벤트에 추가하는 대신, Adjust 메서드의 addSessionPartnerParameter:value::'로의 호출을 통해 추가합니다.\

```js
Adjust.addSessionPartnerParameter('foo','bar');
```

세션 파트너 파라미터는 이벤트에 추가된 파트너 파라미터와 병합됩니다. 이벤트에 추가된 파트너 파라미터는 세션 파트너 파라미터보다 높은 우선순위를 가집니다. 세션에서 추가된 것과 동일한 키로 파트너 파라미터를 이벤트에 추가하면 이벤트에 추가된 파트너 파라미터의 값이 우선시됩니다.

원하는 키를`removeSessionPartnerParameter` 메서드에 전달하여 특정 세션 파트너 파라미터를 삭제할 수 있습니다.

```js
Adjust.removeSessionPartnerParameter('foo');
```

세션 파트너 파라미터에서 모든 키와 값을 제거하려면`resetSessionPartnerParameters` 메소드를 사용하여 재설정할 수 있습니다.

```js
Adjust.resetSessionPartnerParameters();
```

### <a id="delay-start"></a>시작 지연

Adjust SDK의 시작을 지연시키면 앱이 내부 유저 ID와 같은 세션 파라미터를 획득할 시간이 확보되므로, 세션 파라미터를 설치 시에 전송할 수 있게 됩니다.

AdjustConfig 인스턴스의 setDelayStart 필드로 초기 지연 시간을 초 단위로 설정하세요.

```js
adjustConfig.setDelayStart(5.5);
```

이렇게 설정하면 Adjust SDK가 초기 설치 세션과 5.5초 이내로 생성된 이벤트를 전송하지 않습니다. 이 시간이 만료되거나 그동안 Adjust.sendFirstPackages()`를 호출하면 모든 세션 파라미터가 지연된 설치 세션 및 이벤트에 추가되며 Adjust SDK가 평소대로 재개됩니다.

<strong>Adjust SDK의 최대 시작 지연 시간은 10초입니다</strong>.

### <a id="attribution-callback"></a>어트리뷰션 콜백

어트리뷰션 변경에 대한 알림을 받도록 콜백 메서드를 등록 할 수 있습니다. 어트리뷰션에는 다양한 소스가 관련되어 있기 때문에 이 정보는 즉각적으로 제공될 수 없습니다.

Adjust의 [applicable attribution data policies][attribution-data]을 반드시 고려해야 합니다.

콜백 메소드는 'AdjustConfig'인스턴스를 사용하여 구성되므로`Adjust.appDidLaunch (adjustConfig)`를 호출하기 전에`setAttributionCallback`을 호출해야합니다.

```js
adjustConfig.setAttributionCallback(function(attribution) {
    //이 예시에서는 어트리뷰션 콘텐츠가 포함 된 경고만 표시합니다.
    alert('Tracker token = ' + attribution.trackerToken + '\n' +
          'Tracker name = ' + attribution.trackerName + '\n' +
          'Network = ' + attribution.network + '\n' +
          'Campaign = ' + attribution.campaign + '\n' +
          'Adgroup = ' + attribution.adgroup + '\n' +
          'Creative = ' + attribution.creative + '\n' +
          'Click label = ' + attribution.clickLabel + '\n' +
          'Adid = ' + attribution.adid);
});
```

SDK가 최종 어트리뷰션 데이터를 수신하면 콜백 메서드가 트리거됩니다. 콜백 내에서 어트리뷰션 파라미터에 액세스할 수 있습니다. 그 속성에 대한 요약 정보는 다음과 같습니다.

-`var trackerToken` 현재 설치의 트래커 토큰.
-`var trackerName` 현재 설치의 트래커 이름.
-var network : 현재 설치의 네트워크 레벨.
-`var campaign` 현재 설치의 캠페인 레벨.
-`var adgroup` 현재 설치의 광고 그룹 레벨.
- 'var creative'는 현재 설치의 크리에이티브 레벨 수준입니다.
-`var clickLabel` 현재 설치의 클릭 레이블.
- 'var adid'는 어트리뷰션이 제공하는 고유 기기 식별자 (adjust ID).

값을 사용할 수없는 경우 어트리뷰션 객체의 일부가 아닙니다.

### <a id="event-session-callbacks"> </a> 이벤트 및 세션 콜백

이벤트 또는 세션이 트래킹될시 알림을 받을 콜백을 등록할 수 있습니다. 콜백에는 네 가지가 있습니다. 하나는 성공적인 이벤트를 트래킹하기 위한 것, 하나는 실패한 이벤트를 트래킹하기 위한 것, 하나는 성공한 세션을 트래킹하기위한 것, 다른 하나는 실패한 세션을 트래킹하기 위한 것입니다.

다음 단계를 수행하고 다음 콜백 메서드를 구현하여 성공적인 이벤트를 트래킹하십시오.

```js
adjustConfig.setEventSuccessCallback(function(eventSuccess) {
    // ...
});
```

다음의 델리게이트 콜백 함수(delegate callback function)는 실패한 이벤트 트래킹에 사용됩니다:

```js
adjustConfig.setEventFailureCallback(function(eventFailure) {
    // ...
});
```

성공한 세션을 트래킹하려면 :

```js
adjustConfig.setSessionSuccessCallback(function(sessionSuccess) {
    // ...
});
```

실패한 세션을 트래킹하려면 :

```js
adjustConfig.setSessionFailureCallback(function(sessionFailure) {
    // ...
});
```

SDK가 패키지를 서버로 전송하려고 시도한 후에 콜백 메소드가 호출됩니다. 콜백 메소드 내에서 콜백에 대한 response 데이터 객체에 액세스할 수 있습니다.  세션 반응 데이터 속성에 대한 요약 정보는 다음과 같습니다.

-`var message` 서버로부터의 메시지 또는 SDK에 의해 기록된 오류.
-`var timeStamp` 서버의 타임 스탬프.
- 'var adid'는 Adjust가 제공하는 고유 기기 식별자
- `var jsonResponse` 서버로부터의 응답을 포함하는 JSON 객체.

두 이벤트 응답 데이터 개체는 다음을 포함합니다.

- 'var eventToken'트래킹된 패키지가 이벤트인 경우 이벤트 토큰.

두 이벤트 및 세션 실패 개체는 다음을 포함합니다.

- 'var willRetry'는 이후 패키지 재전송 시도가 있음을 알립니다.

### <a id="disable-tracking"></a>추적 비활성화

`false` 파라미터와 함께`setEnabled`를 호출하여 Adjust SDK가 현재 기기의 모든 활동을 트래킹하는 것을 비활성화 할 수 있습니다. (주의: 트래킹 중단을 원한때만 사용하시기 바랍니다.) **이 설정은 세션 간에 유지됩니다 **.

```js
Adjust.setEnabled(false);
```

<a id="is-enabled"> `isEnabled 함수를 호출하여 Adjust SDK가 현재 활성화 되어있는지 확인할 수 있습니다.

```js
Adjust.isEnabled(function(isEnabled) {
    if (isEnabled) {
        // SDK가 활성화되었습니다.    
    } else {
        // SDK가 비활성화되었습니다.
    }
});
```

활성화된 파라미터를`true`로 설정하여 `setEnabled` 를 호출하고 언제든지 Adjust SDK를 활성화할 수 있습니다.

### <a id="offline-mode"></a>오프라인 모드

Adjust 서버에 대한 전송을 연기하고 트래킹된 데이터가 이후에 전송되도록 유지함으로써 Adjust SDK를 오프라인 모드로 설정할 수 있습니다. 오프라인 모드에서는 모든 정보가 파일에 저장되기 때문에 너무 많은 이벤트를 발생시키지 않도록 주의해야 합니다.

오프라인 모드를 활성화하려면 `setOfflineMode`를 호출하고 파라미터를 `true`로 설정합니다.

```js
Adjust.setOfflineMode(true);
```

반대로 setOfflineMode를 false로 호출하여 오프라인 모드를 비활성화할 수 있습니다. Adjust SDK가 다시 온라인 모드가 되면 저장된 모든 정보가 정확한 시간 정보와 함께 Adjust 서버로 전송됩니다.

트래킹 비활성화와는 다르게 **이 설정은 세션 간에 유지되지 않습니다**. 즉, 앱이 오프라인 모드에서 종료되었더라도 Adjust SDK는 항상 온라인 모드로 시작됩니다.

### <a id="event-buffering"></a>이벤트 버퍼링

앱이 이벤트 추적을 많이 사용하는 경우, 일부 네트워크 요청을 연기하여 네트워크 요청을 1분에 한 번씩 일괄로 보낼 수 있습니다. `AdjustConfig` 인스턴스를 통해 이벤트 버퍼링을 활성화할 수 있습니다.

```js
adjustConfig.setEventBufferingEnabled(true);
```

### <a id="gdpr-forget-me"></a>GDPR 잊혀질 권리

EU의 개인정보보호법(GDPR) 제 17조에 따라, 사용자는 잊혀질 권리(Right to be Forgotten)를 행사했음을 Adjust에 알릴 수 있습니다. 다음 메서드를 호출하면 Adjust SDK가 잊혀질 권리에 대한 사용자의 선택과 관련된 정보를 Adjust 백엔드에 보냅니다.

```js
Adjust.gdprForgetMe();
```

이 정보를 수신한 후 Adjust는 해당 사용자의 데이터를 삭제하며 Adjust SDK는 해당 사용자에 대한 추적을 중지합니다. 이 기기로부터의 요청은 향후 Adjust에 전송되지 않습니다.


### <a id="disable-third-party-sharing"> </a> 타사 공유 비활성화

이제 사용자가 마케팅 파트너를 위해 파트너와 데이터 공유를 중단할 수 있는 권리를 행사하였지만 통계적인 목적을 위해 공유할 수 있도록 허용했다는 것을 Adjust에 알릴 수 있습니다. 

다음 메서드를 호출하여 Adjust SDK가 데이터 공유 비활성화에 대한 사용자의 선택과 관련된 정보를 Adjust 백엔드에 보냅니다:

```js
Adjust.disableThirdPartySharing();
```

이 정보를 수신하면 Adjust는 특정 사용자의 데이터를 파트너와 공유하는 것을 차단하고 Adjust SDK는 계속 정상적으로 작동합니다.

### <a id="sdk-signature"></a>SDK 서명

Adjust SDK 서명은 클라이언트별로 활성화됩니다. 이 기능을 사용하기 위해서는 담당 매니저에게 문의하십시오.

SDK 서명이 이미 계정에서 활성화되어 있으며 Adjust 대시보드의 App Secret에 액세스할 수 있는 경우, 아래 방법을 사용하여 SDK 서명을 앱에 연동하세요.

'AdjustConfig'인스턴스에서`setAppSecret`을 호출하여 앱 시크릿을 설정합니다.

```js
adjustConfig.setAppSecret(secretId, info1, info2, info3, info4);
```

### <a id="background-tracking"></a>백그라운드 추적

Adjust SDK는 기본적으로 앱이 백그라운드에서 작동하는 동안 네트워크 요청 전송을 일시 중지하도록 설정되어 있습니다. `AdjustConfig` 인스턴스에서 이 동작을 변경할 수 있습니다 :

```js
adjustConfig.setSendInBackground(true);
```

아무 것도 설정되지 않으면 백그라운드 전송이 **기본적으로 비활성화됩니다**.

### <a id="device-ids"></a>기기 ID

Adjust SDK를 사용하면 일부 기기 식별자를 얻을 수 있습니다.

### <a id="di-idfa"></a>iOS 광고 식별자

특정 서비스(예: Google Analytics)는 중복 보고를 방지하기 위해 기기 및 클라이언트 ID 통합을 요청합니다.

기기 식별자 IDFA를 얻으려면`getIdfa` 함수를 호출하십시오.

```js
Adjust.getIdfa(function(idfa) {
    // ...
});
```

### <a id="di-adid"></a>Adjust 기기 식별자

사용자의 앱이 설치된 각 기기에 대해 Adjust 백앤드는 고유한 **Adjust 기기 식별자**(**adid**)를 생성합니다. 이 식별자를 얻기 위해`Adjust` 인스턴스에서 다음 메서드를 호출 할 수 있습니다.

```js
var adid = Adjust.getAdid();
```

** 참고 ** : ** adid **에 대한 정보는 Adjust 백앤드에서 앱 설치를 트래킹한 후에 사용할 수 있습니다. 그 다음부터는 Adjust SDK가 기기 **adid** 정보를 보유하게 되며, 이 메서드를 사용하여 해당 정보에 액세스할 수 있습니다. 따라서 SDK가 초기화되고 앱 설치가 추적되기 전까지는 **adid**에 액세스할 수 **없습니다**.

### <a id="user-attribution"></a>사용자 어트리뷰션

이 어트리뷰션 콜백은 [어트리뷰션 콜백 섹션](#attribution-callback)에 설명된 대로 실행되며, 변경될 때마다 새 어트리뷰션에 대한 정보를 제공합니다. 사용자의 현재 어트리뷰션에 대한 정보에 액세스할 수 있도록 하려면 `Adjust` object의 다음 메서드에 호출을 합니다.

```js
var attribution = Adjust.getAttribution();
```

**참고**: 현재 어트리뷰션에 대한 정보는 Adjust 백엔드가 앱의 설치를 추적하고 어트리뷰션 콜백이 처음으로 실행된 다음에만 사용할 수 있습니다. 그 다음부터는 Adjust SDK가 사용자의 어트리뷰션 상태에 대한 정보를 보유하게 되며, 이 메서드를 사용하여 해당 정보에 액세스할 수 있습니다. 따라서 SDK가 초기화되고 어트리뷰션 콜백이 실행되기 전까지는 사용자의 어트리뷰션 값에 액세스할 수 **없습니다**.

### <a id="push-token"></a>푸시 토큰

푸시 토큰은 오디언스 빌더(Audience Builder) 및 클라이언트 콜백에 사용되며 삭제 및 재설치 트래킹 기능에 필요합니다.

Adjust에 푸시 알림 토큰을 전송하려면 앱 델리게이트(app delegate)의 `didRegisterForRemoteNotificationsWithDeviceToken` 에 Adjust으로의 호출을 추가하세요.

```objc
#"Adjust.h"가져오기
// or # <AdjustSdkWebBridge/Adjust.h>가져오기

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Adjust setDeviceToken:deviceToken];
}
```

또는 웹보기에서 푸시 토큰에 액세스 할 수있는 경우 Javascript의`Adjust` 오브젝트에서`setDeviceToken` 메소드를 대신 호출 할 수 있습니다.

```js
Adjust.setDeviceToken(deviceToken);
```

### <a id="pre-installed-trackers"></a>사전 설치 트래커

Adjust SDK를 사용하여 본인의 앱을 발견하고 기기에 사전 설치한 사용자를 식별하려면 다음 단계를 따르세요.

1. [대시보드]에서 새 트래커를 생성합니다.
2. 앱 델리게이트를 열고 AdjustConfig 인스턴스의 기본 트래커를 설정 및 추가합니다.

  ```js
  adjustConfig.setDefaultTracker(trackerToken);
  ```

  'trackerToken'을 2 단계에서 만든 트래커 토큰으로 바꿉니다. 대시보드에 트래커가 표시됩니다.
  URL (including `http://app.adjust.com/`). 소스 코드에서 전체 URL이 아닌
  6글자의 토큰만 지정해야 합니다.

### <a id="deeplinking"> </a> 딥 링크

Adjust 트래커 URL을 사용하며 URL로부터 앱으로 딥링킹하는 옵션을 설정한 경우, 딥링크 및 그 콘텐츠에 대한 정보를 얻을 수 있습니다. 사용자가 앱을 이미 설치한 경우(표준 딥링크 시나리오) 또는 기기에 앲이 없는 경우(지연 딥링크 시나리오)에 URL 조회가 발생할 수 있습니다. 이 두 시나리오는 Adjust SDK에서 지원되며 두 경우 모두 트래커 URL에 도달 한 후 앱이 시작된 후 딥 링크 URL이 제공됩니다. 앱에서이 기능을 사용하려면 올바르게 설정해야합니다.

### <a id="deeplinking-standard"> </a> 표준 딥링크 시나리오

만일 사용자가 이미 앱을 설치하였고 딥링크 정보가 담긴 트래커 URL에 도달하였다면 애플리케이션이 열리고 딥링크의 내용이 앱으로 전송되어 파싱 및 다음 작업을 결정할 수 있습니다. iOS 9이 나오면서 Apple은 앱에서 딥링크를 처리하는 방식을 변경했습니다. 앱에 사용하려는 시나리오 (또는 다양한 기기를 지원하기 위해 둘 다 사용하려는 경우)에 따라 다음 시나리오 중 하나 또는 둘 다를 처리하도록 앱을 설정해야합니다.

### <a id="deeplinking-setup-old"> </a> iOS 8 및 이전 버전에서의 딥링크

iOS 8 및 이전 기기에서 딥링크는 커스텀 URL 스킴 설정을 사용하여 수행됩니다. 앱을 여는 데 사용할 커스텀 URL 스킴 이름을 선택해야합니다. 이 스킴 이름은`deep_link` 파라미터의 일부로 Adjust 트래커 URL에서도 사용됩니다. 앱에서 이를 설정하려면`Info.plist`를 엽니다. 파일에 새로운 'URL 유형'행을 추가합니다. 거기에 'URL 식별자'로 앱의 번들 ID를 작성하고 'URL 스킴'아래에서 앱이 처리 할 스킴 이름을 추가합니다. 아래 예제에서는 앱이`adjustExample` 스킴 이름을 처리하도록 선택했습니다.

![][custom-url-scheme]

이것이 설정되면 선택한 스킴 이름이 포함된`deep_link` 파라미터로 Adjust 트래커 URL를 클릭하면 앱이 열립니다. 앱이 열리면 'AppDelegate'클래스의`openURL` 메소드가 실행되고 트래커 URL의`deep_link` 파라미터의 내용이 전달됩니다. 딥링크의 컨텐츠에 액세스하려면이 이 매서드를 오버라이드합니다.

```objc
#"Adjust.h"가져오기
// or # <AdjustSdkWebBridge/Adjust.h>가져오기

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // url 객체에 딥링크 콘텐츠가 있습니다

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

이 셋업을 사용하여 iOS 8 및 이전 버전의 iOS 기기에 대한 딥링크 처리를 성공적으로 설정했습니다.

### <a id="deeplinking-setup-new"> </a> iOS 9 이후 버전에서 딥링크

iOS 9 이후 기기에 대한 딥링크 지원을 설정하려면 앱이 Apple 유니버셜 링크를 처리할 수 있도록 설정해야 합니다. 유니버셜 링크 및 해당 설정에 대해 자세히 알아 보려면 [here] [universal-links]를 확인하십시오.

Adjust는 개별적으로 유니버셜 링크와 관련하여 많은 것들을 처리하고 있습니다. 그러나 Adjust로 유니버셜 링크를 지원하려면 Adjust 대시 보드에서 유니버셜 링크에 대해 작은 설정을 수행해야합니다. 이에 대한 자세한 내용은 공식 [here] [universal-links-guide]를 참조하십시오.

대시보드에서 유니버셜 링크 기능을 활성화한 후에는 앱에서도 이를 수행해야합니다.

Apple Developer Portal에서 앱에 대해 'Associated Domains'를 활성화한 후에는 앱의 Xcode 프로젝트에서 동일한 작업을 수행해야합니다. `Associated Domains`를 활성화 한 후`Domains` 섹션의 Adjust 대시보드에서`applinks :`를 접두사로 사용하여 생성된 유니버설 링크를 추가하고 유니버설 링크의 `http(s)` 부분을 반드시 삭제하도록 합니다.

![][associated-domains-applinks]

이 설정이 완료되면 Adjust 트래커 유니버셜 링크를 클릭할 시 앱이 열립니다. 앱이 열리면 'AppDelegate'클래스의`continueUserActivity` 메서드가 트리거되고 유니버셜 링크 URL의 컨텐츠가 있는 곳이 전달됩니다. 딥링크의 컨텐츠에 액세스하려면이 이 매서드를 오버라이드합니다.

``` objc
#"Adjust.h"가져오기
// or # <AdjustSdkWebBridge/Adjust.h>가져오기

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
#"Adjust.h"가져오기
// or # <AdjustSdkWebBridge/Adjust.h>가져오기

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

### <a id="deeplinking-deferred"></a>지연된 딥링킹 시나리오

지연된 딥링크가 열리기 전에 알림을 받을 콜백을 등록할 수 있습니다. 이 설정은 다음을 통해 `AdjustConfig` 인스턴스에서 구성할 수 있습니다.

```js
adjustConfig.setDeferredDeeplinkCallback(function(deferredDeeplink) {
    // ...
});
```
콜백 함수는 SDK가 Adjust 서버에서 지연된 딥링크를 수신하고 열기 전에 호출됩니다. 

이 콜백이 구현되지 않으면 **Adjust SDK는 항상 기본적으로 해당 딥링크를 열려고 시도합니다.**.

AdjustConfig 인스턴스에 다른 설정을 사용하면 Adjust SDK가 이 딥링크를 열지 여부를 결정할 수 있습니다. 예를 들어 SDK가 바로 딥링크를 열지 않고 저장 후 나중에 직접 열도록 할수 있습니다. You can do this by calling the `setOpenDeferredDeeplink` method:

```js
//기본 설정. SDK는 디퍼트 딥링크 콜백 이후 딥링크를 열게 됩니다.
adjustConfig.setOpenDeferredDeeplink(true);

// 혹은 Adjust SDK가 딥링크를 열지 못하게 하려면:
adjustConfig.setOpenDeferredDeeplink(false);
```

### <a id="deeplinking-reattribution"></a>딥링크를 통한 리어트리뷰션

Adjust를 사용하면 립링크를 사용하여 리인게이지먼트(재유입) 캠페인 트래킹을 실행할 수 있습니다. 이를 수행하는 방법에 대한 자세한 정보는 Adjust의 [official docs][reattribution-with-deeplinks]에서 찾아볼 수 있습니다.

이 기능을 사용하는 경우, 사용자에 대한 리어트리뷰션이 적절히 이루어지려면 앱에서 Adjust SDK에 대한 추가적인 호출을 수행해야 합니다.

앱의 딥링크 콘텐츠 정보를 수신했으면 the `appWillOpenUrl` 매서드로 호출을 추가합니다. 이 호출을 수행함으로써 Adjust SDK는 딥링크 내부에서 새 어트리뷰션 정보를 찾으며, 정보가 있는 경우에는 Adjust 백앤드에 전송됩니다. 딥링크 콘텐츠를 포함하는 Adjust 트래커 URL에 대한 클릭으로 인해 사용자에 대한 리어트리뷰션이 이루어져야 하는 경우, 앱에서 해당 사용자에 대한 새 어트리뷰션 정보와 함께 [어트리뷰션 콜백](#attribution-callback)이 실행되는 것을 볼 수 있습니다.

`appWillOpenUrl`에 대한 호출은 모든 iOS 버전에서 딥링크 리어트리뷰션을 지원하기 위해 다음과 같이 수행되어야합니다.

```objc
#"Adjust.h"가져오기
// or # <AdjustSdkWebBridge/Adjust.h>가져오기

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // url 객체에 딥링크 콘텐츠가 있습니다
    
    [Adjust appWillOpenUrl:url];

    //이 메서드의 리턴값을 결정하기 위해 로직을 적용합니다.
    리턴 YES;
    // or
    // 리턴 NO;
}
```

``` objc
#"Adjust.h"가져오기
// or # <AdjustSdkWebBridge/Adjust.h>가져오기

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

사용자가 웹뷰에서 딥링크 URL에 액세스할 수 있으면 Javascript의`Adjust` 객체에서`appWillOpenUrl` 메서드를 호출 할 수 있습니다.

```js
Adjust.appWillOpenUrl(deeplinkUrl);
```


[dashboard]:  http://adjust.com
[adjust.com]: http://adjust.com

[releases]:   https://github.com/adjust/ios_sdk/releases
[carthage]:   https://github.com/Carthage/Carthage
[cocoapods]:  http://cocoapods.org

[wvjsb_readme]:             https://github.com/marcuswestin/WebViewJavascriptBridge#usage
[ios_sdk_ulinks]:           https://github.com/adjust/ios_sdk/#universal-links
[example-webview]:          https://github.com/adjust/ios_sdk/tree/master/examples/AdjustExample-WebView
[callbacks-guide]:          https://docs.adjust.com/en/callbacks
[attribution-data]:         https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[special-partners]:        https://docs.adjust.com/en/special-partners
[basic_integration]:        https://github.com/adjust/ios_sdk/#basic-integration
[web_view_js_bridge]:       https://github.com/marcuswestin/WebViewJavascriptBridge
[currency-conversion]:      https://docs.adjust.com/en/event-tracking/#tracking-purchases-in-different-currencies
[event-tracking-guide]:     https://docs.adjust.com/en/event-tracking/#reference-tracking-purchases-and-revenues
[reattribution-deeplinks]:  https://docs.adjust.com/en/deeplinking/#manually-appending-attribution-data-to-a-deep-link

[custom-url-scheme]:            https://raw.github.com/adjust/sdks/master/Resources/ios/custom-url-scheme.png
[associated-domains-applinks]:  https://raw.github.com/adjust/sdks/master/Resources/ios/associated-domains-applinks.png

## <a id="license"></a>License

Adjust SDK는 MIT 라이센스 하에 사용이 허가됩니다.

Copyright (c) 2012-2018 Adjust GmbH, http://www.adjust.com

다음 조건하에서 본 소프트웨어와 관련 문서 파일
(이하 "소프트웨어")의 사본을 보유한 제3자에게 소프트웨어의
사용, 복사, 수정, 병합, 게시, 배포, 재실시권 및/또는 사본의 판매 등을 포함하여
소프트웨어를 제한 없이 사용할 수 있는 권한을 무료로 부여하며,
해당 제3자는 소프트웨어를 보유한 이에게
이러한 이용을 허가할 수 있습니다.

본 소프트웨어의 모든 사본 또는 상당 부분에
위 저작권 공고와 본 권한 공고를 포함해야 합니다.

소프트웨어는 "있는 그대로" 제공되며,
소프트웨어의 상품성과 특정 목적에의 적합성 및 비 침해성에 대해
명시적이거나 묵시적인 일체의 보증을 하지 않습니다. 저자 또는 저작권자는
본 소프트웨어나 이의 사용 또는 기타 소프트웨어 관련 거래로 인해
발생하는 모든 클레임, 손해 또는 기타 법적 책임에 있어서
계약 또는 불법 행위와 관련된 소송에 대해 어떠한 책임도 부담하지
않습니다.
