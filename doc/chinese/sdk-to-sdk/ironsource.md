# 通过 Adjust SDK 跟踪 ironSource 广告收入

[Adjust iOS SDK 自述文件][ios-readme]

此功能最低 SDK 版本要求：

- **Adjust SDK v4.29.0**

如果您想使用 ironSource SDK 跟踪广告收入，可以借助我们的 SDK-to-SDK 集成，将数据发送到 Adjust 后端。要做到这一点，您需要构建 Adjust 广告收入对象，其中包含想记录的信息，然后将对象发送到 `trackAdRevenue` 方法。

> 请注意：如果您对 ironSource 广告收入跟踪有任何疑问，请联系您的专属客户经理，或发送邮件至 [support@adjust.com](mailto:support@adjust.com)。

### 示例

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

[ios-readme]:    https://github.com/adjust/ios_sdk/blob/master/doc/chinese/README.md
