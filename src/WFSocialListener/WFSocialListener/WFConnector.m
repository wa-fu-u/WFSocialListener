//
//  TwitterPollingConnector.m
//  WFSocialListener
//
//  Created by akihiro uehara on 2013/03/07.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFConnector.h"
#import "WFOAuthConnection.h"
#import <Social/Social.h>

@interface WFConnector () {
    SLRequest *_slrequest;
    WFOAuthConnection *_con;
}
@property (nonatomic) WFAccount    *account;
@property (nonatomic) NSString     *endpoint;
@property (nonatomic) NSDictionary *parameters;
@property (nonatomic) NSDate       *lastUpdatedAt;

@end

@implementation WFConnector
#pragma mark - Constructor
- (id)initWithAccount:(WFAccount *)account endpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        self.account    = account;
        self.endpoint   = endpoint;
        self.parameters = parameters;
        self.lastUpdatedAt = [NSDate date];
    }
    return self;
}
#pragma mark - Private methods
- (void)handleResponseData:(NSData *)responseData urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error  handler:(WFConnectorHandler)handler {
//    DLog(@"%s %@", __func__, [urlResponse allHeaderFields]);
    NSInteger statusCode = [urlResponse statusCode];
    id jsonData;
    if (statusCode == 200) {
        jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    } else {
        DLog(@"%s\n\thttp error, status code:%d\n\tur:%@\n\tresponseData:%@\n\terror:%@",
             __func__,
             statusCode,
             urlResponse.URL,
             [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding],
             error);
    }

    self.lastUpdatedAt = [NSDate date];    
    handler(jsonData, urlResponse, error);
}
#pragma mark - Public methods
- (NSURLRequest *)prepareURLRequest:(NSDictionary *)additionalParameters {
    // 標準パラメータにパラメータを追加
    NSMutableDictionary *p = [[NSMutableDictionary alloc] initWithDictionary:self.parameters];
    [p addEntriesFromDictionary:additionalParameters];
    
    NSURLRequest *request = nil;
    
    bool hasCredential = (self.account.clientCredential != nil && self.account.tokenCredential != nil);
    if ( hasCredential ) {
        WFOAuthRequest *inst = [[WFOAuthRequest alloc]
                                initWithCredential:self.account.clientCredential
                                tokenCredential:self.account.tokenCredential
                                oauthAdditionalParameters:nil
                                endpoint:[NSURL URLWithString:self.endpoint]
//FIXME                                httpMethod:WFOAuthHttpGET
                                httpMethod:WFOAuthHttpPOST
                                queryParameters:p];
        request = [inst preparedURLRequest];
    } else {
        
        ACAccount *a = self.account.account;
        SLRequest *slrequest = [SLRequest
                                requestForServiceType:SLServiceTypeTwitter
                                //FIXME                                requestMethod:SLRequestMethodGET
                                //FIXME
                                requestMethod:SLRequestMethodPOST
                                URL:[NSURL URLWithString:self.endpoint]
                                parameters:p];
        slrequest.account = a;
        
        request = [slrequest preparedURLRequest];
    }
    return request;
}

- (void)fetch:(NSDictionary *)additionalParameters handler:(WFConnectorHandler)handler {
    __weak WFConnector *weak_self = self;
    
    // 標準パラメータにパラメータを追加
    NSMutableDictionary *p = [[NSMutableDictionary alloc] initWithDictionary:self.parameters];
    [p addEntriesFromDictionary:additionalParameters];
    
    bool hasCredential = (self.account.clientCredential != nil && self.account.tokenCredential != nil);
    if ( hasCredential ) {
        _con = [WFOAuthConnection
                request:self.account.clientCredential
                tokenCredential:self.account.tokenCredential
                oauthParameters:nil
                endpoint:[NSURL URLWithString:self.endpoint]
                httpMethod:WFOAuthHttpGET
                queryParameters:p
                handler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)  {
                    [weak_self handleResponseData:responseData urlResponse:urlResponse error:error handler:handler];
                }];
    } else {
        ACAccount *a = self.account.account;
        _slrequest = [SLRequest
                      requestForServiceType:SLServiceTypeTwitter
                      requestMethod:SLRequestMethodGET
                      URL:[NSURL URLWithString:self.endpoint]
                      parameters:p];
        _slrequest.account = a;
        
        [_slrequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            [weak_self handleResponseData:responseData urlResponse:urlResponse error:error handler:handler];
        }];
    }
}
@end