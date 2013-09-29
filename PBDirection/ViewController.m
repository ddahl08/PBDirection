//
//  ViewController.m
//  PBDirection
//
//  Created by Guido Naturani on 18/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <PebbleKit/PebbleKit.h>

#import "DirectionsViewController.h"

#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize _destination;
@synthesize _startpoint;
@synthesize _targetWatch;
@synthesize _WaitingAlert;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // TEST
    _destination.text = @"via Giancarlo Rossi Carpaneto Piacentino";
    
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    _targetWatch = theAppDelegate._targetWatch;
    connectedLabel.text = theAppDelegate._statusWatch;

}

-(IBAction)calculateInstructions:(id)sender{
    
    _WaitingAlert = [[UIAlertView alloc] initWithTitle:@"Routing in progress\nPlease Wait..."
                                        message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(_WaitingAlert.bounds.size.width / 2, _WaitingAlert.bounds.size.height - 50);
    [indicator startAnimating];
    [_WaitingAlert addSubview:indicator];
    [_WaitingAlert show];
    
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    theAppDelegate._stringDestination = _destination.text;
     theAppDelegate._startLocation = [MKMapItem mapItemForCurrentLocation];
    
    theAppDelegate._TurnByTurn._Delegate = self;
    [theAppDelegate._TurnByTurn calculate];
}

-(IBAction)installWatchApp:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/14227079/follow_me.pbw"]];
    
}

-(void)updateEnd:(BOOL)iSuccess :(NSString *) iMessage{
    
    [_WaitingAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (iSuccess == NO){
        
        [[[UIAlertView alloc] initWithTitle:nil message:iMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
        
        DirectionsViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectionsViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detail];
        
        [detail updateDataFromApp];
        
        [self presentViewController:nav animated:YES completion:nil];

}


-(IBAction)calculateInstructions_OLD:(id)sender{
    
    __block NSString *message = @"";
    void (^showAlert)(void) = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    };
    
    NSNumber *infoTextKey = @(0);
    NSDictionary *update = @{ infoTextKey:@"Waiting for Route"};
    
    [_targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        message = error ? [error localizedDescription] : @"Update sent!";
        //showAlert();
    }];
    
    if ([_destination.text isEqualToString:@""]){
        return;
    }
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:_destination.text
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                     // Convert the CLPlacemark to an MKPlacemark
                     // Note: There's no error checking for a failed geocode
                     CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                     MKPlacemark *placemark = [[MKPlacemark alloc]
                                               initWithCoordinate:geocodedPlacemark.location.coordinate
                                               addressDictionary:geocodedPlacemark.addressDictionary];
                     
                     // Create a map item for the geocoded address to pass to Maps app
                     MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                     [mapItem setName:geocodedPlacemark.name];
                     
                     // Set the directions mode to "Driving"
                     // Can use MKLaunchOptionsDirectionsModeWalking instead
                     NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                     
                     // Get the "Current User Location" MKMapItem
                     MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                     
                     // Pass the current location and destination map items to the Maps app
                     // Set the direction mode in the launchOptions dictionary
                     //[MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                     
                     MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
                     [request setSource:currentLocationMapItem];
                     [request setDestination:mapItem];
                     
                     MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
                     
                     [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                         NSLog(@"%@",[response description]);
                         
                         NSMutableArray *iStringSteps = [[NSMutableArray alloc] initWithCapacity:0];
                         
                         NSMutableArray *iMkSteps = [[NSMutableArray alloc] initWithCapacity:0];
                         
                         DirectionsViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectionsViewController"];
                         
                         
                         if (response != nil){
                             
                             for (MKRoute *actRoute in response.routes) {
                                 NSLog(@"Distance: %f",actRoute.distance);
                                 
                                 detail._Route = actRoute;
                                 
                                 for (MKRouteStep *actStep in actRoute.steps) {
                                     NSLog(@"Istruzione: %@",actStep.instructions);
                                     NSLog(@"Descrizione: %@",actStep.description);
                                     NSLog(@"Distanza: %f",actStep.distance);
                                     
                                     [iStringSteps addObject:actStep.instructions];
                                     [iMkSteps addObject:actStep];
                                 }
                                 
                                 
                             }
                         } else {
                             [iStringSteps addObject:[error description]];
                         }
                         
                         NSLog(@"%@",[error description]);
                         
                         detail._StringSteps = iStringSteps;
                         detail._Steps = iMkSteps;
                         
                         UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detail];
                         
                         MKRouteStep *firstStep =[iMkSteps objectAtIndex:1];
                         
                         NSString *stepDes = [[NSString alloc] initWithFormat:@"%f",firstStep.distance];
                         
                         NSNumber *infoTextKey = @(0);
                         NSDictionary *update = @{ infoTextKey:stepDes};

                         [_targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
                             message = error ? [error localizedDescription] : @"Update sent!";
                             showAlert();
                         }];
                         
                         [self presentViewController:nav animated:YES completion:nil];
                                                  
                     }];
                     
                     
                 }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
