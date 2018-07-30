## Migrate your adjust SDK for iOS to v4.14.0 from v4.9.1

### Integration

Before, it was required to manualy drag-and-drop source files into your project to integrate the adjust web view bridge.
One of the main reasons to have to do this, was that we required the javascript files from adjust to be used on the view.
Now that the javascript files are injected into the view, it's possible to integrate the adjust web view bridge using either
cocoapods or carthage.

Whether you choose to keep the direct source files integration, or use cocoapods/carthage, you may remove the 
adjust javascript files you imported previously and their reference from your html file(s).

### Adjust config

The adjust web view bridge is now accessing the bridge reference directly by name, so it's no longer necessary to pass
the bridge instance when creating the `AdjustConfig` object. So while previously you would do this:

```js
    var adjustConfig = new AdjustConfig(bridge, yourAppToken, environment);
```

Now you should do:

```js
    var adjustConfig = new AdjustConfig(yourAppToken, environment);
```

We are still detecting the previous api signature, to be compatible, but you should change it when migrating.
