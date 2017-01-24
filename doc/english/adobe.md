##Integrate adjust with Adobe SDK

To integrate adjust with all tracked events of Adobe SDK, you must send adjust attribution data to Adobe SDK 
after receiving the attribution response from our backend. Follow the steps of the [listener][listener] chapter 
in our Android SDK guide to implement it. The delegate function can be set as the following, to use the Adobe 
SDK API:

```java
public class YourApplicationClass extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Initialize Adobe SDK
        Config.setContext(this.getApplicationContext());
        Config.setDebugLogging(true);
        
        // Configure Adjust
        String appToken = "{YourAppToken}";
        String environment = AdjustConfig.ENVIRONMENT_SANDBOX;
        AdjustConfig config = new AdjustConfig(this, appToken, environment);

        config.setOnAttributionChangedListener(new OnAttributionChangedListener() {
            @Override
            public void onAttributionChanged(Attribution attribution) {
                Map<String,Object> dataAdjust = new HashMap<String,Object>();
                
                dataAdjust.put("Adjust Network", adjustAttribution.network); // Do not change the key "Adjust Network". This key is being used in the Data Connector Processing Rule
                dataAdjust.put("Adjust Campaign", adjustAttribution.campaign); // Do not change the key "Adjust Campaign". This key is being used in the Data Connector Processing Rule
                dataAdjust.put("Adjust Adgroup", adjustAttribution.adgroup); // Do not change the key "Adjust Adgroup". This key is being used in the Data Connector Processing Rule
                dataAdjust.put("Adjust Creative", adjustAttribution.creative); // Do not change the key "Adjust Creative". This key is being used in the Data Connector Processing Rule

                Analytics.trackAction("Adjust Campaign Data Received",dataAdjust); // Send Data to Adobe using Track Action
            }
        });

        Adjust.onCreate(config);
    }
}
```

Before you implement this interface, please take care to consider 
[possible conditions for usage of some of your data][attribution_data].

[attribution_data]: https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[listener]: https://github.com/adjust/android_sdk/tree/master#13-set-listener-for-delegate-notifications
