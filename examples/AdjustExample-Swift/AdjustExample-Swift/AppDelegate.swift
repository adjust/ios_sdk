//
//  AppDelegate.swift
//  AdjustExample-Swift
//
//  Created by Uglješa Erceg on 06/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let appToken = "2fm9gkqubvpc"
        let environment: Environment = .sandbox

        let adjustConfig = Config(appToken: appToken, environment: environment)

        // change the log level
        adjustConfig.logLevel = .verbose

        // Enable event buffering.
        // adjustConfig.eventBufferingEnabled = true

        // Set default tracker.
        // adjustConfig.defaultTracker = "{TrackerToken}"

        // Send in the background.
        // adjustConfig.sendInBackground = true

        // set an attribution delegate
        adjustConfig.delegate = self

        // Initialise the SDK.
        Adjust.appDidLaunch(adjustConfig)

        // Put the SDK in offline mode.
        // Adjust.setOfflineMode(true);
        
        // Disable the SDK
        // Adjust.setEnabled(false);

        return true
    }
}

extension AppDelegate: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: Attribution?) {
        if let attribution = attribution {
            print("adjust attribution %@", attribution)
        }
    }

    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: EventSuccess?) {
        if let data = eventSuccessResponseData {
            print("adjust event success %@", data)
        }
    }

    func adjustEventTrackingFailed(_ eventFailureResponseData: EventFailure?) {
        if let data = eventFailureResponseData {
            print("adjust event failure %@", data)
        }
    }

    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: SessionSuccess?) {
        if let data = sessionSuccessResponseData {
            print("adjust session success %@", data)
        }
    }

    func adjustSessionTrackingFailed(_ sessionFailureResponseData: SessionFailure?) {
        if let data = sessionFailureResponseData {
            print("adjust session failure %@", data)
        }
    }

    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        return true
    }
}
