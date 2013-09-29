//
//  AppDelegate.m
//  PBDirection
//
//  Created by Guido Naturani on 18/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import "AppDelegate.h"
#import <PebbleKit/PebbleKit.h>

#import "KBPebbleMessageQueue.h"

@implementation AppDelegate

@synthesize _targetWatch;
@synthesize _statusWatch;
@synthesize _stringDestination;
@synthesize _Steps;
@synthesize _Route;
@synthesize _TurnByTurn;
@synthesize _message_queue;
@synthesize _startLocation;
@synthesize _OldInfo;

- (void)setTargetWatch:(PBWatch*)watch {
    _targetWatch = watch;
    
    //uint8_t bytes[] = {0x66, 0xc8, 0x6e, 0xa4, 0x1c, 0x3e, 0x4a, 0x07, 0xb8, 0x89, 0x2c, 0xcc, 0xca, 0x91, 0x41, 0x98};
    
    uint8_t bytes[] = { 0x24, 0x70, 0x5D, 0x56, 0x05, 0xB0, 0x4D, 0xB3, 0x9F, 0x6F, 0x09, 0x72, 0x59, 0x52, 0x78, 0x92 };
    
    NSData *uuid = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.
    
    // Test if the Pebble's firmware supports AppMessages:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Configure our communications channel to target the sports app:
            [watch appMessagesSetUUID:uuid];
            
            _statusWatch = [NSString stringWithFormat:@"Yay! %@ supports AppMessages :D", [watch name]];
            //[[[UIAlertView alloc] initWithTitle:@"Connected!" message:_statusWatch delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            _message_queue.watch = watch;
                        
        } else {
            
            _statusWatch = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
            //[[[UIAlertView alloc] initWithTitle:@"Connected..." message:_statusWatch delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Get the "Current User Location" MKMapItem
    _startLocation = [MKMapItem mapItemForCurrentLocation];
    
    _TurnByTurn = [[CalculateTurnByTurn alloc] init];
    _message_queue = [[KBPebbleMessageQueue alloc] init];
    
    _OldInfo = @"";
    
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
    
    return YES;
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
