//
//  ViewController.m
//  timbrum
//
//  Created by Simone Genovese on 03/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#define radianConst M_PI/180.0
#define EARTHRADIUS 6371

@interface ViewController()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISlider *pranzoSlider;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursRes;
@property (strong,nonatomic) VerificaTimbratura * verifica ;
@end

@implementation ViewController

@synthesize connector = _connector;
@synthesize dataUscitaPranzo = _dataUscitaPranzo;
@synthesize manager;
@synthesize accuracy;
@synthesize regionCourante;
@synthesize centre;
@synthesize reach = _reach;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    _verifica = [[VerificaTimbratura alloc] init];
    
    _connector = [[ZucchettiConnector alloc] init];
    [_connector setMainView:self];
    
    [self startStandardUpdates];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        [self startRegionMonitoring];
        NSLog(@"Region monitoring available");
    }
    
    // Allocate a reachability object
    reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    __weak typeof(self) weakSelf = self;
    __weak typeof(Reachability*) weakReach = reach;
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        NetworkStatus netStatus =[weakReach currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                break;
            }
            case ReachableViaWWAN:
            {
                [weakSelf doAlert:@"Non sei connesso alla WiFi"];

                break;
            }
            case ReachableViaWiFi:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *currentSSID = @"";
                    CFArrayRef myArray = CNCopySupportedInterfaces();
                    if (myArray != nil){
                        NSDictionary* myDict = (NSDictionary *) CFBridgingRelease(CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0)));
                        if (myDict!=nil){
                            currentSSID=[myDict valueForKey:@"SSID"];
                            NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
                            if ([currentSSID isEqualToString:[standardUserDefaults objectForKey:@"wifi_preference"]]) {
                                [weakSelf doAlert:@"Sei connesso alla WiFi, effettua accesso"];
                            }
                        }
                    }
                    NSLog(@"REACHABLE!");
                });
                break;
            }
            default:
            {
                break;
            }
                
        }
        
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        [weakSelf doAlert:@"Non Raggiungibile"];
        
        NSLog(@"UNREACHABLE!");
    };
        [reach startNotifier];
}


-(void)becomeActive:(NSNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self viewDidAppear:YES];
}

- (void)connect:(NSString *)zucchettiUrl password:(NSString *)password username:(NSString *)username
{
    [_connector sendLoginRequest:username password:password url:zucchettiUrl];
    [NSTimer scheduledTimerWithTimeInterval: 2.0
                                     target: self
                                   selector:@selector(reloadPage:)
                                   userInfo: nil repeats:NO];
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
        
        [self connect:zucchettiUrl password:password username:username];
        
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
        if(isLastAnEnter){
            [_verifica setConnector:_connector];
            [_verifica setTimbratura:@"E"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doppia Entrata"
                                                            message:@"Attenzione esiste già una timbratura per l'ingresso. Sei sicuro di voler procedere?"
                                                           delegate:_verifica
                                                  cancelButtonTitle:@"Annulla"
                                                  otherButtonTitles:@"Timbra", nil];
            [alert show];
            
        } else{
            [_connector timbra:@"E"];
        }
        [_slider setEnabled:false];
        [_connector loadAccessLog];
    } else if ([_slider value] == [_slider maximumValue] ){
        NSLog(@"Exit");
        if(!isLastAnEnter){
            [_verifica setConnector:_connector];
            [_verifica setTimbratura:@"U"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doppia Uscita"
                                                            message:@"Attenzione esiste già una timbratura per l'uscita. Sei sicuro di voler procedere?"
                                                           delegate:_verifica
                                                  cancelButtonTitle:@"Annulla"
                                                  otherButtonTitles:@"Timbra", nil];
            [alert show];
        }else{
            [_connector timbra:@"U"];
        }
        [_slider setEnabled:false];
        [_connector loadAccessLog];
    }
    [_slider setValue:([_slider maximumValue]-[_slider minimumValue])/2 animated:true];
    [_slider reloadInputViews];
    [NSTimer scheduledTimerWithTimeInterval: 0.50
                                     target: self
                                   selector:@selector(reloadPage:)
                                   userInfo: nil repeats:NO];
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
        [_connector timbra:@"U"];
        [_connector loadAccessLog];
        _dataUscitaPranzo = [[NSDate alloc] init];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[_durataPranzo integerValue]*60];
        localNotification.alertBody = @"E' ora di rientrare!";
        localNotification.applicationIconBadgeNumber++;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [localNotification setHasAction:true];
        
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
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components =
    [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    
    *hour_p = [components hour];
    *minute_p = [components minute];
}

- (void)setTimeAndRemaining:(NSInteger)minTot {
    [_hoursLabel setText:[[NSString alloc]initWithFormat:@"%d:%02d",(int)minTot/60,(int)minTot%60]];
    [_hoursRes setText:[[NSString alloc]initWithFormat:@"%d:%02d",(int)(480-minTot)/60,(int)(480-minTot)%60]];
    if (workFinishedNotif!=nil && !isLastAnEnter) {
        [[UIApplication sharedApplication]  cancelLocalNotification:workFinishedNotif];
    }
    
    if (minTot<480 && isLastAnEnter) {
        if (workFinishedNotif!=nil) {
            [[UIApplication sharedApplication]  cancelLocalNotification:workFinishedNotif];
        }
        workFinishedNotif = [[UILocalNotification alloc] init];
        workFinishedNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:(480-minTot)*60];
        workFinishedNotif.alertBody = @"Congratulazioni: hai lavorato 8 ore!";
        workFinishedNotif.applicationIconBadgeNumber++;
        workFinishedNotif.soundName = UILocalNotificationDefaultSoundName;
        [workFinishedNotif setHasAction:true];
        
        workFinishedNotif.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:workFinishedNotif];
    }
}

-(void) loadNewDataList:(NSArray*) array{
    NSMutableString *logs = [[NSMutableString alloc] initWithString:@"<html><head></head><body style='color:white;background-color: transparent;'>Timbrature:</br><table border='0' align='center'>"];
    NSInteger minTot = 0;
    isLastAnEnter= false;
    if ([array count]<=0) {
        return;
    }
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
    [_connector loadAccessLog];
}
-(void)reloadPage:(NSTimer *)timer{
    [_connector loadAccessLog];
}

-(void)updatePranzoSlider:(NSTimer *)timer{
    if (_dataUscitaPranzo!=nil) {
        NSDate * now = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSUInteger unitFlags = NSCalendarUnitMinute;
        
        NSDateComponents *components = [gregorian components:unitFlags
                                                    fromDate:_dataUscitaPranzo
                                                      toDate:now options:0];
        NSNumber *minutes =  [NSNumber numberWithDouble:[components minute]];
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
    
    //NSLog(@"Count: %i", _manager.monitoredRegions.count);
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
    
    [manager requestAlwaysAuthorization];
    
    manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    manager.distanceFilter = 10; // meters
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
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * latitudine = [standardUserDefaults objectForKey:@"latitudine_preference"];
    NSNumber * longitudine = [standardUserDefaults objectForKey:@"longitudine_preference"];
    
    centre = CLLocationCoordinate2DMake([latitudine floatValue], [longitudine floatValue]);
    regionCourante = [[CLCircularRegion alloc] initWithCenter:centre
                                                       radius:25.0
                                                   identifier:@"Work"];
    [manager startMonitoringForRegion:regionCourante];
}

- (IBAction)setCoordinates:(id)sender {
    [manager stopMonitoringForRegion:regionCourante];
    centre = CLLocationCoordinate2DMake(manager.location.coordinate.latitude, manager.location.coordinate.longitude);
    regionCourante = [[CLCircularRegion alloc] initWithCenter:centre
                                                       radius:25.0
                                                   identifier:@"Work"];
    [manager startMonitoringForRegion: regionCourante];
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion");
    if([self todayIsWorkingDay] && !isAtWork){
        [self doAlert:@"E' ora di rientrare"];
    }
    isAtWork = true;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion");
    if([self todayIsWorkingDay] && isAtWork){
        [self donotAlert];
    }
    isAtWork =false;
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring failed");
}

-(void)doAlert:(NSString *)message
{
    UILocalNotification *scheduledAlert;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    scheduledAlert = [[UILocalNotification alloc] init];
    scheduledAlert.applicationIconBadgeNumber=1;
    scheduledAlert.fireDate = nil;
    scheduledAlert.timeZone = [NSTimeZone defaultTimeZone];
    scheduledAlert.alertBody = message;
    [scheduledAlert setHasAction:true];
    scheduledAlert.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:scheduledAlert];
    
}

-(void)donotAlert
{
    UILocalNotification *scheduledAlert;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    scheduledAlert = [[UILocalNotification alloc] init];
    scheduledAlert.applicationIconBadgeNumber=1;
    scheduledAlert.fireDate = nil;
    scheduledAlert.timeZone = [NSTimeZone defaultTimeZone];
    scheduledAlert.soundName = UILocalNotificationDefaultSoundName;
    [scheduledAlert setHasAction:true];
    scheduledAlert.alertBody = @"Stai andando via? Ricorda di timbrare l'uscita";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:scheduledAlert];
    
}

-(BOOL)todayIsWorkingDay{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL domenica = [standardUserDefaults boolForKey:@"domenica_preference"];
    BOOL lunedi = [standardUserDefaults boolForKey:@"lunedi_preference"];
    BOOL martedi = [standardUserDefaults boolForKey:@"martedi_preference"];
    BOOL mercoled = [standardUserDefaults boolForKey:@"mercoledi_preference"];
    BOOL giovedi = [standardUserDefaults boolForKey:@"giovedi_preference"];
    BOOL venerdi = [standardUserDefaults boolForKey:@"venerdi_preference"];
    BOOL sabato = [standardUserDefaults boolForKey:@"sabato_preference"];
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDate *now = [[NSDate alloc] init];
    NSDateComponents* components = [cal components:NSCalendarUnitWeekday fromDate:now];
    NSInteger weekday = [components weekday];
    
    switch (weekday) {
        case 1:
            return domenica;
        case 2:
            return lunedi;
        case 3:
            return martedi;
        case 4:
            return mercoled;
        case 5:
            return giovedi;
        case 6:
            return venerdi;
        case 7:
            return sabato;
        default:
            break;
    }
    return false;
}


@end
