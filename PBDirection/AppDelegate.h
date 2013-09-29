//
//  AppDelegate.h
//  PBDirection
//
//  Created by Guido Naturani on 18/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>
#import <MapKit/MapKit.h>

#import "CalculateTurnByTurn.h"
#import "KBPebbleMessageQueue.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,PBPebbleCentralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PBWatch *_targetWatch;
@property (nonatomic, strong) NSString *_statusWatch;

@property (nonatomic, strong) NSString *_stringDestination;

@property (nonatomic, strong) NSString *_OldInfo;
@property (nonatomic, assign) int _OldDistance;

@property(nonatomic,strong) NSMutableArray *_Steps;
@property(nonatomic,strong) MKRoute *_Route;

@property(nonatomic,strong) MKMapItem *_startLocation;

@property(nonatomic,strong) CalculateTurnByTurn *_TurnByTurn;

@property (nonatomic, strong) KBPebbleMessageQueue *_message_queue;

@end
