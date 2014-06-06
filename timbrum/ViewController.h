//
//  ViewController.h
//  timbrum
//
//  Created by Simone Genovese on 03/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import "ZucchettiConnector.h"
#endif
@class ZucchettiConnector;
@interface ViewController : UIViewController<UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (readwrite) ZucchettiConnector *connecctor;

-(void) loadHTML:(NSString *) data;

-(void) loadNewDataList:(NSArray*) array;
@end
