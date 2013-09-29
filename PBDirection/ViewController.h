//
//  ViewController.h
//  PBDirection
//
//  Created by Guido Naturani on 18/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

#import "CalculateTurnByTurn.h"

@interface ViewController : UIViewController <UpdateCompleteDelegate>{
    
    IBOutlet UILabel* connectedLabel;
    BOOL shouldBeConnected;
    BOOL couldConnect;
    BOOL isConnected;    
    
}

@property (nonatomic,strong) IBOutlet UITextField *_destination;
@property (nonatomic,strong) IBOutlet UITextField *_startpoint;
@property (nonatomic,strong) PBWatch *_targetWatch;

@property (nonatomic,strong) UIAlertView *_WaitingAlert;

-(IBAction)calculateInstructions:(id)sender;

-(void)updateEnd:(BOOL)iSuccess :(NSString *) iMessage;

- (void)pebbleFound:(PBWatch *)watch ;
- (void)pebbleConnected:(PBWatch *)watch ;
- (void)pebbleDisconnected:(PBWatch *)watch ;
- (void)pebbleLost:(PBWatch *)watch ;

@end
