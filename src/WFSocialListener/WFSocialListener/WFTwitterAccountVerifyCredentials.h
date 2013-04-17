//
//  WFTwitterGetDirectMessages.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/05.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "WFConnector.h"

@interface WFTwitterAccountVerifyCredentials : NSObject

// Latest user information, KVC
@property (nonatomic, readonly) WFAccount *account;
@property (nonatomic, readonly) NSString *name;

+(id)verifyCredentials:(WFAccount *)account handler:(WFConnectorHandler)handler;
@end
