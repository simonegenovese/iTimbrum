//
//  ZucchettiConnector.h
//  iTimbrum
//
//  Created by Simone Genovese on 05/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"
#endif
@class ViewController;
@class TableViewController;
@interface ZucchettiConnector : NSObject

@property (readonly) NSURLSession *session;
@property (readwrite) ViewController *mainView;
@property (readwrite) TableViewController *tableView;

- (void)sendLoginRequest: (NSString*) username password: (NSString*) password;

- (void) loadAccessLog;

- (void)timbra:(NSString *) cartellino;

@end
