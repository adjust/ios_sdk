# Adjust SDK에서 AdMob 광고 매출 트래킹

[Adjust iOS SDK README][ios-readme]

이 기능에 필요한 최소 SDK 버전:

- **Adjust SDK v4.29.0**

Admob SDK의 광고 매출을 트래킹하고 싶다면, Adjust의 SDK 연동을 사용하여 Adjust 백엔드로 광고 매출 정보를 전송할 수 있습니다. 이를 위해서는 기록하고자 하는 정보를 포함한 Adjust 광고 매출 객체를 구성한 뒤, `trackAdRevenue` 메서드를 사용하여 객체를 전송해야 합니다.

> 참고: AdMob과의 광고 매출 트래킹에 관한 문의 사항은 담당 어카운트 매니저나 [support@adjust.com](mailto:support@adjust.com)으로 연락주시기 바랍니다.

### 예시

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
[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/korean/README.md
