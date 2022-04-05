# Track Helium Chartboost ad revenue with Adjust SDK

[Adjust iOS SDK README][ios-readme]

Minimum SDK version required for this feature:

- **Adjust SDK v4.29.7**

If you want to track your ad revenue with the Helium SDK, you can use our SDK-to-SDK integration to pass this information to the Adjust backend. To do this, you will need to construct an Adjust ad revenue object containing the information you wish to record, then pass the object to the `trackAdRevenue` method.

> Note: If you have any questions about ad revenue tracking with Helium Chartboost, please contact your dedicated account manager or send an email to [support@adjust.com](mailto:support@adjust.com).

### Example

```objc
[NSNotificationCenter.defaultCenter addObserverForName:kHeliumDidReceiveILRDNotification
                                                object:nil
                                                 queue:nil
                                            usingBlock:^(NSNotification * _Nonnull notification) {
    // extract the ILRD payload
    HeliumImpressionData *ilrd = (HeliumImpressionData *)notification.object;
    NSDictionary *json = ilrd.jsonData;
    // mandatory fields
    NSNumber *ad_revenue = [json objectForKey:@"ad_revenue"];
    NSString *currency_type = [json objectForKey:@"currency_type"];
    ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceHeliumChartboost];
    [adjustAdRevenue setRevenue:[ad_revenue doubleValue] currency:currency_type];
    // optional fields
    NSString *network_name = [json objectForKey:@"network_name"];     // Helium demand network name
    NSString *placement_name = [json objectForKey:@"placement_name"]; // Helium placement name
    NSString *line_item_name = [json objectForKey:@"line_item_name"]; // Helium line item name
    [adjustAdRevenue setAdRevenueNetwork:network_name];
    [adjustAdRevenue setAdRevenueUnit:placement_name];
    [adjustAdRevenue setAdRevenuePlacement:line_item_name];
    // track Adjust ad revenue
    [Adjust trackAdRevenue:adjustAdRevenue];
}
```

[ios-readme]:    ../../../README.md
