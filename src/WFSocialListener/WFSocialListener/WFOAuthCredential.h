//
//  WFOAuthCredential.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/19.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface WFOAuthCredential : NSObject

@property (nonatomic, readonly) NSString *token;
@property (nonatomic, readonly) NSString *secret;

- (id)initWithKey:(NSString *)token secret:(NSString *)secret;
- (ACAccountCredential *)createACAccountCredential;
@end
