//
//  WFTwitterTokenRequest.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/05.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterTokenRequest.h"
#import "WFTwitterTypes.h"
#import "WFOAuthCredentialStore.h"
#import "WFTwitterVerifyCredential.h"

@interface WFTwitterTokenRequest () {
    __weak WFTwitterTokenRequest *_weakSelf;
    UIWebView *_webView;
    WFAccount *_account;
    NSString  *_callbackURL;
    WFTwitterTokenRequestHandler _handler;
    
    WFOAuthCredentialStore *_store;
    WFTwitterVerifyCredential *_verifyCredential;
}
@end

@implementation WFTwitterTokenRequest
#pragma mark - Constructor
- (id)initWithArgs:(UIWebView *)webView
          account:(WFAccount *)account
      callbackURL:(NSString *)callbackURL
{
    self = [super init];
    if (self) {
        _weakSelf = self;    
        _webView = webView;
        _account = account;
        _callbackURL = callbackURL;
    }
    return self;
}
#pragma mark - Private methods

- (void)requestToken
{
    _store =
    [WFOAuthCredentialStore
     requestToken:_webView
     clientCredential:_account.clientCredential
     callbackURL:[NSURL URLWithString:_callbackURL]
     temporalCredentialURI:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]
     ahthorizeURI:[NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"]
     tokenRequestURI:[NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"]
     handler:^(WFOAuthCredentialStore *sender, WFOAuthCredential *c, NSError *e) {
         [_weakSelf handleRequestToken:sender credential:c error:e];
     }];
}
- (void)handleRequestToken:(WFOAuthCredentialStore *)sender credential:(WFOAuthCredential *)c error:(NSError *)e {
    if (e != nil || c == nil) {
        _handler(NO, e);
    } else {
        [self verifyAccount:c];
    }    
}
- (void)verifyAccount:(WFOAuthCredential *)credential {
    _account.tokenCredential = credential;
    _verifyCredential =
    [WFTwitterVerifyCredential
     accountVerifyCredential:_account     
     handler:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *error) {
         [_weakSelf handleVerifyCredential:jsonData urlResponse:urlResponse error:error];
     }];
}
- (void)handleVerifyCredential:(id)jsonData urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error {
    _handler(_verifyCredential.verified, error);
}
#pragma mark - Public methods
+(WFTwitterTokenRequest *)requestToken:(UIWebView *)webView
                               account:(WFAccount *)account
                           callbackURL:(NSString *)callbackURL
                               handler:(WFTwitterTokenRequestHandler)handler
{
    WFTwitterTokenRequest *inst = [[WFTwitterTokenRequest alloc]
                                   initWithArgs:webView
                                   account:account
                                   callbackURL:callbackURL];
    inst->_handler = handler;
    [inst requestToken];
    
    return inst;
}
@end