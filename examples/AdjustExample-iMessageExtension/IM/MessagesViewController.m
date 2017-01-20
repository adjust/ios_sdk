//
//  MessagesViewController.m
//  IM
//
//  Created by Pedro on 20/01/2017.
//  Copyright © 2017 adjust. All rights reserved.
//

#import <AdjustSdkIM/Adjust.h>

#import "MessagesViewController.h"

#import "URLRequest.h"
#import "Constants.h"


@interface MessagesViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnTrackSimpleEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackRevenueEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackCallbackEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackPartnerEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnEnableOfflineMode;
@property (weak, nonatomic) IBOutlet UIButton *btnDisableOfflineMode;
@property (weak, nonatomic) IBOutlet UIButton *btnEnableSdk;
@property (weak, nonatomic) IBOutlet UIButton *btnDisableSdk;
@property (weak, nonatomic) IBOutlet UIButton *btnIsSdkEnabled;
@property (weak, nonatomic) IBOutlet UIButton *btnForgetDevice;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        // Configure adjust SDK.
        NSString *yourAppToken = kAppToken;
        NSString *environment = ADJEnvironmentSandbox;
        ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken environment:environment];
        
        // Change the log level.
        [adjustConfig setLogLevel:ADJLogLevelVerbose];
        
        // Enable event buffering.
        // [adjustConfig setEventBufferingEnabled:YES];
        
        // Set default tracker.
        // [adjustConfig setDefaultTracker:@"{TrackerToken}"];
        
        // Send in the background.
        [adjustConfig setSendInBackground:YES];
        
        // Add session callback parameters.
        [Adjust addSessionCallbackParameter:@"sp_foo" value:@"sp_bar"];
        [Adjust addSessionCallbackParameter:@"sp_key" value:@"sp_value"];
        
        // Add session partner parameters.
        [Adjust addSessionPartnerParameter:@"sp_foo" value:@"sp_bar"];
        [Adjust addSessionPartnerParameter:@"sp_key" value:@"sp_value"];
        
        // Remove session callback parameter.
        [Adjust removeSessionCallbackParameter:@"sp_key"];
        
        // Remove session partner parameter.
        [Adjust removeSessionPartnerParameter:@"sp_foo"];
        
        // Remove all session callback parameters.
        // [Adjust resetSessionCallbackParameters];
        
        // Remove all session partner parameters.
        // [Adjust resetSessionPartnerParameters];
        
        // Set an attribution delegate.
        [adjustConfig setDelegate:self];
        
        // Delay the first session of the SDK.
        // [adjustConfig setDelayStart:7];
        
        // Initialise the SDK.
        [Adjust appDidLaunch:adjustConfig];
        // Launch the Sdk
        [Adjust trackSubsessionStart];
        
        // Put the SDK in offline mode.
        // [Adjust setOfflineMode:YES];
        
        // Disable the SDK.
        // [Adjust setEnabled:NO];
        
        // Interrupt delayed start set with setDelayStart: method.
        // [Adjust sendFirstPackages];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Conversation Handling

- (IBAction)clickTrackSimpleEvent:(id)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:kEventToken1];
    
    [Adjust trackEvent:event];
}

- (IBAction)clickTrackRevenueEvent:(id)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:kEventToken2];
    
    // Add revenue 1 cent of an euro.
    [event setRevenue:0.01 currency:@"EUR"];
    
    [Adjust trackEvent:event];
}

- (IBAction)clickTrackCallbackEvent:(id)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:kEventToken3];
    
    // Add callback parameters to this event.
    [event addCallbackParameter:@"a" value:@"b"];
    [event addCallbackParameter:@"key" value:@"value"];
    [event addCallbackParameter:@"a" value:@"c"];
    
    [Adjust trackEvent:event];
}
- (IBAction)clickTrackPartnerEvent:(id)sender {
    ADJEvent *event = [ADJEvent eventWithEventToken:kEventToken4];
    
    // Add partner parameteres to this event.
    [event addPartnerParameter:@"x" value:@"y"];
    [event addPartnerParameter:@"foo" value:@"bar"];
    [event addPartnerParameter:@"x" value:@"z"];
    
    [Adjust trackEvent:event];
}
- (IBAction)clickEnableOfflineMode:(id)sender {
    [Adjust setOfflineMode:YES];
}

- (IBAction)clickDisableOfflineMode:(id)sender {
    [Adjust setOfflineMode:NO];
}

- (IBAction)clickEnableSdk:(id)sender {
    [Adjust setEnabled:YES];
}

- (IBAction)clickDisableSdk:(id)sender {
    [Adjust setEnabled:NO];
}

- (IBAction)clickIsSdkEnabled:(id)sender {
    NSString *message;
    
    if ([Adjust isEnabled]) {
        message = @"SDK is ENABLED!";
    } else {
        message = @"SDK is DISABLED!";
    }
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Is SDK Enabled?"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clickForgetDevice:(id)sender {
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [URLRequest forgetDeviceWithAppToken:kAppToken
                                    idfv:idfv
                         responseHandler:^(NSString *response) {
                             [self responseHandler:response];
                         }];
}

- (void)responseHandler:(NSString *)response {
    NSString *message;
    
    if ([[response lowercaseString] containsString:[@"Forgot device" lowercaseString]]) {
        message = @"Device is forgotten!";
    } else {
        message = @"Device isn't known!";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showResultInMainThread:message];
    });
}

- (void)showResultInMainThread:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Forget device"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    NSLog(@"Attribution callback called!");
    NSLog(@"Attribution: %@", attribution);
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    NSLog(@"Event success callback called!");
    NSLog(@"Event success data: %@", eventSuccessResponseData);
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    NSLog(@"Event failure callback called!");
    NSLog(@"Event failure data: %@", eventFailureResponseData);
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    NSLog(@"Session success callback called!");
    NSLog(@"Session success data: %@", sessionSuccessResponseData);
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    NSLog(@"Session failure callback called!");
    NSLog(@"Session failure data: %@", sessionFailureResponseData);
}

// Evaluate deeplink to be launched.
- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    NSLog(@"Deferred deep link callback called!");
    NSLog(@"Deferred deep link URL: %@", [deeplink absoluteString]);
    
    return YES;
}

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    
    // Use this method to configure the extension and restore previously stored state.
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user taps the send button.
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
}

@end
