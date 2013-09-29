//
//  DirectionsViewController.h
//  PBDirection
//
//  Created by Guido Naturani on 18/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import "CalculateTurnByTurn.h"

@interface DirectionsViewController : UITableViewController <UpdateCompleteDelegate, CLLocationManagerDelegate>{
    

    
}

@property(nonatomic,strong) IBOutlet UILabel *_lbMessage;

@property(nonatomic,strong) NSMutableArray *_StringSteps;
@property(nonatomic,strong) NSMutableArray *_Steps;
@property(nonatomic,strong) MKRoute *_Route;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;

@property (nonatomic,strong) UIAlertView *_WaitingAlert;

@property(nonatomic,assign) BOOL _Updating;

-(void)updateEnd:(BOOL)iSuccess :(NSString *) iMessage;

-(void)updateDataFromApp;

@end
