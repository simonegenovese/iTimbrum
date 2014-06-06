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
@property (strong, nonatomic) IBOutlet NSMutableArray *dataList;


@end

@implementation ViewController

@synthesize connecctor = _connecctor;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    _connecctor = [[ZucchettiConnector alloc] init];
    [_connecctor setMainView:self];
    _dataList = [[NSMutableArray alloc]init];
    }

-(void)becomeActive:(NSNotification *)notification {
    [self viewDidAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * password = [standardUserDefaults objectForKey:@"pass_preference"];
    NSString * username = [standardUserDefaults objectForKey:@"name_preference"];
    [_connecctor sendLoginRequest:username password:password];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_slider setContinuous: NO];
}


- (IBAction)sliderAction:(id)sender {
    if ([_slider value] == [_slider maximumValue]) {
        NSLog(@"Enter");
        [_connecctor timbra:@"E"];
        [_connecctor loadAccessLog];
    } else if ([_slider value] == [_slider minimumValue]){
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

-(void) loadNewDataList:(NSArray*) array{
    [_dataList addObjectsFromArray: array];
    NSMutableString *logs = [[NSMutableString alloc] initWithString:@"<html><head></head><body style='color:white;background-color: transparent;'>"];
    for (int i =0; i<[_dataList count]; i++) {
       [logs appendFormat:@"%@",[_dataList objectAtIndex:i]];
    }
    [logs appendString:@"</body></html>"];

    [_webView loadHTMLString:logs baseURL:nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_dataList objectAtIndex:indexPath.row];
    return cell;
}


@end
