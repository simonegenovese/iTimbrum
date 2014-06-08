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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    _connecctor = [[ZucchettiConnector alloc] init];
    [_connecctor setMainView:self];
}



-(void)enteredBackground:(NSNotification *)notification {
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                              target:self
                                            selector:@selector(updatePranzoSlider:)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
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
    [_slider setContinuous: NO];
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

-(void) loadNewDataList:(NSArray*) array{
    NSMutableString *logs = [[NSMutableString alloc] initWithString:@"<html><head></head><body style='color:white;background-color: transparent;'><table border='0' align='center'>"];
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
        [logs appendFormat:@"<td width='30%%'>%@</td></tr>",ora];
    }
    [logs appendString:@"</table></body></html>"];
    
    [_webView loadHTMLString:logs baseURL:nil];
    
}



@end
