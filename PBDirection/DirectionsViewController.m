//
//  DirectionsViewController.m
//  PBDirection
//
//  Created by Guido Naturani on 18/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import "DirectionsViewController.h"

#import <MapKit/MapKit.h>

#import "AppDelegate.h"

@interface DirectionsViewController ()

@end

@implementation DirectionsViewController

@synthesize _StringSteps;
@synthesize _Steps;
@synthesize _Route;

@synthesize locationManager;
@synthesize locations;
@synthesize _Updating;
@synthesize _lbMessage;

@synthesize _WaitingAlert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _StringSteps = [[NSMutableArray alloc] initWithCapacity:0];
        _Steps = [[NSMutableArray alloc] initWithCapacity:0];
        _Route = [[MKRoute alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _WaitingAlert = [[UIAlertView alloc] initWithTitle:@"Routing in progress\nPlease Wait..."
                                               message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    
    //UIBarButtonItem *btNewSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newSearch:)];
    
    UIBarButtonItem *btNewSearch = [[UIBarButtonItem alloc] initWithTitle:@"new search" style:UIBarButtonItemStyleBordered target:self action:@selector(newSearch:)];

    UIBarButtonItem *btRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateTurnByTurnFromBt:)];
    
    //UIBarButtonItem *btRefreshLoc = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateTurnByTurnFromLocBt:)];
    
    UIBarButtonItem *btStopRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopRefreshAutoLocation:)];
    
    UIBarButtonItem *btStartRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startRefreshAutoLocation:)];
        
    self.navigationItem.rightBarButtonItem = btNewSearch;
    self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:btRefresh, btStopRefresh, btStartRefresh, nil];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    //[self.tableView reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.locations = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    //self.locationManager.distanceFilter = 1;
    
    self._Updating = NO;
    
    [self.locationManager startUpdatingLocation];
    
}

-(IBAction)stopRefreshAutoLocation:(id)sender{
    NSDate *actDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [df stringFromDate:actDate];
    
    _lbMessage.text = [[NSString alloc] initWithFormat:@"%@ - STOP Update",dateString ];
    
    [self.locationManager stopUpdatingLocation];
}

-(IBAction)startRefreshAutoLocation:(id)sender{
    NSDate *actDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [df stringFromDate:actDate];
    _lbMessage.text = [[NSString alloc] initWithFormat:@"%@ - RESTART Update",dateString ];
    [self.locationManager startUpdatingLocation];
}

-(IBAction)newSearch:(id)sender{
    [self.locationManager stopUpdatingLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateDataFromApp{
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    _Steps = theAppDelegate._Steps;
    _Route = theAppDelegate._Route;
}

-(void)updateTurnByTurn{
    if (_Updating == NO){
        _Updating = YES;
        AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        theAppDelegate._TurnByTurn._Delegate = self;
        [theAppDelegate._TurnByTurn calculate];
    }
}

-(IBAction)updateTurnByTurnFromBt:(id)sender{
    
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    // Get the "Current User Location" MKMapItem
    theAppDelegate._startLocation = [MKMapItem mapItemForCurrentLocation];
    theAppDelegate._TurnByTurn._Delegate = self;
    [theAppDelegate._TurnByTurn calculate];
    
    [_WaitingAlert show];
}

-(IBAction)updateTurnByTurnFromLocBt:(id)sender{

    [self.locationManager startUpdatingLocation];
    [_WaitingAlert show];

}

-(void)updateEnd:(BOOL)iSuccess :(NSString *) iMessage{
    
    [_WaitingAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    NSDate *actDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [df stringFromDate:actDate];
    
    if (iSuccess == NO){
        
        _Steps = [[NSMutableArray alloc] initWithCapacity:0];
        _lbMessage.text = [[NSString alloc] initWithFormat:@"%@ - %@",dateString, iMessage ];
        
        //[[[UIAlertView alloc] initWithTitle:nil message:iMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        
        [self updateDataFromApp];        
        [self.tableView reloadData];
        _lbMessage.text = [[NSString alloc] initWithFormat:@"%@ - Update OK",dateString ];
        
    }
    _Updating = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_Steps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKRouteStep *actStep = [_Steps objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCell"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:100];
    [lblName setText:actStep.instructions];

    UILabel *lblDist = (UILabel *)[cell viewWithTag:200];
    [lblDist setText:[[NSString alloc] initWithFormat:@"%f",actStep.distance]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    float currentLangitude = newLocation.coordinate.longitude;
    float currentLatitude =  newLocation.coordinate.latitude;
    //NSLog( @"new location lat = %f long = %f", currentLatitude,currentLangitude );
    
    //NSLog(@"Start New Update");
 
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = newLocation.coordinate;
    
    CLLocationCoordinate2D coord = [newLocation coordinate] ;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    theAppDelegate._startLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    [self updateTurnByTurn];
    
}

@end
