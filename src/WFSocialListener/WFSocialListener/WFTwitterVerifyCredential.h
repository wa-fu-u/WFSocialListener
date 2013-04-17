//
//  WFTwitterVerifyCredential.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/16.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "WFConnector.h"

@interface WFTwitterVerifyCredential : NSObject
// Latest user information, KVC
@property (nonatomic, readonly) WFAccount *account;

@property (nonatomic, readonly) BOOL verified;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *screen_name;
@property (nonatomic, readonly) NSString *profile_image_url;

+(WFTwitterVerifyCredential *)accountVerifyCredential:(WFAccount *)account handler:(WFConnectorHandler)handler;
@end
