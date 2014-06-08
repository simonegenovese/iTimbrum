//
//  ZucchettiConnector.m
//  iTimbrum
//
//  Created by Simone Genovese on 05/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "ZucchettiConnector.h"

@interface ZucchettiConnector() {
    NSURLSession *session;
    ViewController *mainView;
}

@end
@implementation ZucchettiConnector

@synthesize session,mainView;

- (id)init{
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    session = [NSURLSession sessionWithConfiguration: sessionConfig delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    return self;
}


- (void)sendLoginRequest: (NSString*) username password: (NSString*) password{
    NSURL *aUrl = [NSURL URLWithString:@"https://saas.hrzucchetti.it/hrpergon/servlet/cp_login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSString *postString = [[NSMutableString alloc ] initWithFormat: @"m_cUserName=%@&m_cPassword=%@&m_cAction=login",username,password];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSLog(@"Response:%@ %@\n", response, error);
                                                    if(error == nil)
                                                    {
                                                        NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                        NSLog(@"Data = %@",text);
                                                        if(![[[response URL] absoluteString] isEqualToString:@"https://saas.hrzucchetti.it/hrpergon/servlet/../../hrpergon/servlet/../jsp/home.jsp"]){
                                                            NSString *myHTML = @"<html><body><h2>Accesso non riuscito!</h2>Il servizio potrebbe non funzionare correttamente o le credenziali essere invialide.</body></html>";
                                                            [mainView loadHTML:myHTML];
                                                        } else {
                                                            [self loadAccessLog];
                                                        }
                                                    }
                                                    
                                                }];
    [dataTask resume];
    
}

- (void) loadAccessLog{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Rome"]];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSURL *aUrl = [NSURL URLWithString:@"https://saas.hrzucchetti.it/hrpergon/servlet/SQLDataProviderServer"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSString *postString =[[NSString alloc] initWithFormat:@"rows=10&startrow=0&count=true&cmdhash=49189db8b0d3c1ee6c2b37ef5dbd803&sqlcmd=rows%%3Aushp_fgettimbrus&pDATE=%@",dateString];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSLog(@"Response:%@ %@\n", response, error);
                                                    
                                                    if(error == nil)
                                                    {
                                                        NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                        NSLog(@"Data = %@",text);
                                                        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                        NSArray *iPhoneModels = [NSArray arrayWithArray:[json objectForKey:@"Data"]];
                                                        
                                                        [mainView loadNewDataList:iPhoneModels];
                                                    }
                                                    
                                                }];
    [dataTask resume];
}


- (void)timbra:(NSString *) cartellino{
    NSURL *aUrl = [NSURL URLWithString:@"https://saas.hrzucchetti.it/hrpergon/servlet/ushp_ftimbrus"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSString *postString =[[NSString alloc] initWithFormat:@"verso=%@",cartellino];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSLog(@"Response:%@ %@\n", response, error);
                                                    
                                                    if(error == nil)
                                                    {
                                                        NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                        NSLog(@"Data = %@",text);
                                                        [mainView loadHTML:text];
                                                    }
                                                    
                                                }];
    [dataTask resume];
    
}

@end
