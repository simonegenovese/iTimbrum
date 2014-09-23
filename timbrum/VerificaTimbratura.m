//
//  VerificaTimbratura.m
//  iTimbrum
//
//  Created by Simone Genovese on 19/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "VerificaTimbratura.h"

@interface VerificaTimbratura(){
    ZucchettiConnector * localconnector;
    NSMutableString * localtimbratura;
}

@end

@implementation VerificaTimbratura
@synthesize connector = _connector;


-(void) setConnector:(ZucchettiConnector *)connector{
    localconnector = connector;
}

-(void) setTimbratura:(NSString*)timbratura{
    localtimbratura = [[NSMutableString alloc]initWithString:timbratura];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex == buttonIndex){
        // Do cancel
    }
    else{
        [localconnector timbra:localtimbratura];
        NSLog(@"Timbra,%@",localtimbratura);
    }
    
}


@end
