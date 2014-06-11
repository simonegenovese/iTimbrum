//
//  ViewController.m
//  timbrum
//
//  Created by Simone Genovese on 03/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "ViewController.h"

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
    _durataPranzo = [standardUserDefaults objectForKey:@"pranzo_preference"];

    [_connecctor sendLoginRequest:username password:password];
    [self updatePranzoSlider:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)sliderAction:(id)sender {
    if ([_slider value] == [_slider minimumValue] && ![_slider isHighlighted] ) {
        NSLog(@"Enter");
        [_connecctor timbra:@"E"];
        [_connecctor loadAccessLog];
    } else if ([_slider value] == [_slider maximumValue] ){
        NSLog(@"Exit");
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
    if ([_pranzoSlider value] == [_pranzoSlider maximumValue] ){
        NSLog(@"Exit Pranzo");
        // [_connecctor timbra:@"U"];
        [_connecctor loadAccessLog];
        _dataUscitaPranzo = [[NSDate alloc] init];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[_durataPranzo integerValue]];
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
        [_pranzoSlider setValue:[_pranzoSlider minimumValue]];
    }
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
    [_hoursLabel setText:[[NSString alloc]initWithFormat:@"%d:%02d",(int)minTot/60,(int)minTot%60]];
        [_hoursRes setText:[[NSString alloc]initWithFormat:@"%d:%02d",(int)(480-minTot)/60,(int)(480-minTot)%60]];
    [_webView loadHTMLString:logs baseURL:nil];
    
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
            // [_connecctor timbra:@"E"];
            
        }
    }
    
}



@end
