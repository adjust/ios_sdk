## 摘要

这是 Adjust™ 的 iOS SDK 包。您可以在 [adjust.com] 了解更多有关 Adjust™ 的信息。

如果您的应用使用 web views，且您希望 Adjust 通过 Javascript 代码跟踪，请参阅我们的 [iOS web views SDK 指南][ios-web-views-guide]。

阅读本文的其他语言版本：[English][en-readme]、[中文][zh-readme]、[日本語][ja-readme]、[한국어][ko-readme]。

## 目录

* [应用示例](#example-apps)
* [基本集成](#basic-integration)
   * [添加 SDK 至您的项目](#sdk-add)
   * [添加 iOS 框架](#sdk-frameworks)
   * [集成 SDK 至您的应用](#sdk-integrate)
   * [基本设置](#qs-basic-setup)
      * [iMessage 的特定设置](#basic-setup-imessage)
   * [Adjust 日志](#adjust-logging)
   * [构建您的应用](#build-the-app)
* [附加功能](#additional-feature)
   * [AppTrackingTransparency 框架](#att-framework)
      * [应用跟踪授权包装器](#ata-wrapper)
      * [了解当前授权状态](#ata-getter)
   * [SKAdNetwork 框架](#skadn-framework)
      * [更新 SKAdNetwork 转化值](#skadn-update-conversion-value)
      * [转化值更新回传](#skadn-cv-updated-callback)
   * [事件跟踪](#event-tracking)
      * [收入跟踪](#revenue-tracking)
      * [收入数据去重](#revenue-deduplication)
      * [应用内收入验证](#iap-verification)
      * [回传参数](#callback-parameters)
      * [合作伙伴参数](#partner-parameters)
      * [回传标识符](#cp-event-callback-id)
   * [会话参数](#session-parameters)
      * [会话回传参数](#session-callback-parameters)
      * [会话合作伙伴参数](#session-partner-parameters)
      * [延迟启动](#delay-start)
   * [归因回传](#attribution-callback)
   * [广告收入跟踪](#ad-revenue)
   * [订阅跟踪](#subscriptions)
   * [事件与会话回传](#event-session-callbacks)
   * [禁用跟踪](#disable-tracking)
   * [离线模式](#offline-mode)
   * [事件缓冲](#event-buffering)
   * [GDPR 被遗忘权](#gdpr-forget-me)
   * [第三方分享](#third-party-sharing)
      * [禁用第三方分享](#disable-third-party-sharing)
      * [启用第三方分享](#enable-third-party-sharing)
   * [许可监测](#measurement-consent)
   * [SDK 签名](#sdk-signature)
   * [后台跟踪](#background-tracking)
   * [设备 ID](#device-ids)
      * [iOS 广告标识符](#di-idfa)
      * [Adjust 设备 ID](#adid)
   * [用户归因](#user-attribution)
   * [推送标签 (Push token)](#push-token)
   * [预安装跟踪码](#pre-installed-trackers)
   * [深度链接](#deeplinking)
      * [标准深度链接场景](#deeplinking-standard)
      * [iOS 8 及以下版本的深度链接设置](#deeplinking-setup-old)
      * [iOS 9 及以上版本的深度链接设置](#deeplinking-setup-new)
      * [延迟深度链接场景](#deeplinking-deferred)
      * [通过深度链接的再归因](#deeplinking-reattribution)
   * [[beta] 数据驻留](#data-residency)
* [问题排查](#troubleshooting)
   * [SDK 延迟初始化问题](#ts-delayed-init)
   * [显示 "Adjust requires ARC" 出错信息](#ts-arc)
   * [显示 "\[UIDevice adjTrackingEnabled\]: unrecognized selector sent to instance" 出错信息](#ts-categories)
   * [显示 "Session failed (Ignoring too frequent session.)"出错信息](#ts-session-failed)
   * [日志未显示 "Install tracked"](#ts-install-tracked)
   * [显示 "Unattributable SDK click ignored" 信息](#ts-iad-sdk-click)
   * [Adjust 控制面板显示错误收入数据](#ts-wrong-revenue-amount)
* [许可协议](#license)

## <a id="example-apps"></a>应用示例

[`examples` 目录][examples]内有 [`iOS (Objective-C)`][example-ios-objc]、[`iOS (Swift)`][example-ios-swift]、[`tvOS`][example-tvos]、[`iMessage`][example-imessage] 和 [`Apple Watch`][example-iwatch] 的应用示例。您可以打开任何一个 Xcode 项目查看集成 Adjust SDK 的例子。

## <a id="basic-integration">基本集成

我们将介绍把 Adjust SDK 集成到 iOS 项目中的步骤。我们假定您使用 Xcode 进行 iOS 开发。

### <a id="sdk-add"></a>添加 SDK 至您的项目

如果您正在使用 [CocoaPods][cocoapods]，可以将以下代码行添加至 `Podfile`，然后继续进行[此步骤](#sdk-integrate)：

```ruby
pod 'Adjust', '~> 4.29.1'
```

或：

```ruby
pod 'Adjust', :git => 'https://github.com/adjust/ios_sdk.git', :tag => 'v4.29.1'
```

---

如果您正在使用 [Carthage][carthage]，可以将以下代码行添加至 `Cartfile`，然后继续进行[此步骤](#sdk-frameworks)：

```ruby
github "adjust/ios_sdk"
```

---

如果您正在使用 Swift Pacage Manager，可以转到 `File > Swift Packages > Add Package Dependency`，直接在 Xcode 中添加库的地址，然后继续进行[此步骤](#sdk-frameworks)：

```
https://github.com/adjust/ios_sdk
```

---

您也可以把 Adjust SDK 作为框架添加至您的项目中，来进行集成。在[发布专页][releases]，您可以找到以下文档：

* `AdjustSdkStatic.framework.zip`
* `AdjustSdkDynamic.framework.zip`
* `AdjustSdkTv.framework.zip`
* `AdjustSdkIm.framework.zip`

自 iOS 8 发布以来，Apple 引入了动态框架 (dynamic frameworks)，也称为嵌入式框架 (embedded frameworks)。如果您的应用目标对象是 iOS 8 或以上版本，则可以使用 Adjust SDK 动态框架。请选择您希望使用的框架 – 静态或动态 – 并将其添加到项目中。

如果您正在使用 `tvOS` 应用，可以使用 Adjust SDK，也可使用我们的 tvOS 框架，该框架可从 `AdjustSdkTv.framework.zip` 文档中提取。

如果您正在使用 `iMessage` 应用，可以使用 Adjust SDK，也可使用我们的 IM 框架，该框架可从 `AdjustSdkIm.framework.zip` 文档中提取。

### <a id="sdk-frameworks"></a>添加 iOS 框架

如果您关联额外的 iOS 框架到应用中，Adjust SDK 将能获取更多的信息。请根据应用启用 Adjust SDK 功能的情况，添加下列框架，并将其标记为 "可选" (optional)：

- `AdSupport.framework` - 请务必添加该框架，让 SDK 能访问 IDFA 值和 (iOS 14 以前的) LAT 信息。
- `iAd.framework` - 如果您希望 SDK 自动处理您的 ASA 推广活动归因数据，请添加该框架。
- `AdServices.framework`- 对于 iOS 14.3 及以上的设备，该框架允许 SDK 自动处理 ASA 推广活动归因数据。使用 Apple Ads 归因 API 时必须采用该框架。
- `CoreTelephony.framework`- 如果您希望 SDK 能辨识当前的无线接入技术 (radio access)，请添加该框架。
- `StoreKit.framework`- 如果您希望访问 `SKAdNetwork` 框架，同时让 Adjust SDK 在 iOS 14 或未来版本的 iOS 中自动处理与`SKAdNetwork` 的通讯，请添加该框架。
- `AppTrackingTransparency.framework` - 如果您希望 SDK 能在 iOS 14 或未来版本的 iOS 中包装用户的跟踪许可对话框，并访问用户跟踪许可的值，请添加该框架。

### <a id="sdk-integrate"></a>集成 SDK 至您的应用

如果您从 Pod 库添加 Adjust SDK，请从以下导入语句中选一使用：

```objc
#import "Adjust.h"
```

或

```objc
#import <Adjust/Adjust.h>
```

---

如果您是以静态/动态框架 (static/dynamic framework) 或者经 Carthage 添加 Adjust SDK，请使用以下导入语句：

```objc
#import <AdjustSdk/Adjust.h>
```

---

如果您在 tvOS 应用中使用 Adjust SDK，请使用以下导入语句：

```objc
#import <AdjustSdkTv/Adjust.h>
```

---

如果您在 iMessage 应用中使用 Adjust SDK，请使用以下导入语句:

```objc
#import <AdjustSdkIm/Adjust.h>
```

接下来，我们将设置基本会话跟踪。

### <a id="qs-basic-setup"></a>基本设置

在项目导航 (Project Navigator) 中，打开您的应用委托 (application delegate) 源文件。在文件顶部添加 `import` (import) 语句，然后在应用委托的 `didFinishLaunching` 或 `didFinishLaunchingWithOptions` 方法中，将以下调用添加至 `Adjust`：

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

**请注意**：Adjust SDK 初始化设置 `非常重要`。否则，您有可能会遇到[问题排查](#ts-delayed-init)中描述的多种问题。

用您的应用识别码 (app token) 替换 `{YourAppToken}`。您可以在[控制面板]上找到该应用识别码。

取决于您的应用创建是用于测试或产品开发目的，您必须将 `environment` (环境模式) 设为以下值之一：

```objc
NSString *environment = ADJEnvironmentSandbox;
NSString *environment = ADJEnvironmentProduction;
```

**重要提示:** 只有在您或其他人测试应用时，才应将该值设为 `ADJEnvironmentSandbox`。在发布应用之前，请确保将环境设为 `ADJEnvironmentProduction`。再次开始研发和测试时，将其设回 `ADJEnvironmentSandbox`。

我们按照设置的环境来区分真实流量和来自测试设备的测试流量。非常重要的是，您必须始终让该值保持有意义！这一点在进行收入跟踪时尤为重要。

### <a id="basic-setup-imessage"></a>iMessage 的特定设置

**从源代码添加 SDK**：如果您选择**从源代码**添加 Adjust SDK 到 iMessage 应用，请确保您已在 iMessage 项目中设置了预处理宏 **ADJUST_IM=1**。

**将 SDK 作为框架添加**：在将 `AdjustSdkIm.framework` 添加到 iMessage 应用后，请确保在 `Build Phases` 项目设置中添加 `New Copy Files Phase` 并选择将 `AdjustSdkIm.framework`复制到 `Frameworks` 文件夹。

**会话跟踪**：如果您希望在 iMessage 应用中正常使用会话跟踪功能，则需要执行一个额外的集成步骤。在标准 iOS 应用中，Adjust SDK 会自动订阅 iOS 系统通知，让我们能够知晓应用进入或离开前台的时间。在 iMessage 应用的情况则有所不同，您需要在 iMessage 应用视图控制器中添加对 `trackSubsessionStart` 和 `trackSubsessionEnd` 方法的显示调用，以在应用进入前台时通知我们的 SDK。

在 `didBecomeActiveWithConversation:` 方法中添加对 `trackSubsessionStart` 的调用：

```objc
-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    // Use this method to configure the extension and restore previously stored state.

    [Adjust trackSubsessionStart];
}
```

在 `willResignActiveWithConversation:` 方法中添加对 `trackSubsessionEnd` 的调用：

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

设置完成后，Adjust SDK 就能够在您的 iMessage 应用中成功执行会话跟踪。

**请注意**：您的 iOS 应用和为其创建的 iMessage 扩展程序是在不同的内存空间中运行的，它们也拥有不同的 Bundle ID。如果使用相同的应用识别码来初始化 Adjust SDK ，将导致独立的两者在没有注意到彼此的状况下进行跟踪，进而使控制面板上的数据显得混杂，为您带来不便。我们通常建议您在 Adjust 控制面板中为 iMessage 应用创建单独的应用，并使用单独的应用识别码来初始化 SDK。

### <a id="adjust-logging"></a>Adjust 日志

您可以增加或减少在测试中看到的日志数量，方法是用以下参数之一来调用 `ADJconfig` 实例上的 `setLogLevel`：

```objc
[adjustConfig setLogLevel:ADJLogLevelVerbose];  // enable all logging
[adjustConfig setLogLevel:ADJLogLevelDebug];    // enable more logging
[adjustConfig setLogLevel:ADJLogLevelInfo];     // the default
[adjustConfig setLogLevel:ADJLogLevelWarn];     // disable info logging
[adjustConfig setLogLevel:ADJLogLevelError];    // disable warnings as well
[adjustConfig setLogLevel:ADJLogLevelAssert];   // disable errors as well
[adjustConfig setLogLevel:ADJLogLevelSuppress]; // disable all logging
```

如果您不希望开发中的应用显示来自 Adjust SDK 的任何日志，请选择 `ADJLogLevelSuppress`，并通过另一个构建函数初始化 `ADJConfig` 对象，启用抑制日志级别模式:

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

### <a id="build-the-app"></a>构建您的应用

创建并运行自己的应用。如果构建成功，您应当仔细阅读控制台的 SDK 日志。应用首次启动之后，您应当看到信息日志 `Install tracked`（安装已跟踪）。

![][run]

## <a id="additional-feature">附加功能

将 Adjust SDK 集成到项目中后，您即可利用以下功能。

### <a id="att-framework"></a>AppTrackingTransparency 框架

每发送一个包，Adjust 的后端就会收到下列四 (4) 种许可状态之一，了解用户是否授权分享应用相关数据，用于用户或设备跟踪：

- Authorized (授权)
- Denied (拒绝)
- Not Determined (待定)
- Restricted (受限)

如果设备收到了用于用户设备跟踪目的应用相关数据访问授权请求，那么返回的状态要么是 Authorized，要么是 Denied。

如果设备尚未收到用于用户设备跟踪目的应用相关数据访问授权请求，那么返回的状态是 Not Determined。

如果应用跟踪数据授权受限，那么返回的状态是 Restricted。

如果您不需要自定义显示的弹出对话框，SDK 拥有内置机制可在用户回复弹出对话框后接收更新后的状态。为了简便、高效地向后端发送用户许可的新状态，Adjust SDK 会提供一个应用跟踪授权方法包装器，详情请参阅下一章节 "应用跟踪授权包装器"。

### <a id="ata-wrapper"></a>应用跟踪授权包装器

您可以使用 Adjust SDK 请求用户授权，让用户允许您访问他们的应用相关数据。基于 [requestTrackingAuthorizationWithCompletionHandler:](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorizationwith?language=objc) 方法，Adjust SDK 打造了一个包装器，您可以定义回传方法，了解用户是否授予了数据跟踪许可。借助该包装器，只要用户回复弹出对话框，这一信息就能通过您定义的回传方式传递回来。SDK 也会通知后端用户的许可选择。`NSUInteger` 值将通过您的回传方法传递，不同值的含义如下：

- 0: `ATTrackingManagerAuthorizationStatusNotDetermined` (授权状态待定)
- 1: `ATTrackingManagerAuthorizationStatusRestricted` (授权状态受限)
- 2: `ATTrackingManagerAuthorizationStatusDenied`(已拒绝)
- 3: `ATTrackingManagerAuthorizationStatusAuthorized`(已授权)

要使用该包装器，您可以按照下列方法进行调用：

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

### <a id="ata-getter"></a>获得当前授权状态

要接收当前应用跟踪授权状态，请调用 `[Adjust appTrackingAuthorizationStatus]`，会返回下列可能的值之一：

* `0`：用户尚未收到请求
* `1`：用户设备受限
* `2`：用户拒绝提供 IDFA
* `3`：用户授权访问 IDFA
* `-1`：状态不可用


### <a id="skadn-framework"></a>SKAdNetwork 框架

如果您已经安装了 Adjust iOS SDK v4.23.0 或更新版本，且您的应用在 iOS 14 端运行，那么与 SKAdNetwork 之间的通讯会默认启用，但您可以自行禁用通讯。启用状态下，Adjust 会在 SDK 初始化时自动注册 SKAdNetwork 归因。如果您在 Adjust 控制面板中对事件进行了接收转化值设置，那么 Adjust 后端就会将转化值数据发送给 SDK。然后 SDK 会设定转化值。Adjust 收到 SKAdNetwork 回传数据后，会在控制面板中予以显示。

如果您不希望 Adjust SDK 自动与 SKAdNetwork 通讯，可以针对配置对象调用如下方法：

```objc
[adjustConfig deactivateSKAdNetworkHandling];
```

### <a id="skadn-update-conversion-value"></a>更新 SKAdNetwork 转化值

从 iOS SDK v4.26.0 开始，您就可以使用 Adjust SDK 包装器方法 `updateConversionValude:` 为用户更新 SKAdNetwork 转化值：

```objc
[Adjust updateConversionValue:6];
```

### <a id="skadn-cv-updated-callback"></a>转化值更新回传

您可以注册回传，在每次 Adjust SDK 更新用户转化值时获得通知。请安装 `AdjustDelegate` 协议，以及可选的 `adjustConversionValueUpdated:` 方法：

```objc
- (void)adjustConversionValueUpdated:(NSNumber *)conversionValue {
    NSLog(@"Conversion value updated callback called!");
    NSLog(@"Conversion value: %@", conversionValue);
}
```

### <a id="event-tracking"></a>事件跟踪

您可以通过 Adjust 来跟踪事件。假设您想要跟踪具体按钮的每一次点击。要达到这个目的，您要在[控制面板]上创建新的事件识别码，[控制面板]有相关的事件识别码，例如 `abc123` 等。在按钮 `bottonDown` 方法中，添加以下代码行以跟踪点击：

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[Adjust trackEvent:event];
```

您在点击按钮时，应当可以在日志中看到 `Event tracked`（事件已跟踪）。

事件实例可以用于在跟踪之前对事件作进一步配置：

### <a id="revenue-tracking"></a>收入跟踪

如果您的用户可以通过点击广告或应用内购为您带来收入，您可以按照事件来跟踪这些收入。假设一次点击值一欧分。那么您可以这样来跟踪收入事件：

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event setRevenue:0.01currency:@"EUR"];

[Adjust trackEvent:event];
```

当然，这可以和回传参数相结合。

设置货币识别码后，Adjust 会自动将收入转化为您所选的报告收入。[在此了解更多货币换算相关信息][currency-conversion]。

要更多地了解收入和事件跟踪相关信息，欢迎参阅[事件跟踪指南](https://help.adjust.com/zh/article/app-events#tracking-purchases-and-revenues)。

### <a id="revenue-deduplication"></a>收入数据去重

您也可以输入可选的交易 ID，以避免跟踪重复收入。最近的十个交易 ID 将被记录下来，带有重复交易 ID 的收入事件将被跳过。这对于应用内购跟踪尤其有用。参见以下例子。

如果您想要跟踪应用内购，请确保只有状态变为 `SKPaymentTransactionStatePurchased` 时，才在 finishTransaction` 之后在 `paymentQueue:updatedTransaction` 中调用 `trackEvent`。这样您可以避免跟踪实际未产生的收入。

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

### <a id="iap-verification"></a>应用内收入验证

如果您希望使用收入验证（即 Adjust 服务器端收据验证工具）来检查应用内购的真实性，请查看我们的 iOS 购买 SDK 并[在此][ios-purchase-verification]阅读详细内容。

### <a id="callback-parameters"></a>回传参数

您可以在 [控制面板] 中为事件输入回传 URL。这样，只要跟踪到事件，我们都会向该 URL 发送 GET 请求。您可以在跟踪前调用事件的 `addCallbackParameter` ，向该事件添加回传参数。之后我们会将这些参数附加至您的回传 URL。

例如，假设您输入了 URL `http://www.mydomain.com/callback` 则使用以下方式跟踪事件：

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event addCallbackParameter:@"key" value:@"value"];
[event addCallbackParameter:@"foo" value:@"bar"];

[Adjust trackEvent:event];
```

在这种情况下，我们会跟踪该事件并发送请求至：

    http://www.mydomain.com/callback?key=value&foo=bar

值得一提的是，我们支持各种可以用作参数值的占位符，例如 `{idfa}`。在接下来的回传中，该占位符将被当前设备的广告 ID 代替。同时请注意，我们不会存储您的任何自定义参数。我们仅将这些参数附加到您的回传中。所以如果没有设置回传，这些参数不会被保存，也不会发送给您。

若想进一步了解 URL 回传，查看可用参数的完整列表，请参阅我们的 [回传指南][callbacks-guide]。

### <a id="partner-parameters"></a>合作伙伴参数

在 Adjust 控制面板中启用了相关功能后，您还可以添加与合作伙伴共享的参数。

工作方式和上述提及的回传参数类似，但可以通过调用 `ADJEvent` 实例上的 `addPartnerParameter` 方法来添加。

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event addPartnerParameter:@"key" value:@"value"];
[event addPartnerParameter:@"foo" value:@"bar"];

[Adjust trackEvent:event];
```

您可以在我们的 [特殊合作伙伴指南][special-partners] 中进一步了解特殊合作伙伴以及这些集成的信息。

### <a id="cp-event-callback-id"></a>回传标识符

您还可为想要跟踪的每个事件添加自定义字符串 ID。此 ID 将在之后的事件成功和/或事件失败回传中被报告，以便您及时了解哪些事件跟踪成功或者失败。您可通过调用 `ADJEvent` 实例上的 `setCallbackId` 方法来设置此标识符：


```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];

[event setCallbackId:@"Your-Custom-Id"];

[Adjust trackEvent:event];
```

### <a id="session-parameters"></a>会话参数

一些参数被保存发送到 Adjust SDK 的每一个事件和会话中。一旦添加此类参数，则无需再每次重复添加，因为这些参数将被保存至本地。如果您添加同样参数两次，也不会有任何效果。

如果您希望和初始安装事件一同发送会话参数，这些参数必须在 Adjust SDK 通过 `[Adjust appDidLaunch:]`启动之前被调用。如果您需要在安装同时发送参数，但只有在 SDK 启动后才能获得必需的值，则可以[延迟](#delay-start) Adjust SDK 的首次启动以允许该行为。

### <a id="session-callback-parameters"></a>会话回传参数

被注册在[事件](#callback-parameters) 中的相同回传参数也可以被保存发送至 Adjust SDK 的每一个事件和会话中。

会话回传参数拥有与事件回传参数类似的接口。该参数是通过调用 `Adjust` 方法 `addSessionCallbackParameter:value:`(添加会话回调参数值) 被添加，而不是添加 Key 和值至事件:

```objc
[Adjust addSessionCallbackParameter:@"foo" value:@"bar"];
```

会话回传参数将与被添加至事件的回传参数合并。被添加至事件的回传参数拥有高于会话回传参数的优先级。这意味着，当被添加至事件的回传参数拥有与会话回传参数同样的 Key 时，以被添加至事件的回传参数值为准。

您可以通过传递 Key 至 `removeSessionCallbackParameter` 方法来删除特定会话回传参数。

```objc
[Adjust removeSessionCallbackParameter:@"foo"];
```

如果您希望删除会话回传参数中所有的 Key 及值，可以通过 `resetSessionCallbackParameters` 方法重置。

```objc
[Adjust resetSessionCallbackParameters];
```

### <a id="session-partner-parameters"></a>会话合作伙伴参数

与 [会话回传参数](#session-callback-parameters) 的方式一样，会话合作伙伴参数也会与 SDK 的每个事件或会话一同发送。

它们将被传送至渠道合作伙伴，用于 Adjust [控制面板]上已经激活的模块集成。

会话合作伙伴参数拥有与事件合作伙伴参数类似的接口。该参数是通过调用 `Adjust` 方法 `addSessionPartnerParameter:value:`(添加会话合作伙伴参数值) 被添加，而不是添加 Key 和值至事件：

```objc
[Adjust addSessionPartnerParameter:@"foo" value:@"bar"];
```

会话合作伙伴参数将与被添加至事件的合作伙伴参数合并。被添加至事件的合作伙伴参数具有高于会话合作伙伴参数的优先级。这意味着，当被添加至事件的合作伙伴参数拥有与会话合作伙伴参数同样的 Key 时，以被添加至事件的合作伙伴参数值为准。

您可以通过传递 Key 至 `Adjust.removeSessionPartnerParameter` 方法，删除特定的会话合作伙伴参数。

```objc
[Adjust removeSessionPartnerParameter:@"foo"];
```

如果您希望删除会话合作伙伴参数中所有的 Key 及值，则可以通过 `resetSessionPartnerParameters` 方法重置。

```objc
[Adjust resetSessionPartnerParameters];
```

### <a id="delay-start"></a>延迟启动

延迟 Adjust SDK 的启动可以为您的应用提供更充裕的时间，来接收所有想要随安装发送的会话参数 (例如：唯一标识符)。

利用 `ADJConfig` 实例中的 `setDelayStart` 方法，以秒为单位设置初始延迟时间：

```objc
[adjustConfig setDelayStart:5.5];
```

在此种情况下，Adjust SDK 不会在 5.5 秒内发送初始安装会话以及所创建的任何事件。在该时间过期后或同时调用 `[Adjust sendFirstPackages]`时，每个会话参数将被添加至延迟的安装会话和事件中，Adjust SDK 将恢复正常。

**您最多可以将 Adjust SDK 的启动时间延长 10 秒**。

### <a id="attribution-callback"></a>归因回传

您可以注册一个委托回传，以获取跟踪链接归因变化的通知。由于考虑到归因的不同来源，归因信息无法被同步提供。遵循以下步骤在您的应用委托中启用可选的委托协议：

请务必考虑我们的[适用归因数据政策][attribution-data]。

1. 打开 `AppDelegate.h`，添加导入和 `AdjustDelegate` 声明。

    ```objc
    @interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>
    ```

2. 打开 `AppDelegate.m`，添加以下委托回传功能至您的应用委托执行 (app delegate implementation)。

    ```objc
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    }
    ```

3. 用您的 `ADJConfig` 实例设置委托：

    ```objc
    [adjustConfig setDelegate:self];
    ```

由于委托回调使用 `ADJConfig` 实例进行配置，您应当在调用 `[Adjust appDidLaunch:adjustConfig]` 之前调用 `setDelegate`。

当 SDK 接收到最终归因数据后，将会调用委托功能。在委托功能内，您可以访问 `attribution` (归因)参数。以下是归因属性的摘要：

- `NSString trackerToken` 当前归因的跟踪码
- `NSString trackerName` 当前归因的跟踪链接名称
- `NSString network` 当前归因的渠道分组级别
- `NSString campaign` 当前归因的推广活动分组级别
- `NSString adgroup` 当前归因的广告组分组级别
- `NSString creative` 当前归因的素材分组级别
- `NSString clickLabel` 当前归因的点击标签
- `NSString adid` 归因提供的唯一设备 ID
- `NSString costType` 成本类型字符串。
- `NSNumber costAmount` 成本金额。
- `NSString costCurrency` 成本币种字符串。

当值不可用时，将默认为 `nil`。

请注意：只有在 `ADJConfig` 中通过调用 `setNeedsCost` 方法来进行配置后，`costType`、 `costAmount` 和 `costCurrency` 成本数据才可用。如果未进行配置，或已配置但这些字段不属于归因的一部分，那么字段值就会为 `nil`。此功能仅适用于 SDK 4.24.0 及以上版本。

### <a id="ad-revenue"></a>广告收入跟踪

**注意**：该广告收入跟踪 API 仅适用于原生 SDK v.29.0 及更高版本。

您可以通过调用以下方法，使用 Adjust SDK 对广告收入进行跟踪：

```objc
// initilise ADJAdRevenue instance with appropriate ad revenue source
ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:source];
// pass revenue and currency values
[adRevenue setRevenue:1.6currency:@"USD"];
// pass optional parameters
[adRevenue setAdImpressionsCount:adImpressionsCount];
[adRevenue setAdRevenueUnit:adRevenueUnit];
[adRevenue setAdRevenuePlacement:adRevenuePlacement];
[adRevenue setAdRevenueNetwork:adRevenueNetwork];
// attach callback and/or partner parameter if needed
[adRevenue addCallbackParameter:key value:value];
[adRevenue addPartnerParameter:key value:value];

// track ad revenue
[Adjust trackAdRevenue:source payload:payload];
```

目前，我们支持以下 `source` 参数值：

- `ADJAdRevenueSourceAppLovinMAX` - representing AppLovin MAX platform.
- `ADJAdRevenueSourceMopub` - representing MoPub platform.
- `ADJAdRevenueSourceAdMob` - representing AdMob platform.
- `ADJAdRevenueSourceIronSource` - representing IronSource platform.

**请注意**：会有独立于本 REDME 之外的文档，解释每个受支持来源的详细集成信息。此外，要使用该功能，您需要在 Adjust 控制面板中进行额外的应用设置。因此，请务必联系我们的支持团队，在启用功能前确保一切设置妥当。

### <a id="subscriptions"></a>订阅跟踪

**请注意**：此功能仅适用于原生 SDK 4.22.0 及以上版本。我们推荐您使用最低 4.22.1 版本。 

**重要提示**：下列步骤仅会在 SDK 中设置订阅跟踪。要完成设置，您必须在 Adjust 内部界面中提供具体应用的特定信息。该操作必须由 Adjust 代表完成。请联系 support@adjust.com 或您的技术客户经理。 

您可以用 Adjust SDK 跟踪 App Store 的订阅，并验证这些订阅是否有效。订阅购买成功后，请向 Adjust SDK 进行如下调用：

```objc
ADJSubscription *subscription = [[ADJSubscription alloc] initWithPrice:price
                                                              currency:currency
                                                         transactionId:transactionId
                                                            andReceipt:receipt];
[subscription setTransactionDate:transactionDate];
[subscription setSalesRegion:salesRegion];

[Adjust trackSubscription:subscription];
```

请确保只有状态变为 `SKPaymentTransactionStatePurchased` 或 `SKPaymentTransactionStateRestored` 时才进行该操作。然后在 `paymentQueue:updatedTransactions` 中调用 `finishTransaction`。

订阅跟踪参数：

- [price](https://developer.apple.com/documentation/storekit/skproduct/1506094-price?language=objc)
- currency (您需要发送 [priceLocale](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc) 对象的 [currencyCode](https://developer.apple.com/documentation/foundation/nslocale/1642836-currencycode?language=objc) )
- [transactionId](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc)
- [receipt](https://developer.apple.com/documentation/foundation/nsbundle/1407276-appstorereceipturl)
- [transactionDate](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411273-transactiondate?language=objc)
- salesRegion (您需要发送 [priceLocale](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc) 对象的 [countryCode](https://developer.apple.com/documentation/foundation/nslocale/1643060-countrycode?language=objc) )

与事件跟踪一样，您也可以向订阅对象附加回传和合作伙伴参数：

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

### <a id="event-session-callbacks"></a>事件和会话回传

您可以设置委托回调，用于在事件和/或会话跟踪成功和失败时获取通知。使用的是和[归因回传][#attribution-callback]一样的 `AdjustDelegate` 可选协议。

按照同样的步骤，执行以下委托回传函数，于成功跟踪事件时调用：

```objc
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
}
```

以下为事件跟踪失败的委托回传函数：

```objc
- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
}
```

跟踪成功的会话：

```objc
- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
}
```

跟踪失败的会话：

```objc
- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
}
```

委托函数将于 SDK 尝试发送包 (package) 到服务器后调用。在委托回传内，您能访问专为委托回传所设的响应数据对象。会话响应数据属性摘要如下：

- `NSString message` 服务器信息或者 SDK 记录的错误信息
- `NSString timeStamp` 服务器的时间戳
- `NSString adid` Adjust 提供的唯一设备标识符
- `NSDictionary jsonResponse` JSON 对象及服务器响应

两个事件响应数据对象都包含：

- 如果跟踪的包是一个事件，`NSString eventToken` 代表事件识别码。
- `NSString callbackId`为事件对象设置的自定义回传 ID。

当值不可用时，将默认为 `nil`。

事件和会话跟踪失败的对象也均包含：

- `BOOL willRetry` 表示稍后将再次尝试发送数据包。

### <a id="disable-tracking"></a>禁用跟踪

您可以调用参数为 `NO`的 `setEnabled`，停用 Adjust SDK 跟踪目前设备所有活动的功能。**该设置在会话间保存**。

```objc
[Adjust setEnabled:NO];
```

<a id="is-enabled">您可以通过调用 `isEnabled` 函数来查看 Adjust SDK 目前是否启用。您始终可以通过调用启用参数设置为 `YES` 的 `setEnabled` 来激活 Adjust SDK。

### <a id="offline-mode"></a>离线模式

您可以把 Adjust SDK 设置为离线模式，以暂停发送数据到我们的服务器，但仍然继续跟踪及保存数据并于之后发送。当设为离线模式时，所有数据将存放于一个文件中，所以请注意不要在离线模式时触发太多事件。

您可以调用参数为 `YES` 的 `setOfflineMode`，以激活离线模式。

```objc
[Adjust setOfflineMode:YES];
```

相反地，您可以调用 `setOfflineMode`，启用参数为 `NO`，以终止离线模式。当Adjust SDK 回到在线模式时，所有被保存的数据将被发送到我们的服务器，并保留正确的时间信息。

跟禁用跟踪设置不同的是，此设置在会话与会话之间将**不被保存**。也就是说，即使应用在处于离线模式时停用，SDK 每次启动时都必定处于在线模式。

### <a id="event-buffering"></a>事件缓冲

如果您的应用大量使用事件跟踪，您可能会想要延迟部分 HTTP 请求，以便按分钟成批发送这些请求。您可以通过 `ADJConfig` 实例启用事件缓冲：

```objc
[adjustConfig setEventBufferingEnabled:YES];
```

如果不做任何设置，事件缓冲为 **默认禁用**。

### <a id="gdpr-forget-me"></a>GDPR 被遗忘权

根据欧盟的《一般数据保护条例》(GDPR) 第 17 条规定，用户行使被遗忘权时，您可以通知 Adjust。调用以下方法时，Adjust SDK 将会收到指示向 Adjust 后端传达用户选择被遗忘的信息：

```objc
[Adjust gdprForgetMe];
```

收到此信息后，Adjust 将清除用户数据，并且 Adjust SDK 将停止跟踪该用户。以后不会再向 Adjust 发送来自此设备的请求。

## <a id="third-party-sharing"></a>具体用户的第三方数据分享

当有用户禁用、启用或重启第三方合作伙伴数据分享时，您可以通知 Adjust。

### <a id="disable-third-party-sharing"></a>为具体用户禁用第三方数据分享

请调用以下方法，指示 Adjust SDK 将用户禁用数据分享的选择传递给 Adjust 后端：

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:@NO];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

收到此信息后，Adjust 会停止向合作伙伴分享该用户的数据，而 Adjust SDK 将会继续如常运行。

### <a id="enable-third-party-sharing">为具体用户启用或重启第三方数据分享</a>

请调用以下方法，指示 Adjust SDK 将用户启用或变更数据分享的选择传递给 Adjust 后端：

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:@YES];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

收到此信息后，Adjust 会就是否与合作伙伴分享该用户的数据做出相应变更，而 Adjust SDK 将会继续如常运行。

请调用以下方法，指示 Adjust SDK 向 Adjust 后端发送精细选项：

```objc
ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:nil];
[adjustThirdPartySharing addGranularOption:@"PartnerA" key:@"foo" value:@"bar"];
[Adjust trackThirdPartySharing:adjustThirdPartySharing];
```

### <a id="measurement-consent"></a>监测具体用户的许可

要在 Adjust 控制面板中启用或禁用数据隐私设置，包括许可有效期和用户数据留存期，您需要安装以下方法。

请调用以下方法，指示 Adjust SDK 将数据隐私设置传递给 Adjust 后端：

```objc
[Adjust trackMeasurementConsent:YES];
```

收到此信息后，Adjust 会就是否与合作伙伴分享该用户的数据做出相应变更，而 Adjust SDK 将会继续如常运行。

### <a id="sdk-signature"></a>SDK 签名

Adjust SDK 签名功能是按客户逐一启用的。如果您希望使用该功能，请联系您的客户经理。

如果您已经在账户中启用了 SDK 签名，并可访问 Adjust 控制面板的应用密钥，请使用以下方法来集成 SDK 签名到您的应用。

在您的 `AdjustConfig` 实例中调用 `setAppSecret` 来设置应用密钥。

```objc
[adjustConfig setAppSecret:secretId info1:info1 info2:info2 info3:info3 info4:info4];
```

### <a id="background-tracking"></a>后台跟踪

Adjust SDK 的默认行为是当应用处于后台时暂停发送 HTTP 请求。您可以在 `AdjustConfig` 实例中更改此设置：

```objc
[adjustConfig setSendInBackground:YES];
```

如果不做任何设置，后台发送为**默认禁用**。

### <a id="device-ids"></a>设备 ID

Adjust SDK 支持您获取一些设备 ID。

### <a id="di-idfa"></a>iOS 广告 ID

某些服务 (如 Google Analytics) 要求您协调设备及客户 ID 以避免重复报告。

请调用 `idfa` 以获取设备ID IDFA：

```objc
NSString *idfa = [Adjust idfa];
```

### <a id="adid"></a>Adjust 设备 ID

Adjust 后台将为每一台安装了您应用的设备生成一个唯一的 **Adjust 设备 ID** (**adid**)。您可以在 `Adjust` 示例上调用下列方法，获得该 ID：

```objc
NSString *adid = [Adjust adid];
```

**请注意：**只有在 Adjust 后台跟踪到应用安装后，您才能获取 **adid** 的相关信息。跟踪到应用安装后，Adjust SDK 将拥有设备 **adid** 的信息，您可以使用此方法来访问此信息。因此，在 SDK 初始化以及您的应用安装被成功跟踪之前，您将**无法**访问 **adid**。

### <a id="user-attribution"></a>用户归因

归因回传通过[归因回传章节](#attribution-callback)所描述的方法被触发，以向您提供关于用户归因值的任何更改信息。如果您想要在任何其他时间访问用户当前归因值的信息，您可以通过对 `Adjust` 实例调用如下方法来实现：

```objc
ADJAttribution *attribution = [Adjust attribution];
```

**请注意**：只有在 Adjust 后台跟踪到应用安装和归因回传被初始触发后，您才能获取关于当前归因的信息。自此之后，Adjust SDK 已经拥有关于用户归因的信息，您可以使用此方法来访问它。因此，在 SDK 被初始化以及归因回传被初始触发之前，您将**无法**访问用户归因值。

### <a id="push-token"></a>推送标签 (push token)

推送标签用于受众分群工具和客户回传，是跟踪卸载和重装所需的信息。

请添加以下调用到应用委托 `didRegisterForRemoteNotificationsWithDeviceToken` 中的 `Adjust`，发送推送标签给我们：

```objc
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Adjust setDeviceToken:deviceToken];
}
```

### <a id="pre-installed-trackers"></a>预安装跟踪码

如果您希望使用 Adjust SDK 来识别已在其设备中预安装您的应用的用户，请执行以下步骤。

1. 在 [控制面板] 中创建新的跟踪码。
2. 打开您的应用委托，并在 `ADJConfig`: 中设置默认跟踪码：

  ```objc
  ADJConfig*adjustConfig = [ADJConfig configWithAppToken:yourAppToken environment:environment];
  [adjustConfig setDefaultTracker:@"{TrackerToken}"];
  [Adjust appDidLaunch:adjustConfig];
  ```

  用您在步骤 2 中创建的跟踪码替换 `{TrackerToken}`。请注意，控制面板中显示的是跟踪
  链接 (包含 `http://app.adjust.com/`)。在您的源代码中，您应该仅指定六个字符的识别码，而不是
  整个 URL。

3. 创建并运行应用。您应该可以看到如下的一行 Xcode：

    ```
    默认跟踪码：'abc123'
    ```

### <a id="deeplinking"></a>深度链接

如果您正在使用可从 URL 深度链接至您的应用的 Adjust 跟踪链接，您将可以获取深度链接 URL 及其内容的相关信息。点击 URL 的情况发生在用户已经安装了您的应用 (标准深度链接场景)，或用户尚未在其设备上安装您的应用 (延迟深层链接场景)。Adjust SDK 支持此两种场景，在两种场景下，一旦用户点击跟踪链接启动您的应用之后，深度链接 URL 都将被提供给您。您必须正确设置，以便在应用中使用此功能。

### <a id="deeplinking-standard"></a>标准深度链接场景

如果用户已经安装了您的应用，并点击了带有深度链接信息的跟踪链接，您的应用将被打开，深度链接的内容将被发送至应用，这样您就可以解析它们并决定下一步动作。自 iOS 9 推出后，Apple 已经改变了在应用程序中处理深度链接的方式。取决于您希望在应用中使用哪种场景 (或者您希望同时使用两种场景以支持更广泛的设备)，您需要设置应用以处理以下一种或两种场景。

### <a id="deeplinking-setup-old"></a>iOS 8 及以下版本的深度链接设置

iOS 8 及以下版本设备上的深度链接是通过使用自定义 URL 方案设置的。您需要选择一个由您的应用负责开启的自定义 URL 方案名。该方案名也将作为 deep_link (深度链接) 参数的一部分被用于 Adjust 跟踪链接。打开您的 `Info.plist` 文件，添加新的 `URL types` 行，以在您的应用中设置 URL 方案名。在 `URL identifier` 输入您的应用 `bundle ID`，于 `URL schemes` 下添加您希望在应用中处理的方案名称。在以下例子中，我们已经选择应用程序处理以 `adjustExample` 命名的方案。

![][custom-url-scheme]

该设置完成之后，一旦点击包含自定义方案名的 `deep_link` 参数的 Adjust 跟踪链接， 您的应用将被打开。应用打开后，您的 `AppDelegate` 中的 `openURL` 方法将被触发，来自跟踪链接的 `deep_link` 参数内容来源将被发送。如果您希望访问该深度链接内容，请改写此方法。

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    // url object contains your deep link content

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}
```

通过以上设置，您已经成功为 iOS 8 及以下版本的 iOS 设备设置深度链接。

### <a id="deeplinking-setup-new"></a>iOS 9 及以上版本的深度链接设置

为 iOS 9 及以上版本设备设置深度链接，您需要启用您的应用处理 Apple 通用链接的功能。查看[这里][universal-links]，了解更多关于通用链接及其设置的相关信息。

Adjust 在后台负责处理与通用链接相关的大部分工作。但是，为了让 Adjust 支持通用链接，您需要在 Adjust 控制面板中为通用链接做一些小的设置。请查看我们的[官方文档][universal-links-guide]以了解设置信息。

一旦在控制面板中成功启用通用链接功能，您还需要在应用中作如下设置：

在 Apple Developer Portal 上为您的应用启用 `Associated Domains` 后，您需要为应用的 Xcode 项目作同样设置。启用 `Assciated Domains` 后，通过前缀 `applinks:` 的方式添加从 Adjust 控制面板中 `Domains` 部分生成的通用链接，并确保您同时也删除了通用链接的 `http(s)` 部分。

![][associated-domains-applinks]

完成该设置后，一旦点击 Adjust 跟踪通用链接，您的应用将被打开。应用打开后，您的 `AppDelegate` 中的 `continueUserActivity` 方法将被触发，来自通用链接 URL 的内容来源将被发送。如果您希望访问该深度链接内容，请改写此方法。

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

通过以上设置，您已经成功为 iOS 9 及以上版本的 iOS 设备设置深度链接。

如果在您的代码中包含某些自定义逻辑，其仅接受旧式自定义 URL 方案名格式的深度链接信息，我们为您提供一个辅助函数，可以让您将通用链接转化为旧式的深度链接 URL。您可以使用通用链接以及您希望的深度链接前缀自定义 URL 方案名来调用该方法，我们将为您生成自定义 URL 方案深度链接：

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

### <a id="deeplinking-deferred"></a>延迟深度链接场景

您可以注册一个委托回传，以在延迟深度链接被打开之前获取通知，并决定是否由 Adjust SDK 尝试打开该链接。其所使用的是和[归因回传](#attribution-callback)及[事件及会话回传](#event-session-callbacks)同样的可选协议 `AdjustDelegate`。

按照同样步骤，为延迟深度链接执行以下委托回传函数：

```objc
- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    // deeplink object contains information about deferred deep link content

    // Apply your logic to determine whether the Adjust SDK should try to open the deep link
    return YES;
    // or
    // return NO;
}
```

在 SDK 从我们的服务器中接收延迟深度链接之后，回传函数将在打开该链接之前被调用。您可以在回传功能中访问该深度链接。返回的布尔值将决定是否由 SDK 打开该深度链接。您可以在此时不允许 SDK 打开该深度链接，将其保存，并在此之后由您自己打开。

如果不执行回传，**Adjust SDK 将始终默认尝试打开深度链接**。

### <a id="deeplinking-reattribution"></a>通过深度链接的再归因

Adjust 支持您使用深度链接进行交互推广活动。请查看我们的[官方文档][reattribution-with-deeplinks]了解更多相关操作信息。

如果您正在使用该功能，您需要在应用中对 Adjust SDK 做一个额外的调用，以便用户被正确地再归因。

一旦您已经在应用中接收到深度链接内容信息，添加一个至 `appWillOpenUrl` 方法的调用。通过该调用，Adjust SDK 将会尝试在深度链接内寻找是否有任何新的归因信息，一旦找到，该信息将被发送至 Adjust 后台。如果您的用户因为点击带有深度链接内容的 Adjust 跟踪链接，而应该被再归因，您将会在应用中看到[归因回传](#attribution-callback)被该用户新的归因信息触发。

在所有的 iOS 版本中，请参照如下调用 `appWillOpenUrl` 以设置深度链接再归因：

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

### <a id="data-residency"></a>[beta] 数据驻留

要启用数据驻留功能，请务必通过以下常量之一调用`ADJConfig` 实例中的 `setUrlStrategy:` 方法 ：

```objc
[adjustConfig setUrlStrategy:ADJDataResidencyEU]; // for EU data residency region
[adjustConfig setUrlStrategy:ADJDataResidencyTR]; // for Turkey data residency region
```

**注意:** 该功能当前尚处于 BETA 测试阶段。如果您希望启用该功能，请联系您的客户经理，或发送邮件至 support@adjust.com。为避免 SDK 流量丢失，请务必在启用该功能设置前联系我们的支持团队，保证该功能已为您的应用启用。

## <a id="troubleshooting"></a>问题排查

### <a id="ts-delayed-init"></a>SDK 延迟初始化问题

如在[基本设置步骤](#basic-setup)中所描述的那样，我们强烈建议您在应用委托中以 `didFinishLaunching` 或者 `didFinishLaunchingWithOptions` 方法初始化 Adjust SDK。为了能够使用 SDK 的所有功能，您必须尽快地初始化 Adjust SDK。

不立即初始化 Adjust SDK 将会对应用跟踪产生多种影响。**为了在您的应用中执行所有的跟踪，Adjust SDK *一定*要被初始化。**

如果您决定执行以下任一操作：

* [事件跟踪](#event-tracking)
* [通过深度链接的再归因](#deeplinking-reattribution)
* [禁用跟踪](#disable-tracking)
* [离线模式](#offline-mode)

在您初始化 SDK 之前，`这些操作不会被执行`。

如果您希望在 Adjust SDK 被真正初始化之前跟踪以上任一操作，则必须在应用中创建 `custom actions queueing mechanism` (自定义操作队列机制)。您需要将所有希望 SDK 执行的操作排成队列，在 SDK 被初始化之后执行它们。

离线模式状态不会被改变，跟踪启用/禁用状态不会被改变，深度链接再归因无法执行，所有跟踪事件将被`dropped` (丢弃)。

另一个可能会被 SDK 延迟初始化影响的是会话跟踪。Adjust SDK 在被初始化之前，不能收集任何会话长度的信息。您控制面板中的 DAU 数量将无法被正确跟踪。

举例来说，让我们假设这个场景：您正在初始化 Adjust SDK，要求一些特定的视图或视图控制器（view controller) 被加载。假设这不是您的应用初始启动或第一个屏幕，但是用户必须从主屏幕中导航至它们。如果用户下载并打开您的应用，主屏幕将被显示。正常情况下此时该安装应该被跟踪。然而，因为用户需要导航至之前提到的您初始化 Adjust SDK 的屏幕，所以 Adjust SDK 无法获取任何相关信息。此外，如果用户不喜欢该应用，并在看到主屏幕之后立即卸载该应用，以上提到的所有信息将不会被我们的 SDK 跟踪，也不会被显示在控制面板中。

### 事件跟踪

对于要跟踪的事件，请使用内部队列机制将其排列，并在 SDK 初始化之后跟踪它们。在初始化 SDK 之前跟踪事件将会造成事件被`dropped` (丢弃) 且 `permanently lost` (永久丢失)，所以请确认您在 SDK 被 `initialised` (初始化) 并 [`enabled`](#is-enabled) (启用) 之后跟踪它们。

#### 离线模式和启用/禁用跟踪

离线模式功能在 SDK 初始化之间无法保留，所以它被默认设置为 `false`。如果您尝试在 SDK 初始化之前启用离线模式，当 SDK 最终被初始化之后，将仍然被设置为 `false`。

启用/禁用跟踪状态在 SDK 初始化之间保持不变。如果您尝试在 SDK 初始化之前切换它们，切换尝试将被忽略。当 SDK 被初始化之后，SDK 将处于切换尝试之前的 (启用或禁用) 状态。

#### 通过深度链接的再归因

如[之前](#deeplinking-reattribution)所描述的，当处理深度链接再归因时，取决于您正在使用的深度链接机制 (旧式或通用链接)，在进行以下调用后您将获得 `NSURL` 对象：

```objc
[Adjust appWillOpenUrl:url]
```

如果您在 SDK 被初始化之前进行此调用，来自深度链接的归因信息将会永久丢失。如果您希望 Adjust SDK 成功再归因用户，则需要在 SDK 被初始化之后，队列 `NSURL` 对象信息，并触发 `appWillOpenUrl` 方法。

#### 会话跟踪

会话跟踪将由 Adjust SDK 自动执行，不受应用开发者的影响。按照本自述文件说明初始化 Adjust SDK 对于会话跟踪是至关重要的，否则将对会话跟踪以及控制面板的 DAU 数量产生不可预测的影响。

例如：
* 用户打开应用，但在 SDK 初始化之前删除应用，导致安装和会话从未被跟踪，因此也不会在控制面板中被报告。
* 如果用户在午夜前下载并打开您的应用，然而 Adjust SDK 在午夜后被初始化，则所有的安装和会话数据将在错误日期被报告。
* 如果用户在午夜之后短暂打开了应用，但是没有在同一天使用应用，Adjust SDK 于午夜后被初始化，那没 DAU 的报告日期也将不是应用打开的那一天。

由于以上原因，请按照本文档的说明，在您的应用委托 `didFinishLaunching` 或 `didFinishLaunchingWithOptions` 方法中初始化 Adjust SDK。

### <a id="ts-arc"></a>显示 "adjust requires ARC" 出错信息

如果您的构建失败，错误为 `Adjust requires ARC`，可能是因为您的项目没有使用 ARC。在这种情况下，我们建议[过渡您的项目至 ARC][transition]。如果您不想使用 ARC，则必须在目标的 Build Phase 中，对 Adjust 的所有源文件启用 ARC：

展开 `Compile Sources` 组，选择所有 Adjust 文件并将 `Compiler Flags` 改为 `-fobjc-arc` (选择全部并按下 `Return` 键立即全部更改)。

### <a id="ts-categories"></a>显示 "[UIDevice adjTrackingEnabled]: unrecognized selector sent to instance" 出错信息

当添加 Adjust SDK 框架至您的应用时可能发生该错误。Adjust SDK 源文件包含 `categories`，因此如果您已经选择此种 SDK 集成方式，则需要添加 `-ObjC` flags 至 Xcode 项目设置中 `Other Linker Flags`。添加该 flag 可以解决此错误。

### <a id="ts-session-failed"></a>显示 "Session failed (Ignoring too frequent session.)"出错信息

该错误一般发生在安装测试时。单凭卸载和重装应用不足以触发新安装。由于我们服务器已经有该设备的纪录，服务器会认定该设备的 SDK 丢失了本地聚合的会话数据，并忽略该错误信息。

这种行为在测试期间可能很麻烦，但为了尽可能地让沙箱（sandbox) 行为与生产 (production) 情况匹配，该行为是非常必要的。

您可以在我们的服务器上重置设备会话数据。请查看日志中的错误信息：

```
Session failed (Ignoring too frequent session.Last session: YYYY-MM-DDTHH:mm:ss, this session: YYYY-MM-DDTHH:mm:ss, interval: XXs, min interval: 20m) (app_token: {yourAppToken}, adid: {adidValue})
```

<a id="forget-device">With the `{yourAppToken}` and  either `{adidValue}` or `{idfaValue}` values filled in below, open one of the following links:

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&adid={adidValue}
```

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&idfa={idfaValue}
```

当设备被忘记，链接仅返回 `Forgot device`。如果设备之前已经被忘记或出现错误值，链接将返回 `Device not found`。

### <a id="ts-install-tracked"></a>日志未显示 "Install tracked"

如果您希望在测试设备上模拟应用的安装场景，仅仅在您的测试设备上重新运行 Xcode 开发的应用是不够的。重新运行 Xcode 开发的应用不会清除应用数据，SDK 保存在您的应用中的所有内部数据仍然会存在。因此在重新运行时，我们的 SDK 将会看到这些文件并认为您的应用已被安装 (SDK 已被启用)，应用只是又一次被打开，而不是第一次。

为了运行应用安装场景，您需要进行以下步骤：

* 从您的设备中卸载应用 (完全删除应用)
*如[之前](#forgot-device)所解释的，在 Adjust 后台忘记您的测试设备
* 在测试设备上运行 Xcode 开发的应用，您将会看到日志信息 "Install tracked"

### <a id="ts-iad-sdk-click"></a>显示 "Unattributable SDK click ignored" 信息

当您在 `sandbox` 环境中测试您的应用时，可能会看到该信息。这与 `iAd.framework` 版本 3 中 Apple 作出的一些更改有关。因此，点击 iAd banner 的用户将被定向至您的应用，导致我们的 SDK 发送一个 `sdk_click` 包至 Adjust 后台并通知后台被点击 URL 的内容。由于某些原因，Apple 决定如果应用在没有点击 iAD banner 的情况下被打开，将人工生成一个带有随机值的 iAd banner URL 点击。我们的 SDK 无法区分 iAd banner 点击是真实或者人工生成的，所以无论在何种情况下都会发送一个 `sdk_click` 包至 Adjust 后台。如果您已将日志级别设置为 `verbose` 级别，您将看到如下 `sdk_click` 包：

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

如果由于某种原因，该 `sdk_click` 被接受，这表示通过点击其他推广链接或者自然搜索打开您的应用的用户，被归因到这个不存在的 iAd 来源。因此，我们的后台将忽略该点击，并显示以下信息：

```
[Adjust]v: Response: {"message":"Unattributable SDK click ignored."}
[Adjust]i: Unattributable SDK click ignored.
```

所以，该错误信息并不代表您的 SDK 集成出现问题，而仅是告知您我们的后台忽略了这个人工生成的 `sdk_click`，避免您的用户被错误地归因/再归因。

### <a id="ts-wrong-revenue-amount"></a>Adjust 控制面板显示错误收入金额

Adjust SDK 仅跟踪您要求它跟踪的内容。如果您添加收入至事件，您所输入的金额是唯一到达 Adjust 后台并显示在控制面板中的金额。我们的 SDK 和后台都不会更改您的金额。如果您看到错误的金额被跟踪，那是因为我们的 SDK 被告知跟踪该金额。

通常，跟踪收入事件的用户代码如下：

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

如果您在控制面板中看到任何您不期望被跟踪的值，**请务必检查您决定量值的逻辑**。

[dashboard]:   http://adjust.com
[adjust.com]:  http://adjust.com

[en-readme]:  ../../README.md
[zh-readme]:  ../chinese/README.md
[ja-readme]:  ../japanese/README.md
[ko-readme]:  ../korean/README.md

[sdk2sdk-mopub]:  ../chinese/sdk-to-sdk/mopub.md

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
[event-tracking]:    https://docs.adjust.com/zh/event-tracking
[callbacks-guide]:   https://docs.adjust.com/zh/callbacks
[universal-links]:   https://developer.apple.com/library/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html
[special-partners]:     https://docs.adjust.com/zh/special-partners
[attribution-data]:     https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[ios-web-views-guide]:  https://github.com/adjust/ios_sdk/tree/master/doc/chinese
[currency-conversion]:  https://docs.adjust.com/zh/event-tracking/#tracking-purchases-in-different-currencies

[universal-links-guide]:      https://docs.adjust.com/zh/universal-links/
[adjust-universal-links]:     https://docs.adjust.com/zh/universal-links/#redirecting-to-universal-links-directly
[universal-links-testing]:    https://docs.adjust.com/zh/universal-links/#testing-universal-link-implementations
[reattribution-deeplinks]:    https://docs.adjust.com/zh/deeplinking/#manually-appending-attribution-data-to-a-deep-link
[ios-purchase-verification]:  https://github.com/adjust/ios_purchase_sdk

[reattribution-with-deeplinks]:   https://docs.adjust.com/zh/deeplinking/#manually-appending-attribution-data-to-a-deep-link

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

## <a id="license"></a>License

The Adjust SDK is licensed under the MIT License.

Copyright (c) 2012-2019 Adjust GmbH, http://www.adjust.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
