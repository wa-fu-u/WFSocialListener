//
//  WFTwitterVerifyCredential.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/16.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterVerifyCredential.h"
#import "WFConnector.h"
#import "WFError.h"
#import "WFTwitterTypes.h"

// read https://dev.twitter.com/docs/api/1.1/get/account/verify_credentials

@interface WFTwitterVerifyCredential () {
    NSString     *_endpoint;
    NSDictionary *_defaultParams;
    WFConnector *_connector;

}
@property (nonatomic) WFAccount *account;
@property (nonatomic) BOOL isCorrectUsername;
@property (nonatomic) BOOL verified;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *screen_name;
@property (nonatomic) NSString *profile_image_url;
@end

@implementation WFTwitterVerifyCredential
#pragma mark - Constructor
- (id)initWithAccount:(WFAccount *)a {
    self = [super init];
    if (self){
        self.account   = a;
        _endpoint      = @"https://api.twitter.com/1.1/account/verify_credentials.json";
        _defaultParams = @{@"include_entities" : @"false"};
    }
    return self;
}
#pragma mark - Private methods
- (void)parse:(id)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *d = (NSDictionary *)jsonData;
        self.name              = d[@"name"];
        self.screen_name       = d[@"screen_name"];
        self.profile_image_url = d[@"profile_image_url"];
        self.verified          = [d[@"verified"] boolValue];
    }
}
-(void)getAccountVerifyCredentials:(WFConnectorHandler)handler {
    __weak WFTwitterVerifyCredential *weak_self = self;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:_defaultParams];
    
    _connector = [[WFConnector alloc] initWithAccount:self.account endpoint:_endpoint parameters:params];
    [_connector fetch:nil handler:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *error){
        [weak_self handlerAccessUserShow:handler jsonData:jsonData urlResponse:urlResponse error:error];
    }];
}


- (void)handlerAccessUserShow:(WFConnectorHandler)handler jsonData:(id)jsonData urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error {
    NSError *e = error;
    
    [self parse:jsonData];
    
    // check user_name
    if(e == nil && self.verified && ! [self.account.username isEqualToString:self.screen_name]) {
        self.verified = NO;
        e = [WFError createError:kWFTwitterErrorDomain
                            code:WFTwitterAccountVerificationError
                shortDescription:@"Illegular user name."
                     description:[NSString stringWithFormat:@"Verified user screen name is %@, expected %@.", self.screen_name, _account.account.username]
                      suggestion:nil];
    }
    handler(jsonData, urlResponse, e);
}

#pragma mark - Public methods
+(WFTwitterVerifyCredential *)accountVerifyCredential:(WFAccount *)account handler:(WFConnectorHandler)handler {
    WFTwitterVerifyCredential *c =[[WFTwitterVerifyCredential alloc] initWithAccount:account];
    [c getAccountVerifyCredentials:handler];
    return c;
}
@end
