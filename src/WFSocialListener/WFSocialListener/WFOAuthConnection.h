//
//  WFOAuthConnection.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/21.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "WFOAuthCredential.h"
#import "WFOAuthRequest.h"

@interface WFOAuthConnection : WFOAuthRequest<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
+(WFOAuthConnection *)request:(WFOAuthCredential *)clientCredential
              tokenCredential:(WFOAuthCredential *)token
        oauthParameters:(NSDictionary *)oauthParams
                     endpoint:(NSURL *)endpoint
                   httpMethod:(WFOAuthHttpMethodType)httpMethod
              queryParameters:(NSDictionary *)p
                      handler:(SLRequestHandler)handler;
// Key-Valueペアに分解。&で分解、のち=で分解。辞書に収める。
+(NSDictionary *)parseKeyValueData:(NSData *)data;
@end
