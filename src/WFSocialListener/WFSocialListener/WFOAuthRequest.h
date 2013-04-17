//
//  WFOAuthRequest.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/08.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFOAuthCredential.h"

typedef enum {
    WFOAuthHttpUnknown = 0,
    WFOAuthHttpGET,
    WFOAuthHttpPOST
} WFOAuthHttpMethodType;

@interface WFOAuthRequest : NSObject
- (id)initWithCredential:(WFOAuthCredential *)clientCredential
        tokenCredential:(WFOAuthCredential *)token
        oauthAdditionalParameters:(NSDictionary *)oauthParams
               endpoint:(NSURL *)endpoint
             httpMethod:(WFOAuthHttpMethodType)httpMethod
        queryParameters:(NSDictionary *)p;
- (NSString *)calcSignature:(NSURLRequest *)request parameters:(NSDictionary *)parameters;
- (NSURLRequest *)preparedURLRequest;
@end
