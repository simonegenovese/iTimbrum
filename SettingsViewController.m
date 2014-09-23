//
//  SettingsViewController.m
//  iTimbrum
//
//  Created by Simone Genovese on 18/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "SettingsViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *durataPausa;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *urlZucchetti;
@property (weak, nonatomic) IBOutlet UITextField *latitudine;
@property (weak, nonatomic) IBOutlet UITextField *longitudine;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *wifiLabel;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [_durataPausa setText:[standardUserDefaults objectForKey:@"pranzo_preference"]];
    [_password setText:[standardUserDefaults objectForKey:@"pass_preference"]];
    [_username setText:[standardUserDefaults objectForKey:@"name_preference"]];
    [_urlZucchetti setText:[standardUserDefaults objectForKey:@"zucchetti_preference"]];
    [_latitudine setText:[standardUserDefaults objectForKey:@"latitudine_preference"]];
    [_longitudine setText:[standardUserDefaults objectForKey:@"longitudine_preference"]];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = 200; // meters
    [_locationManager startUpdatingLocation];
    
    NSString *currentSSID = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil){
        NSDictionary* myDict = (NSDictionary *) CFBridgingRelease(CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0)));
        if (myDict!=nil){
            currentSSID=[myDict valueForKey:@"SSID"];
        } else {
            currentSSID=@"<<NONE>>";
        }
    } else {
        currentSSID=@"<<NONE>>";
    }
    [_wifiLabel setText:currentSSID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[_durataPausa text] forKey:@"pranzo_preference"];
    [standardUserDefaults setObject:[_password text] forKey:@"pass_preference"];
    [standardUserDefaults setObject:[_username text] forKey:@"name_preference"];
    [standardUserDefaults setObject:[_urlZucchetti text] forKey:@"zucchetti_preference"];
    [standardUserDefaults setObject:[_latitudine text] forKey:@"latitudine_preference"];
    [standardUserDefaults setObject:[_longitudine text] forKey:@"longitudine_preference"];
    
    [standardUserDefaults synchronize];
}
- (void)viewDidDisappear:(BOOL)animated{

}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)calcolaCoordinate:(id)sender {
    CLLocation *location = [_locationManager location];
    // Configure the new event with information from the location
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    [_latitudine setText:[[NSString alloc] initWithFormat:@"%f",coordinate.latitude]];
    [_longitudine setText:[[NSString alloc] initWithFormat:@"%f",coordinate.longitude]];
    
}
- (IBAction)userDoneEnteringText:(id)sender {
    UITextField *theField = (UITextField*)sender;
    [theField resignFirstResponder];
}

@end
