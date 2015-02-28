## Criteo plugin

Integrate adjust with Criteo events by following these steps:

1. Locate the `plugin` folder inside the downloaded archive from our [releases page](https://github.com/adjust/ios_sdk/releases).

2. Drag the `ADJCriteo.h` and `ADJCriteo.m` files into the `Adjust` folder inside your project.

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

[ADJCriteo injectViewSearchIntoEvent:event checkInDate:@"2015-01-01" checkOutDate:@"2015-01-07"]

[Adjust trackEvent:event];
```

### View Listing

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewListingEventToken}"];

CriteoProduct *product1 = [CriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
CriteoProduct *product2 = [CriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
CriteoProduct *product3 = [CriteoProduct productWithId:@"productId3" price:50 quantity:2];

NSArray *products = @[product1, product2, product3];

[ADJCriteo injectViewListingIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```

### View Product

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{viewProductEventToken}"];

[ADJCriteo injectViewProductIntoEvent:event productId:@"productId1" customerId:@"customerId1"];

[Adjust trackEvent:event];
```

### Cart

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{cartEventToken}"];

CriteoProduct *product1 = [CriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
CriteoProduct *product2 = [CriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
CriteoProduct *product3 = [CriteoProduct productWithId:@"productId3" price:50 quantity:2];

NSArray *products = @[product1, product2, product3];

[ADJCriteo injectCartIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```

### Transaction confirmation

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"{transactionConfirmedEventToken}"];

CriteoProduct *product1 = [CriteoProduct productWithId:@"productId1" price:100.0 quantity:1];
CriteoProduct *product2 = [CriteoProduct productWithId:@"productId2" price:77.7 quantity:3];
CriteoProduct *product3 = [CriteoProduct productWithId:@"productId3" price:50 quantity:2];

NSArray *products = @[product1, product2, product3];

[ADJCriteo injectTransactionConfirmedIntoEvent:event products:products customerId:@"customerId1"];

[Adjust trackEvent:event];
```
