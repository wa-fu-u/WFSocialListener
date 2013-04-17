//
//  WFOAuth1Token.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/18.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFOAuthToken : NSObject
@property (readwrite, nonatomic, copy) NSString *key;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *session;
@property (readwrite, nonatomic, strong) NSDate *expiration;
@property (readwrite, nonatomic, assign, getter = canBeRenewed) BOOL renewable;

@end
