# AdMobの広告収益をAdjust SDKで計測

[Adjust iOS SDK README][ios-readme]

この機能に必須のSDKバージョン：

- **Adjust SDK v4.29.0**

Admob SDKで広告収益を計測する場合は、AdjustのSDK間連携の機能を使用することで、この情報をAdjustバックエンドに渡すことができます。これを行うには、記録する情報を含むAdjust広告収益オブジェクトを作成し、そのオブジェクトを`trackAdRevenue`メソッドに渡す必要があります。

> 注：Admobによる広告収益計測についてご質問がありましたら、担当のアカウントマネージャー、または[support@adjust.com](mailto:support@adjust.com)までお問い合わせください。

### サンプル

```objc
- (void)requestRewardedAd {
    self.rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:@"ad unit ID"];
    ViewController *strongSelf = weakSelf;
    self.rewardedAd.paidEventHandler = ^void(GADAdValue *_Nonnull value) {
        // ...
        // send ad revenue info to Adjust
        ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceAdMob];
        [adRevenue setRevenue:value.value currency:value.currencyCode];
        [Adjust trackAdRevenue:adRevenue];
    }
};
```

[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/japanese/README.md
