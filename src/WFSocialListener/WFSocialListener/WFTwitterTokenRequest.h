//
//  WFTwitterTokenRequest.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/05.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "WFOAuthCredential.h"
#import "WFConnector.h"

typedef void(^WFTwitterTokenRequestHandler)(BOOL succeeded, NSError *error);

// ユーザ認証によるOAuthトークンを取得します
@interface WFTwitterTokenRequest : NSObject
+(WFTwitterTokenRequest *)requestToken:(UIWebView *)webView
                               account:(WFAccount *)account
                           callbackURL:(NSString *)callbackURL
                               handler:(WFTwitterTokenRequestHandler)handler;
@end
