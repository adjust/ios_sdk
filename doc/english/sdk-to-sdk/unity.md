# Track Unity ad revenue with Adjust SDK

[Adjust iOS SDK README][ios-readme]

Minimum SDK version required for this feature:

- **Adjust SDK v4.29.7**

If you want to track your ad revenue with the Unity SDK, you can use our SDK-to-SDK integration to pass this information to the Adjust backend. To do this, you will need to construct an Adjust ad revenue object containing the information you wish to record, then pass the object to the `trackAdRevenue` method.

> Note: If you have any questions about ad revenue tracking with Unity, please contact your dedicated account manager or send an email to [support@adjust.com](mailto:support@adjust.com).

For more information, see the Unity Mediation [API documentation](https://docs.unity.com/mediation/APIReferenceIOS.html) and [impression event documentation](https://docs.unity.com/mediation/SDKIntegrationIOSImpressionEvents.html).

### Example

```objc
@interface ViewController()

@property(nonatomic, strong) UMSImpressionListenerWithBlocks * listener;

@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.listener = [[UMSImpressionListenerWithBlocks alloc] init];
    self.listener.onImpressionBlock = ^ (NSString *adUnitId, UMSImpressionData *impressionData) {
        if (impressionData) {
            NSLog(@ "impressionData: %@", [impressionData getJsonRepresentation]);
            // send impression data to Adjust
            ADJAdRevenue *adjustAdRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceUnity];
            adjustAdRevenue.setRevenue([impressionData.revenue doubleValue], impressionData.currency);
            // optional fields
            adjustAdRevenue.setAdRevenueNetwork(impressionData.adSourceName);
            adjustAdRevenue.setAdRevenueUnit(impressionData.adUnitId);
            adjustAdRevenue.setAdRevenuePlacement(impressionData.adSourceInstance);
            // track Adjust ad revenue
            Adjust.trackAdRevenue(adjustAdRevenue);
        } else {
            NSLog(@ "Data does not exist due to not enabling User-Level Reporting");
        }
    };
    [UMSImpressionEventPublisher subscribe: self.listener];
}

@end
```

[ios-readme]:    ../../../README.md
