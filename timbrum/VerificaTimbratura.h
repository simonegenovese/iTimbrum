//
//  VerificaTimbratura.h
//  iTimbrum
//
//  Created by Simone Genovese on 19/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ZucchettiConnector.h"

@class ZucchettiConnector;

@interface VerificaTimbratura : NSObject<UIAlertViewDelegate>{
}

@property (readwrite,nonatomic) ZucchettiConnector * connector;
-(void) setTimbratura:(NSString*)timbratura;
@end
