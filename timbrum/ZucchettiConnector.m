//
//  ZucchettiConnector.m
//  iTimbrum
//
//  Created by Simone Genovese on 05/06/14.
//  Copyright (c) 2014 SimoneGenovese. All rights reserved.
//

#import "ZucchettiConnector.h"

NSString * const CONNECTION_ERROR = @"<html><body><h2>Accesso non riuscito!</h2>Il servizio potrebbe non funzionare correttamente o le credenziali essere invialide.</body></html>";

@interface ZucchettiConnector() {
    NSURLSession *session;
    ViewController *mainView;
    NSString *url;
}

@end
@implementation ZucchettiConnector

@synthesize url,session,mainView;

- (id)init{
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration: sessionConfig delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    return self;
}


- (void)sendLoginRequest: (NSString*) username password: (NSString*) password url:(NSString *)zucchettiUrl{
    url = zucchettiUrl;
    if (session!=nil) {
        [session invalidateAndCancel];
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration: sessionConfig delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    }
    NSString * loginUrl = [[NSString alloc] initWithFormat:@"%@/servlet/cp_login",zucchettiUrl ];
    NSURL *aUrl = [NSURL URLWithString:loginUrl];
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
                                                        if([[[response URL] absoluteString] rangeOfString:@"/jsp/home.jsp"].location == NSNotFound){
                                                            [mainView loadHTML:CONNECTION_ERROR];
                                                        } else {
                                                            [self loadAccessLog];
                                                        }
                                                    } else {
                                                        [mainView loadHTML:CONNECTION_ERROR];
                                                    }
                                                    
                                                }];
    [dataTask resume];
    
}

- (void) loadAccessLog{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Rome"]];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSURL *aUrl = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/servlet/SQLDataProviderServer",url]];
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
                                                        if(json == nil){
                                                            
                                                            [mainView loadHTML:CONNECTION_ERROR];
                                                        } else {
                                                            [mainView loadNewDataList:iPhoneModels];
                                                        }
                                                    } else {
                                                        [mainView loadHTML:CONNECTION_ERROR];
                                                    }
                                                    
                                                }];
    [dataTask resume];
}


- (void)timbra:(NSString *) cartellino{
    NSURL *aUrl = [NSURL URLWithString:[[NSString alloc]initWithFormat:@"%@/servlet/ushp_ftimbrus",url]];
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
                                                    } else {
                                                        [mainView loadHTML:CONNECTION_ERROR];
                                                    }
                                                    
                                                }];
    [dataTask resume];
    
}

@end
