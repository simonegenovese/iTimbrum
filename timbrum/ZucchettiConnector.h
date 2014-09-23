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

extern NSString * const CONNECTION_ERROR;

@class ViewController;
@interface ZucchettiConnector : NSObject

@property (readonly) NSURLSession *session;
@property (readonly) NSString *url;

@property (readwrite) ViewController *mainView;

- (void)sendLoginRequest: (NSString*) username password: (NSString*) password url:(NSString*) zucchettiUrl;

- (void) loadAccessLog;

- (void)timbra:(NSString *) cartellino;

@end
