//
//  WFAccount.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/08.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "WFOAuthCredential.h"

@interface WFAccount : NSObject

@property (nonatomic, readonly) ACAccount *account;

@property (nonatomic, readonly, getter = getIdentifier) NSString *identifier;
@property (nonatomic, readonly, getter = getAccountType) ACAccountType *accountType;
@property (nonatomic, readonly, getter = getAccountDescription) NSString *accountDescription;
@property (nonatomic, readonly, getter = getUsername) NSString *username;
@property (nonatomic, readonly, getter = getCredential) ACAccountCredential *credential;

@property (nonatomic) WFOAuthCredential *clientCredential;
@property (nonatomic) WFOAuthCredential *tokenCredential;

- (id)initWithAccount:(ACAccount *)account;
- (WFAccount *)cloneAccount;
@end
