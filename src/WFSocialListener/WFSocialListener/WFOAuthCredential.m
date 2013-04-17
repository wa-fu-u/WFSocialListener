//
//  WFOAuthCredential.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/19.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFOAuthCredential.h"

@interface WFOAuthCredential () {
}
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *secret;
@end

@implementation WFOAuthCredential
- (id)initWithKey:(NSString *)t secret:(NSString *)s {
    self = [super init];
    if (self) {
        self.token = t;
        self.secret = s;
    }
    return self;
}
- (ACAccountCredential *)createACAccountCredential {
    return [[ACAccountCredential alloc] initWithOAuthToken:self.token tokenSecret:self.secret];
}

- (NSString *)description; {
    return [NSString stringWithFormat:@"token:%@ secret:%@.",self.token, self.secret];
}
@end
