## Migrate your Adjust web bridge SDK to v4.17.0 or later from v4.9.1 or earlier

### Integration

Before, it was required to manualy drag-and-drop source files into your project to integrate the Adjust web view bridge. One of the main reasons to have to do this, was that we required the Javascript files from Adjust to be used on the view. Now that the Javascript files are injected into the view, it's possible to integrate the Adjust web bridge SDK by using either Cocoapods or Carthage.

Whether you choose to keep the direct source files integration, or use Cocoapods/Carthage, you may remove the Adjust Javascript files you imported previously and their reference from your HTML file(s).

### Adjust config

The Adjust web bridge SDK is now accessing the bridge reference directly by name, so it's no longer necessary to pass
the bridge instance when creating the `AdjustConfig` object. So while previously you would do this:

```js
var adjustConfig = new AdjustConfig(bridge, yourAppToken, environment);
```

Now you should do:

```js
var adjustConfig = new AdjustConfig(yourAppToken, environment);
```

We are still detecting the previous API signature to be compatible, but you should change it when migrating.
