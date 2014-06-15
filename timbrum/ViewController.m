//
//  ViewController.m
//  timbrum
//
//  Created by Simone Genovese on 03/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "ViewController.h"
#define radianConst M_PI/180.0
#define EARTHRADIUS 6371

@interface ViewController()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISlider *pranzoSlider;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursRes;


@end

@implementation ViewController

@synthesize connecctor = _connecctor;
@synthesize dataUscitaPranzo = _dataUscitaPranzo;
@synthesize manager;
@synthesize accuracy;
@synthesize regionCourante;
@synthesize centre;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    _connecctor = [[ZucchettiConnector alloc] init];
    [_connecctor setMainView:self];
    
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad unit ID.
    bannerView_.adUnitID = @"ca-app-pub-4203217046813060/5414483033";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    bannerView_.center = CGPointMake(self.view.center.x,
                                     self.view.center.y + 150);
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    [self startStandardUpdates];
    
    
    if ([CLLocationManager regionMonitoringAvailable]) {
        [self startRegionMonitoring];
        NSLog(@"Region monitoring available");
    }
}


-(void)becomeActive:(NSNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self viewDidAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * password = [standardUserDefaults objectForKey:@"pass_preference"];
    NSString * username = [standardUserDefaults objectForKey:@"name_preference"];
    NSString * zucchettiUrl = [standardUserDefaults objectForKey:@"zucchetti_preference"];
    _durataPranzo = [standardUserDefaults objectForKey:@"pranzo_preference"];
    
    if ([password isEqualToString:@""]) {
        [self loadHTML:@"Password vuota"];
    } else if ([username isEqualToString:@""]){
        [self loadHTML:@"User vuota"];
    } else if ([zucchettiUrl isEqualToString:@""]) {
        [self loadHTML:@"Indirizzo vuoto"];
    } else if ([_durataPranzo isEqualToString:@""]){
        [self loadHTML:@"Durata pranzo non configurata"];
    }else {
        [_pranzoSlider setMaximumValue:[_durataPranzo floatValue]];
        [_connecctor sendLoginRequest:username password:password url:zucchettiUrl];
        [self updatePranzoSlider:nil];
        [self startRegionMonitoring];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)sliderAction:(id)sender {
    if ([_slider value] == [_slider minimumValue] && ![_slider isHighlighted] ) {
        NSLog(@"Enter");
        [_slider setEnabled:false];
        [_connecctor timbra:@"E"];
        [_connecctor loadAccessLog];
    } else if ([_slider value] == [_slider maximumValue] ){
        NSLog(@"Exit");
        [_slider setEnabled:false];
        [_connecctor timbra:@"U"];
        [_connecctor loadAccessLog];
    }
    [_slider setValue:([_slider maximumValue]-[_slider minimumValue])/2 animated:true];
    [_slider reloadInputViews];
}


-(void) loadHTML:(NSString *) data{
    NSMutableString *logs = [[NSMutableString alloc] initWithString:@"<html><head></head><body style='color:white;background-color: transparent;'>"];
    [logs appendString:data];
    [logs appendString:@"</body></html>"];
    
    [_webView loadHTMLString:logs baseURL:nil];
}

- (IBAction)pranzoAction:(id)sender {
    if ([_pranzoSlider value] >= [_pranzoSlider maximumValue] ){
        NSLog(@"Exit Pranzo");
        [_connecctor timbra:@"U"];
        [_connecctor loadAccessLog];
        _dataUscitaPranzo = [[NSDate alloc] init];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[_durataPranzo integerValue]*60];
        localNotification.alertBody = @"E' ora di rientrare!";
        localNotification.applicationIconBadgeNumber++;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        _timer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                                                  target: self
                                                selector:@selector(updatePranzoSlider:)
                                                userInfo: nil repeats:YES];
        [_pranzoSlider setEnabled:false];
    } else {
        [_pranzoSlider setValue:[_pranzoSlider minimumValue] animated:TRUE];
    }
    [_slider setValue:0.5 animated:true];
    [_pranzoSlider reloadInputViews];
}

- (void)calcola:(NSInteger *)hour_p minute_p:(NSInteger *)minute_p {
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:today];
    
    *hour_p = [components hour];
    *minute_p = [components minute];
}

- (void)setTimeAndRemaining:(NSInteger)minTot {
    [_hoursLabel setText:[[NSString alloc]initWithFormat:@"%d:%02d",(int)minTot/60,(int)minTot%60]];
    [_hoursRes setText:[[NSString alloc]initWithFormat:@"%d:%02d",(int)(480-minTot)/60,(int)(480-minTot)%60]];
    if (minTot<480) {
        if (workFinishedNotif!=nil) {
            [[UIApplication sharedApplication]  cancelLocalNotification:workFinishedNotif];
        }
        workFinishedNotif = [[UILocalNotification alloc] init];
        workFinishedNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:(480-minTot)*60];
        workFinishedNotif.alertBody = @"Congratulazioni: hai lavorato 8 ore!";
        workFinishedNotif.applicationIconBadgeNumber++;
        workFinishedNotif.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:workFinishedNotif];
    }
}

-(void) loadNewDataList:(NSArray*) array{
    NSMutableString *logs = [[NSMutableString alloc] initWithString:@"<html><head></head><body style='color:white;background-color: transparent;'><table border='0' align='center'>"];
    NSInteger minTot = 0;
    BOOL isLastAnEnter= false;
    for (int i =0; i<[array count]-1; i++) {
        NSString *timbratura = [[array objectAtIndex:i] objectAtIndex:2] ;
        if ([timbratura isEqualToString:@"U"]) {
            [logs appendString:@"<tr><td width='20%' bgcolor='#FF0000'>"];
        }else {
            [logs appendString:@"<tr><td width='20%' bgcolor='#00FF00'>"];
        }
        
        [logs appendFormat:@"<font color='#FFFFFF'>%@</font></td>",timbratura];
        
        NSString *data = [[array objectAtIndex:i] objectAtIndex:0] ;
        [logs appendFormat:@"<td width='80%%'>%@</td>",data];
        
        NSString *ora = [[array objectAtIndex:i] objectAtIndex:1] ;
        NSArray *oreMin = [ora componentsSeparatedByString: @":"];
        if([timbratura isEqualToString:@"E"]){
            minTot-=[oreMin[0] intValue]*60;
            minTot-=[oreMin[1] intValue];
            isLastAnEnter= true;
        } else if([timbratura isEqualToString:@"U"]){
            minTot+=[oreMin[0] intValue]*60;
            minTot+=[oreMin[1] intValue];
            isLastAnEnter = false;
        }
        [logs appendFormat:@"<td width='30%%'>%@</td></tr>",ora];
    }
    if(isLastAnEnter){
        NSInteger hour;
        NSInteger minute;
        [self calcola:&hour minute_p:&minute];
        minTot+=hour*60;
        minTot+=minute;
    }
    [logs appendString:@"</table></body></html>"];
    [self setTimeAndRemaining:minTot];
    [_webView loadHTMLString:logs baseURL:nil];
    [_slider setEnabled:true];
    
    
}
- (IBAction)refreshAction:(id)sender {
    [_connecctor loadAccessLog];
}

-(void)updatePranzoSlider:(NSTimer *)timer{
    if (_dataUscitaPranzo!=nil) {
        NSDate * now = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSUInteger unitFlags = NSMinuteCalendarUnit;
        
        NSDateComponents *components = [gregorian components:unitFlags
                                                    fromDate:_dataUscitaPranzo
                                                      toDate:now options:0];
        NSNumber *minutes =  [NSNumber numberWithInt:[components minute]];
        [_pranzoSlider setValue:[_pranzoSlider maximumValue]-[minutes floatValue] animated:true];
        if ([_pranzoSlider value]==[_pranzoSlider minimumValue]) {
            [_timer invalidate];
            [_pranzoSlider setEnabled:TRUE];
        }
    }
    
}

- (IBAction)pranzoSliding:(id)sender {
    if([_pranzoSlider value]>=[_durataPranzo floatValue]/2){
        float newPos = ([_pranzoSlider value]*0.5)/([_durataPranzo floatValue]/2) ;
        [_slider setValue: newPos];
    }
}

- (void) locationManager:(CLLocationManager *)_manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Latitude : %f, Longitude : %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    NSLog(@"Count: %i", _manager.monitoredRegions.count);
    CLRegion *region;// = (CLRegion *) _manager.monitoredRegions.anyObject;
    int i = 1;
    for (region in _manager.monitoredRegions) {
        NSLog(@"%i. Lat : %f, Long : %f, Radius: %f", i, region.center.latitude, region.center.longitude, region.radius);
        i++;
    }
}

- (CLLocationDistance) distanceEntre:(CLLocationCoordinate2D) center et:(CLLocation *) position {
    double centerLat = center.latitude * radianConst;
    double centerLong = center.longitude * radianConst;
    double positionLat = position.coordinate.latitude * radianConst;
    double positionLong = position.coordinate.longitude * radianConst;
    
    double deltaLat = centerLat - positionLat;
    double deltaLong = centerLong - positionLong;
    
    double a = pow(sin(deltaLat/2), 2)
    + cos(centerLat) * cos(positionLat) * pow(sin(deltaLong/2), 2);
    double c = 2 * atan2(pow(a, 0.5), pow(1 - a, 0.5));
    
    return c * EARTHRADIUS * 1000;
}

- (void)startStandardUpdates
{
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    manager.distanceFilter = kCLDistanceFilterNone;
    
    [manager startUpdatingLocation];
}

- (void)startSignificantChangeUpdates {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)startRegionMonitoring
{
    NSLog(@"Starting region monitoring");
    centre = CLLocationCoordinate2DMake(45.658102664404474, 13.82953941822052); // Padriciano
    regionCourante = [[CLRegion alloc] initCircularRegionWithCenter:centre radius:5.0 identifier:@"Esteco"];
    [manager startMonitoringForRegion:regionCourante];
}

- (IBAction)setCoordinates:(id)sender {
    [manager stopMonitoringForRegion:regionCourante];
    centre = CLLocationCoordinate2DMake(manager.location.coordinate.latitude, manager.location.coordinate.longitude);
    regionCourante = [[CLRegion alloc] initCircularRegionWithCenter: centre radius: accuracy identifier: @"Region"];
    [manager startMonitoringForRegion: regionCourante];
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion");
    [self doAlert];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Region Alert"
                                                    message:@"You entered the region"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    //    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion");
    [self donotAlert];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Region Alert"
                                                    message:@"You exited the region"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    //    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring failed");
}


//- (IBAction)determinerAccuracy:(id)sender {
//    [manager stopMonitoringForRegion:regionCourante];
//    regionCourante = [[CLRegion alloc] initCircularRegionWithCenter: centre radius: accuracy identifier: @"Region"];
//    
//    [manager startMonitoringForRegion:regionCourante];
//    //    self.labelAccuracy.text = [NSString stringWithFormat:@"%.1f", [regionCourante radius]];
//    
//}

-(void)doAlert
{
    UIAlertView *alertDialog;
    UILocalNotification *scheduledAlert;
    
    alertDialog = [[UIAlertView alloc]
                   initWithTitle: @"Local Notification"
                   message:@"oh! my good that you enter in my area"
                   delegate: nil
                   cancelButtonTitle: @"Ok"
                   otherButtonTitles: nil];
    
    //[alertDialog show];
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    scheduledAlert = [[UILocalNotification alloc] init];
    scheduledAlert.applicationIconBadgeNumber=1;
    scheduledAlert.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    scheduledAlert.timeZone = [NSTimeZone defaultTimeZone];
    scheduledAlert.repeatInterval = NSDayCalendarUnit;
    scheduledAlert.alertBody = @"Ben arrivato a lavoro, ricorda di timbrare.";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:scheduledAlert];
    
}

-(void)donotAlert
{
    UIAlertView *alertDialog;
    UILocalNotification *scheduledAlert;
    
    alertDialog = [[UIAlertView alloc]
                   initWithTitle: @"Local Notification"
                   message:@"Stai andando via? Ricorda di timbrare l'uscita"
                   delegate: nil
                   cancelButtonTitle: @"Ok"
                   otherButtonTitles: nil];
    
    // [alertDialog show];
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    scheduledAlert = [[UILocalNotification alloc] init];
    scheduledAlert.applicationIconBadgeNumber=1;
    scheduledAlert.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    scheduledAlert.timeZone = [NSTimeZone defaultTimeZone];
    scheduledAlert.repeatInterval = NSDayCalendarUnit;
    scheduledAlert.alertBody = @"Stai andando via? Ricorda di timbrare l'uscita";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:scheduledAlert];
    
}


@end
