//
//  WFOAuthCredentialStore.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/29.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFOAuthCredentialStore.h"
#import "WFOAuthTypes.h"
#import "WFOAuthDefinitions.h"
#import "WFOAuthConnection.h"

@interface WFOAuthCredentialStore () {
    WFOAuthClientCallback _handler;
    UIWebView *_webView;
    WFOAuthConnection *_con;
}

@property (nonatomic) WFOAuthCredential *clientCredential;
@property (nonatomic) NSURL *callbackURL;
@property (nonatomic) NSURL *temporalCredentialRequestURI;
@property (nonatomic) NSURL *resourceOwnerAuthorizeURI;
@property (nonatomic) NSURL *tokenRequestURI;
@end

@implementation WFOAuthCredentialStore
#pragma mark - Constructor
+(WFOAuthCredentialStore *)requestToken:(UIWebView *)webView
                       clientCredential:(WFOAuthCredential *)clientCredential
                            callbackURL:(NSURL *)c
                  temporalCredentialURI:(NSURL *)t
                           ahthorizeURI:(NSURL *)a
                        tokenRequestURI:(NSURL *)r
                                handler:(WFOAuthClientCallback)handler
{
    WFOAuthCredentialStore *inst = [[WFOAuthCredentialStore alloc] init];
    
    inst.clientCredential = clientCredential;
    inst.callbackURL      = c;
    inst.temporalCredentialRequestURI = t;
    inst.resourceOwnerAuthorizeURI = a;
    inst.tokenRequestURI = r;
    inst->_webView = webView;
    inst->_handler = handler;
    
    
    [inst requestTemporaryToken];
    
    return inst;
}

#pragma mark - Private methods
- (void)invokeHandler:(WFOAuthCredential *)c error:(NSError *)e {
    _webView.delegate = nil;
    _handler(self, c, e);
}

- (void)reportError:(NSInteger)code shortDescription:(NSString *)shortDescription description:(NSString *)description suggestion:(NSString *)suggestion {
    WFError *err = [WFError createError:kWFOAuthErrorDomain
                                   code:code
                       shortDescription:shortDescription
                            description:description
                             suggestion:suggestion];
    [self invokeHandler:nil error:err];
}

- (NSDictionary *)parseKeyValuePairsFromQuery:(NSURL *)url {
    NSString *str = [url query];
    NSMutableDictionary *kvp = [[NSMutableDictionary alloc] init];
    for (NSString *s in [str componentsSeparatedByString:@"&"]) {
        NSArray *kv = [s componentsSeparatedByString:@"="];
        if ([kv count] == 2) {
            kvp[[kv objectAtIndex:0]] = [kv objectAtIndex:1];
        }
    }
    return kvp;
}

// テンポラルクレデンシャルの取得、取得に成功すればWebViewを要求して表示遷移する
- (void)requestTemporaryToken {
    __weak WFOAuthCredentialStore *weak_self = self;
    NSDictionary *params = @{ kOAuthCallback : [self.callbackURL absoluteString]};
    _con = [WFOAuthConnection
            request:self.clientCredential
            tokenCredential:nil
            oauthParameters:params
            endpoint:self.temporalCredentialRequestURI
            httpMethod:WFOAuthHttpPOST
            queryParameters:nil
            handler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                [weak_self handleTemporaryToke:responseData urlResponse:urlResponse error:error];
            }];
}
- (void)handleTemporaryToke:(NSData *)responseData urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error {
    NSDictionary *kvp = [WFOAuthConnection parseKeyValueData:responseData];
    NSString *token  = [kvp valueForKey:kOAuthToken];
    NSString *secret = [kvp valueForKey:kOAuthTokenSecret];
    if (error != nil ) {
        [self invokeHandler:nil error:error];
    } else if (token == nil || secret == nil ) {
        [self reportError:WFOAuthUnexpectedResponse
         shortDescription:@"oauth_token or oauth_token_secret are not obtained."
              description:[NSString stringWithFormat:@"oauth_token:%@ , oauth_token_secret:%@", token, secret]
               suggestion:nil];
    } else {
        WFOAuthCredential *cre = [[WFOAuthCredential alloc] initWithKey:token secret:secret];
        [self requestAuthorization:cre];
    }
}

- (void)requestAuthorization:(WFOAuthCredential *)temporalCredential{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@",
                                       [self.resourceOwnerAuthorizeURI absoluteString],
                                       temporalCredential.token]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    _webView.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_webView loadRequest:request];
    });
}
- (void)requestToken:(NSString *)token verifier:(NSString *)verifier {
    __weak WFOAuthCredentialStore *weak_self = self;
    
    NSDictionary *params = @{kOAuthToken    : token,
                             kOAuthVerifier : verifier};
    _con = [WFOAuthConnection
            request:self.clientCredential
            tokenCredential:nil
            oauthParameters:params
            endpoint:self.tokenRequestURI
            httpMethod:WFOAuthHttpPOST
            queryParameters:nil
            handler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSDictionary *kvp = [WFOAuthConnection parseKeyValueData:responseData];
                NSString *token  = [kvp valueForKey:kOAuthToken];
                NSString *secret = [kvp valueForKey:kOAuthTokenSecret];
                if (error != nil) {
                    [weak_self invokeHandler:nil error:error];
                } else if (token == nil || secret == nil ) {
                    [weak_self reportError:WFOAuthUnexpectedResponse
                     shortDescription:@"oauth_token or oauth_token_secret are not obtained."
                          description:[NSString stringWithFormat:@"oauth_token:%@ , oauth_token_secret:%@", token, secret]
                           suggestion:nil];
                } else {
                    WFOAuthCredential *c = [[WFOAuthCredential alloc] initWithKey:token secret:secret];
                    [weak_self invokeHandler:c error:nil];
                }
            }];
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *cb = [self.callbackURL absoluteString];
    if ( [[[request URL] absoluteString] hasPrefix:cb] ) {
        NSDictionary *params = [self parseKeyValuePairsFromQuery:[request URL]];
        NSString *token    = params[kOAuthToken];
        NSString *verifier = params[kOAuthVerifier];
        if (token == nil || verifier == nil) {
            [self reportError:WFOAuthUnexpectedResponse
             shortDescription:@"oauth_token or oauth_verifier are not obtained."
                  description:[NSString stringWithFormat:@"oauth_token:%@ , oauth_verifier:%@", token, verifier]
                   suggestion:nil];
        } else {
            [self requestToken:token verifier:verifier];
        }
        return NO;
    } else {
        return YES;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self invokeHandler:nil error:error];
}
@end
