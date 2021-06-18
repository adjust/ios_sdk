# Track ironSource ad revenue with Adjust SDK

[Adjust iOS SDK README][ios-readme]

Minimum SDK version required for this feature:

- **Adjust SDK v4.29.0**

If you want to track your ad revenue with the ironSource SDK, you can use our SDK-to-SDK integration to pass this information to the Adjust backend. To do this, you will need to construct an Adjust ad revenue object containing the information you wish to record, then pass the object to the `trackAdRevenue` method.

> Note: If you have any questions about ad revenue tracking with ironSource, please contact your dedicated account manager or send an email to [support@adjust.com](mailto:support@adjust.com).

### Example

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

[ios-readme]:    ../../../README.md
