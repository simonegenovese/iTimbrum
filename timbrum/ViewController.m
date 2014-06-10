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

@end

@implementation ViewController

@synthesize connecctor = _connecctor;
@synthesize timer = _timer;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    _connecctor = [[ZucchettiConnector alloc] init];
    [_connecctor setMainView:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                              target:self
                                            selector:@selector(updatePranzoSlider:)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}


-(void)becomeActive:(NSNotification *)notification {
    [self viewDidAppear:YES];
}

-(void)updatePranzoSlider:(NSNotification *)notification{
    NSLog(@"Scalo 60 secondi");
}

- (void)viewDidAppear:(BOOL)animated
{
    [_timer invalidate];
    _timer = nil;
    [super viewDidAppear:animated];
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * password = [standardUserDefaults objectForKey:@"pass_preference"];
    NSString * username = [standardUserDefaults objectForKey:@"name_preference"];
    [_connecctor sendLoginRequest:username password:password];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)sliderAction:(id)sender {
    if ([_slider value] == [_slider minimumValue] && ![_slider isHighlighted] ) {
        NSLog(@"Enter");
        // [_connecctor timbra:@"E"];
        [_connecctor loadAccessLog];
    } else if ([_slider value] == [_slider maximumValue] ){
        NSLog(@"Exit");
        // [_connecctor timbra:@"U"];
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
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
        localNotification.alertBody = @"E' ora di rientrare!";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
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
    [logs appendFormat:@"</table>Ore Tot: %d:%02d</body></html>",(int)minTot/60,(int)minTot%60];
    
    [_webView loadHTMLString:logs baseURL:nil];
    
}
- (IBAction)refreshAction:(id)sender {
    [_connecctor loadAccessLog];
}




@end
