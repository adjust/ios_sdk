# 通过 Adjust SDK 跟踪 AdMob 广告收入

[Adjust iOS SDK 自述文件][ios-readme]

此功能最低 SDK 版本要求：

- **Adjust SDK v4.29.0**

如果您想使用 AdMob SDK 跟踪广告收入，可以借助我们的 SDK 到 SDK 集成，将数据发送到 Adjust 后端。要做到这一点，您需要构建 Adjust 广告收入对象，其中包含想记录的信息，然后将对象发送到 `trackAdRevenue` 方法。

> 请注意：如果您对 AdMob 广告收入跟踪有任何疑问，请联系您的专属客户经理，或发送邮件至 [support@adjust.com](mailto:support@adjust.com)。

### 示例

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

[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/chinese/README.md
