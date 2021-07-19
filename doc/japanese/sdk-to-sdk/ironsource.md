# ironSourceの広告収益をAdjust SDKで計測

[Adjust iOS SDK README][ios-readme]

この機能に必須のSDKバージョン：

- **Adjust SDK v4.29.0**

ironSource SDKで広告収益を計測する場合は、AdjustのSDK間連携の機能を使用することで、この情報をAdjustバックエンドに渡すことができます。 これを行うには、記録する情報を含むAdjust広告収益オブジェクトを作成し、そのオブジェクトを`trackAdRevenue`メソッドに渡す必要があります。

> 注：ironSourceによる広告収益計測についてご質問がありましたら、担当のアカウントマネージャー、または[support@adjust.com](mailto:support@adjust.com)までお問い合わせください。

### サンプル

```objc
- (void)impressionDataDidSucceed:(ISImpressionData *)impressionData {
    ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceIronSource];
    [adjustAdRevenue setRevenue:impressionData.revenue currency:@"USD"];
    // optional fields
    [adjustAdRevenue setAdRevenueNetwork:impressionData.ad_network];
    [adjustAdRevenue setAdRevenueUnit:impressionData.ad_unit];
    [adjustAdRevenue setAdRevenuePlacement:impressionData.placement];
    // track Adjust ad revenue
    [Adjust trackAdRevenue:adjustAdRevenue];
}
```

[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/japanese/README.md
