## Criteo plugin

Integrate adjust with Criteo events by following these steps:

1. Locate the `plugin` folder inside the downloaded archive from our [releases page](https://github.com/adjust/ios_sdk/releases).

2. Drag the `AdjustCriteo.h` and `AdjustCriteo.m` files into the `Adjust` folder inside your project.

3. In the dialog `Choose options for adding these files` make sure to check the checkbox
to `Copy items if needed` and select the radio button to `Create groups`.

Now you can integrate each of the different Criteo events, like in the following examples:

### View Homepage

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewHomepageEventToken}"];

[Adjust trackEvent:event];
```

### View Search

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewSearchEventToken}"];

[AdjustCriteo injectViewSearchIntoEvent:event checkInDate:@"2015-01-01" checkOutDate:@"2015-01-07"]

[Adjust trackEvent:event];
```

### View Listing

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewListingEventToken}"];

CriteoProduct *product1 = [CriteoProduct productWithPrice:100.0 andQuantity:1 andProductId:@"productId1"];
CriteoProduct *product2 = [CriteoProduct productWithPrice:77.7 andQuantity:3 andProductId:@"productId2"];
CriteoProduct *product3 = [CriteoProduct productWithPrice:50 andQuantity:2 andProductId:@"productId3"];

NSArray *products = @[product1, product2, product3];

[AdjustCriteo injectViewListingIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```

### View Product

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewProductEventToken}"];

[AdjustCriteo injectViewProductIntoEvent:event productId:@"productId1" customerId:@"customerId1"];

[Adjust trackEvent:event];
```

### Cart

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{cartEventToken}"];

CriteoProduct *product1 = [CriteoProduct productWithPrice:100.0 andQuantity:1 andProductId:@"productId1"];
CriteoProduct *product2 = [CriteoProduct productWithPrice:77.7 andQuantity:3 andProductId:@"productId2"];
CriteoProduct *product3 = [CriteoProduct productWithPrice:50 andQuantity:2 andProductId:@"productId3"];

NSArray *products = @[product1, product2, product3];

[AdjustCriteo injectCartIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```

### Transaction confirmation

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{transactionConfirmedEventToken}"];

CriteoProduct *product1 = [CriteoProduct productWithPrice:100.0 andQuantity:1 andProductId:@"productId1"];
CriteoProduct *product2 = [CriteoProduct productWithPrice:77.7 andQuantity:3 andProductId:@"productId2"];
CriteoProduct *product3 = [CriteoProduct productWithPrice:50 andQuantity:2 andProductId:@"productId3"];

NSArray *products = @[product1, product2, product3];

[AdjustCriteo injectTransactionConfirmedIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```
