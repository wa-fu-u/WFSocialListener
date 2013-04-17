//
//  WFOAuth1Token.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/18.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFOAuthToken.h"

@implementation WFOAuthToken
- (id)initWithKey:(NSString *)key
           secret:(NSString *)secret
          session:(NSString *)session
       expiration:(NSDate *)expiration
        renewable:(BOOL)canBeRenewed
{
    NSParameterAssert(key);
    NSParameterAssert(secret);
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.key = key;
    self.secret = secret;
    self.session = session;
    self.expiration = expiration;
    self.renewable = canBeRenewed;
    
    return self;
}
@end
