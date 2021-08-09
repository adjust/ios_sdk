# Adjust SDK에서 AppLovin MAX 광고 매출 트래킹

[Adjust iOS SDK README][ios-readme]

이 기능에 필요한 최소 SDK 버전:

- **Adjust SDK v4.29.0**

AppLovin MAX SDK와 광고 매출을 트래킹하고 싶다면, Adjust의 SDK간 연동을 사용하여 Adjust 백엔드로 해당 정보를 전송할 수 있습니다. 이를 위해서는 기록하고자 하는 정보를 포함한 Adjust 광고 매출 객체를 구성한 뒤, `trackAdRevenue` 메서드를 사용하여 객체를 전송해야 합니다.

> 참고: AppLovin MAX와의 광고 매출 트래킹에 관한 문의 사항은 담당 어카운트 매니저나 [support@adjust.com](mailto:support@adjust.com)으로 연락주시기 바랍니다.

### 예시

```objc
- (void)didPayRevenueForAd:(MAAd *)ad {
    ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceAppLovinMAX];

    adjustAdRevenue.setRevenue(ad.revenue, "USD");
    adjustAdRevenue.setAdRevenueNetwork(ad.networkName);
    adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier);
    adjustAdRevenue.setAdRevenuePlacement(ad.placement);
    
    Adjust.trackAdRevenue(adjustAdRevenue);
}
```

[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/korean/README.md
