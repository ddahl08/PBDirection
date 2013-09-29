//
//  CalculateTurnByTurn.m
//  PBDirection
//
//  Created by Guido Naturani on 19/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import "CalculateTurnByTurn.h"

#import "AppDelegate.h"
#import <PebbleKit/PebbleKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@implementation CalculateTurnByTurn

@synthesize _Delegate;

-(void)calculate{
    
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if ([theAppDelegate._stringDestination isEqualToString:@""]){
        [_Delegate updateEnd:NO :@"Insert Destination!"];
        return;
    }
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:theAppDelegate._stringDestination
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
                     
                     // Get the "Current User Location" MKMapItem
                     //MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                     MKMapItem *currentLocationMapItem = theAppDelegate._startLocation;
                     
                     float currentLangitude = currentLocationMapItem.placemark.coordinate.longitude;
                     float currentLatitude =  currentLocationMapItem.placemark.coordinate.latitude;
                     //NSLog( @"new location lat = %f long = %f", currentLatitude,currentLangitude );
                     
                     
                     // Pass the current location and destination map items to the Maps app
                     // Set the direction mode in the launchOptions dictionary
                     //[MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                     
                     MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
                     [request setSource:currentLocationMapItem];
                     [request setDestination:mapItem];
                     
                     MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
                     
                     [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                         //NSLog(@"%@",[response description]);
                         
                         theAppDelegate._Steps = [[NSMutableArray alloc] initWithCapacity:0];
                         
                         if (response != nil){
                             
                             for (MKRoute *actRoute in response.routes) {
                                 //NSLog(@"Distance: %f",actRoute.distance);
                                 
                                 theAppDelegate._Route = actRoute;
                                 
                                 for (MKRouteStep *actStep in actRoute.steps) {
                                     
                                     /*
                                     NSLog(@"Instrction: %@",actStep.instructions);
                                     NSLog(@"Description: %@",actStep.description);
                                     NSLog(@"Distance: %f",actStep.distance);
                                      */
                                     
                                     [theAppDelegate._Steps addObject:actStep];
                                 }
                                 
                                 
                             }
                         } else {
                             [_Delegate updateEnd:NO :[error description]];
                             return;
                         }
                         
                         //NSLog(@"%@",[error description]);
                         
                         MKRouteStep *initialStep = [theAppDelegate._Steps objectAtIndex:0];
                         MKRouteStep *firstStep =[theAppDelegate._Steps objectAtIndex:1];
                         MKRouteStep *secondStep =[theAppDelegate._Steps objectAtIndex:2];
                         
                         NSString *distance2 = [[NSString alloc] initWithFormat:@"%d",(int)firstStep.distance];
                         NSString *info2 = firstStep.instructions;
                         
                         NSNumber *infoTextKey1 = @(0);
                         NSNumber *distanceKey1 = @(1);
                         NSNumber *imageKey = @(6);
                         
                         NSString *imageValue = [self getImageFromInstruction:info2];
                         
                         if (![info2 isEqualToString:theAppDelegate._OldInfo]){
                             [theAppDelegate._message_queue enqueue:@{infoTextKey1: info2}];
                             [theAppDelegate._message_queue enqueue:@{imageKey: imageValue}];
                             theAppDelegate._OldInfo = info2;
                         }
                         [theAppDelegate._message_queue enqueue:@{distanceKey1: distance2}];
                         
                         [_Delegate updateEnd:YES :@""];
                         
                         
                     }];
                     
                     
                 }];
    
}

-(NSString *)getImageFromInstruction:(NSString *)iInstruction{
    
    if ([[iInstruction lowercaseString] rangeOfString:[@"turn left" lowercaseString]].location!=NSNotFound){
        return @"ARROW_LEFT";
    } else if ([[iInstruction lowercaseString] rangeOfString:[@"turn right" lowercaseString]].location!=NSNotFound){
        return @"ARROW_RIGHT";
    } else {
        
        
    }
    
    
    return @"";
}

@end
