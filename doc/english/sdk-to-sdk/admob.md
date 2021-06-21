# Track AdMob ad revenue with Adjust SDK

[Adjust iOS SDK README][ios-readme]

Minimum SDK version required for this feature:

- **Adjust SDK v4.29.0**

> Note: In order to enable this feature, please reach out to your Google point of contact. Your point of contact will be able to activate the feature for you to access it.
If you want to track your ad revenue with the Admob SDK, you can use our SDK-to-SDK integration to pass this information to the Adjust backend. To do this, you will need to construct an Adjust ad revenue object containing the information you wish to record, then pass the object to the `trackAdRevenue` method.

> Note: If you have any questions about ad revenue tracking with Admob, please contact your dedicated account manager or send an email to [support@adjust.com](mailto:support@adjust.com).
### Example

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

[ios-readme]:    ../../../README.md
