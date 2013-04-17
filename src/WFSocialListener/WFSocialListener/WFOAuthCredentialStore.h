//
//  WFOAuthCredentialStore.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/29.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFOAuthCredential.h"
#import "WFError.h"

@class WFOAuthCredentialStore;

typedef void(^WFOAuthClientCallback)(WFOAuthCredentialStore *sender, WFOAuthCredential *credential, NSError *error);

// Credential のストレージクラス
@interface WFOAuthCredentialStore : NSObject<UIWebViewDelegate>
@property (nonatomic, readonly) WFOAuthCredential *clientCredential;
@property (nonatomic, readonly) NSURL *callbackURL;
@property (nonatomic, readonly) NSURL *temporalCredentialRequestURI;
@property (nonatomic, readonly) NSURL *resourceOwnerAuthorizeURI;
@property (nonatomic, readonly) NSURL *tokenRequestURI;

+(WFOAuthCredentialStore *)requestToken:(UIWebView *)webView
                       clientCredential:(WFOAuthCredential *)clientCredential
                            callbackURL:(NSURL *)c
                  temporalCredentialURI:(NSURL *)t
                           ahthorizeURI:(NSURL *)a
                        tokenRequestURI:(NSURL *)r
                                handler:(WFOAuthClientCallback)handler;
@end
