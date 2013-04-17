//
//  WFTwitterGetDirectMessages.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/05.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterAccountVerifyCredentials.h"
#import "WFTwitterTypes.h"
#import "WFConnector.h"
#import "WFError.h"

// see https://dev.twitter.com/docs/api/1.1/get/direct_messages

@interface WFTwitterAccountVerifyCredentials () {
    NSString     *_endpoint;
    NSDictionary *_defaultParams;
    WFConnector *_connector;
}
@property (nonatomic) WFAccount *account;
@property (nonatomic) NSString  *name;

@end

@implementation WFTwitterAccountVerifyCredentials
#pragma mark - Constructor
- (id)initWithAccount:(WFAccount *)a {
    self = [super init];
    if (self){
        self.account = a;        
        _endpoint      = @"https://api.twitter.com/1.1/account/verify_credentials.json";
        _defaultParams = @{};
    }
    return self;
}
#pragma mark - Private methods
- (void)parse:(id)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *d = (NSDictionary *)jsonData;
        self.name = d[@"name"];
    }
}
- (void)verifyCredentials:(WFConnectorHandler)handler {
    __weak WFTwitterAccountVerifyCredentials *weak_self = self;
    _connector = [[WFConnector alloc] initWithAccount:self.account endpoint:_endpoint parameters:_defaultParams];
    [_connector fetch:nil handler:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *error){
        [weak_self handleCredentials:handler jsonData:jsonData urlResponse:urlResponse error:error];
    }];
}
- (void)handleCredentials:(WFConnectorHandler)handler jsonData:(id)jsonData urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error {
    [self parse:jsonData];
    NSError *e = nil;
    if (error != nil) {
        e = error;
    } else if (![self.name isEqualToString:self.account.username]) {
        e = [WFError createError:kWFTwitterErrorDomain
                            code:WFTwitterAccountVerificationError
                shortDescription:@"User name of user status is wrong."
                     description:[NSString stringWithFormat:@""]
                      suggestion:@"User may mistype a user name into the authorization form."];
    }
    handler(jsonData, urlResponse, e);
}

#pragma mark - Public methods
+(id)verifyCredentials:(WFAccount *)account
               handler:(WFConnectorHandler)handler
{
    WFTwitterAccountVerifyCredentials *con = [[WFTwitterAccountVerifyCredentials alloc] initWithAccount:account];
    [con verifyCredentials:handler];
    return con;
}
@end
