//
//  WFSocialListenerTests.m
//  WFSocialListenerTests
//
//  Created by Akihiro Uehara on 2013/04/11.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFSocialListenerTests.h"
#import "WFOAuthCredential.h"
#import "WFOAuthConnection.h"
#import "WFOAuthRequest.h"
#import "WFOAuthCredentialStore.h"

#define kClientKey    @"ZQry8zIMSI3ZH1k7ThcVJA"
#define kClientSecret @"DqQuYUPSyIirf43T6Ee7RpWdIH8OvFG9Yk1z3FuetwM"

#define kTokenKey    @"1091318102-qDCh9oM7uaMnH3xw8Lr6cGyW57JxaKjwYsbZViy"
#define kTokenSecret @"aklbQnvCNURAdY2sFALmkpHhg2N9kW7YiT7qryWfE"
@interface WFSocialListenerTests ()  {
    WFOAuthConnection *_con;
}
@property () double timeoutInterval;
@property () bool isFinished;
@end

@implementation WFSocialListenerTests
- (void)setUp
{
    [super setUp];
    self.timeoutInterval = 1000;
}
- (void)tearDown
{
    double delayInSeconds = self.timeoutInterval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STFail(@"timed out.");
        self.isFinished = YES;
    });
    
    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    } while (!self.isFinished);
    
    [super tearDown];
}

- (void)testSignature {
    // テストデータ生成 http://developer.linkedin.com/oauth-test-console
    // 14:07, OK、これで署名は通った
    WFOAuthCredential *c = [[WFOAuthCredential alloc] initWithKey:@"dpf43f3p2l4k3l03" secret:@"kd94hf93k423kf44"];
    NSDictionary *p = @{@"oauth_consumer_key":@"dpf43f3p2l4k3l03",
                        @"oauth_signature_method": @"HMAC-SHA1",
                        @"oauth_timestamp" : @"137131200",
                        @"oauth_nonce" : @"wIjqoS",
                        @"oauth_version":@"1.0"
                        };
    NSString *sig = @"WXkFFWDjglsdcXQj7lfPdLRb7Qo=";
    WFOAuthRequest *oauthReq = [[WFOAuthRequest alloc] initWithCredential:c
                                                          tokenCredential:nil
                                                          oauthAdditionalParameters:nil
                                                                 endpoint:[NSURL URLWithString:@"https://photos.example.net/initiate"]
                                                               httpMethod:WFOAuthHttpPOST
                                                          queryParameters:nil];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://photos.example.net/initiate"]];
    req.HTTPMethod = @"POST";
    NSString *calcSig = [oauthReq calcSignature:req parameters:p];
    STAssertTrue([sig isEqualToString:calcSig], @"Signature is wrong. Expected:%@ but:%@ ", sig, calcSig);
    
    // 14:00 署名のところはOK。baseStringの作り方を間違えていた
   
    self.isFinished = YES;
}



- (void)testTemporaryCredential {
    self.timeoutInterval = 10;
    
    WFOAuthCredential *cre = [[WFOAuthCredential alloc] initWithKey:kClientKey secret:kClientSecret];
    NSURL *ep = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/request_token"];
    
    _con = [WFOAuthConnection
            request:cre
            tokenCredential:nil
            oauthParameters:nil
            endpoint:ep
            httpMethod:WFOAuthHttpGET
//            httpMethod:WFOAuthHttpPOST
            queryParameters:nil
            handler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                STAssertNil(error, @"error:%@", error);
                self.isFinished = YES;
            }];
}



@end
