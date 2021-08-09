# AppLovin MAXの広告収益をAdjust SDKで計測

[Adjust iOS SDK README][ios-readme]

この機能に必須のSDKバージョン：

- **Adjust SDK v4.29.0**

AppLovin MAX SDKで広告収益を計測する場合は、AdjustのSDK間連携の機能を使用することで、この情報をAdjustバックエンドに渡すことができます。これを行うには、記録する情報を含むAdjust広告収益オブジェクトを作成し、そのオブジェクトを`trackAdRevenue`メソッドに渡す必要があります。

> 注：AppLovin MAXによる広告収益計測についてご質問がありましたら、担当のアカウントマネージャー、または[support@adjust.com](mailto:support@adjust.com)までお問い合わせください。

### サンプル

```objc
- (void)didPayRevenueForAd:(MAAd *)ad {
    ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceAppLovinMAX];

    adjustAdRevenue.setRevenue(ad.revenue,"USD");
    adjustAdRevenue.setAdRevenueNetwork(ad.networkName);
    adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier);
    adjustAdRevenue.setAdRevenuePlacement(ad.placement);
    
    Adjust.trackAdRevenue(adjustAdRevenue);
}
```

[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/japanese/README.md
