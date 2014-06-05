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
@property (nonatomic, strong) NSMutableData *responseData;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];

    _session = [NSURLSession sessionWithConfiguration: sessionConfig delegate: nil delegateQueue: [NSOperationQueue mainQueue]];

	
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
        [self sendEnterRequest];
      
    } else if ([_slider value] == [_slider minimumValue]){
        NSLog(@"Exit");
        [self loadAccessLog];
    }
       [_slider setValue:([_slider maximumValue]-[_slider minimumValue])/2 animated:true];
    [_slider reloadInputViews];
}

- (void)sendEnterRequest{
    NSURL *aUrl = [NSURL URLWithString:@"https://saas.hrzucchetti.it/hrpergon/servlet/cp_login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSString *postString = @"m_cUserName=SIMONE.GENOVESE&m_cPassword=pass&m_cAction=login";
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask * dataTask =[_session dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                               NSLog(@"Data = %@",text);
                                                               [_webView loadData:data MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
                                                           }
                                                           
                                                       }];
    [dataTask resume];

}

- (void) loadAccessLog{
    NSURL *aUrl = [NSURL URLWithString:@"https://saas.hrzucchetti.it/hrpergon/servlet/SQLDataProviderServer"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSString *postString = @"rows=10&startrow=0&count=true&cmdhash=49189db8b0d3c1ee6c2b37ef5dbd803&sqlcmd=rows%3Aushp_fgettimbrus&pDATE=2014-06-03";
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask * dataTask =[_session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     NSLog(@"Response:%@ %@\n", response, error);

                                                     if(error == nil)
                                                     {
                                                         NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                         NSLog(@"Data = %@",text);
                                                         [_webView loadData:data MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
                                                     }
                                                     
                                                 }];
    [dataTask resume];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [_webView loadData:_responseData MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
    NSLog([_responseData description]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
